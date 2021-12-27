#!/bin/bash

echo 临时关闭selinux
setenforce 0
getenforce

echo 永久关闭selinux
sed  -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
sed  -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

echo 关闭firewalld
systemctl disable firewalld --now

echo 设置时区
timedatectl set-timezone Asia/Shanghai
# ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

echo 同步时间
systemctl enable chronyd --now
chronyc -a makestep

echo 写入公钥
mkdir ~/.ssh
echo ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxHm4YvEmueduuH/UVzp6SAvO8L+XtqYMTAMZflzoJSLJ70VqraBcM+LTvbE0Wxh/CDlc/4K/mFIUVdlymqYQttcxGrPh2pU8iC3Fy/5DbGZ/HZvbF8Q/7rzPTUKynjxTMsg7sryzJP4FSZEYCU4/d8P5m71lh9uMDf74UvCGVX3JwG12/id+9Go3e/1AyK2RkGB1vX/IocrmMWd3fMojrUeGzGvMy+U0UIxYE/6r0upXyOo1nurXmJexBE1PZJWXFQjaYfVvSd+dUOtf/6HK10A0iM213NMP5LnccEx7pDRFfZGds1KeZx89eO0MQ49gVLtvGjuRtNxCacYYaWG9yQ== rsa 2048-011521 >> ~/.ssh/authorized_keys

echo 禁用ssh密码登陆
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config 
systemctl restart sshd

#echo 使用华为源
#cd /etc/yum.repos.d/
#mkdir archive
#mv *.repo archive/
#curl -O https://repo.huaweicloud.com/repository/conf/CentOS-8-reg.repo
#yum makecache -y
