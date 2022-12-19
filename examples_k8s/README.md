# Examples for Kubernetes (K8S)

My recommendation for Kubernetes: **Rancher**
* https://rancher.com/ | https://github.com/rancher (CNCF-certified)
* [Rancher](https://rancher.com/products/rancher) - GUI for cluster operations, monitoring and more
* [RKE](https://rancher.com/products/rke) - Rancher Kubernetes Engine (AMD64/x86_64) for on-premise installation
  * RKE v1: [Docs](https://rancher.com/docs/rke/latest/en/installation/) , [GitHub](https://github.com/rancher/rke)
  * RKE v2: [Docs](https://docs.rke2.io/install/quickstart/) , [GitHub](https://github.com/rancher/rke2/) - Recommended!
* [k8s](https://rancher.com/products/k3s) - Lightweight Kubernetes - Optimized for both x86 and Arm processors (ARM64 and ARMv7, example: Raspberry Pi)
* [Longhorn](https://rancher.com/products/longhorn) - Persistent Storage (AMD64/x86_64 & ARM64)
* [local-path-provisioner](https://github.com/rancher/local-path-provisioner) - Persistent Storage (AMD64/x86_64 & ARM64, ARM32)  (when local path is needed or single node, example: Raspberry Pi)

If you don't want use Rancher, then install Kubernetes with [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).  

KVM hypervisor: [Proxmox](https://www.proxmox.com/en/proxmox-ve) based on [Debian](https://www.debian.org/) with [CEPH](https://ceph.io/en/discover/) and ZFS storage support. If you want use VMs for Kubernetes Nodes.  

Help for install Kubernetes Tools? Use my install [Script](https://github.com/Tob1asDocker/Collection/blob/master/scripts/kubernetes_tools_install.sh) for Linux Debian/Raspbian.  

## Links

* Website (NGINX/Apache, PHP, SSH/SFTP) -> [github.com/Tob1as/docker-php](https://github.com/Tob1as/docker-php/blob/master/k8s.yaml)
* MariaDB -> [github.com/Tob1as/docker-mariadb](https://github.com/Tob1as/docker-mariadb/blob/master/k8s.yaml)
* MinIO -> [github.com/Tob1as/docker-minio](https://github.com/Tob1as/docker-minio/blob/main/k8s.yaml)
