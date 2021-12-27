#!/bin/bash

# 在 master 节点和 worker 节点都要执行

# 安装 containerd
# 参考文档如下
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd

echo 临时关闭selinux
setenforce 0
getenforce

echo 永久关闭selinux
sed  -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
sed  -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

echo 关闭firewalld
systemctl disable firewalld --now

echo 关闭交换区
swapoff -a
yes | cp /etc/fstab /etc/fstab_bak
cat /etc/fstab_bak |grep -v swap > /etc/fstab

echo 设置时区
timedatectl set-timezone Asia/Shanghai
# ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo 同步时间
systemctl enable chronyd --now
chronyc -a makestep

#echo 写入公钥
#mkdir ~/.ssh
#echo ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxHm4YvEmueduuH/UVzp6SAvO8L+XtqYMTAMZflzoJSLJ70VqraBcM+LTvbE0Wxh/CDlc/4K/mFIUVdlymqYQttcxGrPh2pU8iC3Fy/5DbGZ/HZvbF8Q/7rzPTUKynjxTMsg7sryzJP4FSZEYCU4/d8P5m71lh9uMDf74UvCGVX3JwG12/id+9Go3e/1AyK2RkGB1vX/IocrmMWd3fMojrUeGzGvMy+U0UIxYE/6r0upXyOo1nurXmJexBE1PZJWXFQjaYfVvSd+dUOtf/6HK10A0iM213NMP5LnccEx7pDRFfZGds1KeZx89eO0MQ49gVLtvGjuRtNxCacYYaWG9yQ== rsa 2048-011521 >> ~/.ssh/authorized_keys

#echo 禁用ssh密码登陆
#sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config 
#systemctl restart sshd

echo 安装基础软件包
dnf install wget vim lrzsz tar ipset ipvsadm -y

echo 开启内核模块自动加载服务
systemctl enable systemd-modules-load --now

echo 加载内核模块
cat <<EOF> /etc/modules-load.d/10-k8s-modules.conf
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
EOF

echo 手动加载内核模块
cat /etc/modules-load.d/10-k8s-modules.conf | xargs modprobe

echo 设置内核参数
cat <<EOF > /etc/sysctl.d/95-k8s-sysctl.conf 
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

echo 生效内核参数
sysctl -p /etc/sysctl.d/95-k8s-sysctl.conf 

echo 设置k8s源
cat <<EOF> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

echo 下载containerd
wget https://ccysh.club/https://github.com/containerd/containerd/releases/download/v1.5.5/cri-containerd-cni-1.5.5-linux-amd64.tar.gz

echo 解压containerd
tar -C / -xzf cri-containerd-cni-1.5.5-linux-amd64.tar.gz

echo 卸载旧版本containerd
yum remove -y containerd.io

echo 生成containerd配置文件
mkdir -p /etc/containerd/
containerd config default > /etc/containerd/config.toml
sed -i "s#k8s.gcr.io#registry.aliyuncs.com/google_containers#g"  /etc/containerd/config.toml
sed -i "s#https://registry-1.docker.io#registry.aliyuncs.com/google_containers#g"  /etc/containerd/config.toml

echo 设置环境变量
export PATH=$PATH:/usr/local/bin:/usr/local/sbin
echo "export PATH=$PATH:/usr/local/bin:/usr/local/sbin" >> /root/.bashrc
source /root/.bashrc

systemctl daemon-reload
systemctl enable containerd
systemctl restart containerd


# 配置K8S的yum源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

echo 卸载旧版本
dnf remove -y kubelet kubeadm kubectl

echo 安装kubelet、kubeadm、kubectl 1.23.1 版本 node节点可以屏蔽kubectl
dnf install -y kubelet-1.23.1 kubeadm-1.23.1 kubectl-1.23.1 --disableexcludes=kubernetes

crictl config runtime-endpoint unix:///run/containerd/containerd.sock

echo kubectl自动补全功能 master节点运行这个 node节点可以屏蔽这个
dnf install -y bash-completion
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc

# 重启 docker，并启动 kubelet
systemctl daemon-reload
systemctl enable kubelet --now

containerd --versions
kubelet --version