images=(
    kube-apiserver:v1.23.1
    kube-controller-manager:v1.23.1
    kube-scheduler:v1.23.1
    kube-proxy:v1.23.1
    pause:3.6
    etcd:3.5.1-0
    coredns/coredns:v1.8.6
)

for imageName in ${images[@]} ; do
    ctr -n k8s.io i  tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
done

#ctr -n k8s.io i  tag a4ca41631cc7a k8s.gcr.io/coredns/coredns:v1.8.6