# Examples for Kubernetes (K8S)

My recommendation for Kubernetes: **Rancher**
* https://rancher.com/ | https://github.com/rancher (CNCF-certified)
* [Rancher](https://rancher.com/products/rancher) - GUI for cluster operations, monitoring and more
* [RKE](https://rancher.com/products/rke) - Rancher Kubernetes Engine (AMD64/x86_64)
* [k8s](https://rancher.com/products/k3s) - Lightweight Kubernetes - Optimized for both x86 and Arm processors (ARM64 and ARMv7 (example: Raspberry Pi))
* [Longhorn](https://rancher.com/products/longhorn) - Persistent Storage (AMD64/x86_64 & ARM64)
* [local-path-provisioner](https://github.com/rancher/local-path-provisioner) - Persistent Storage (AMD64/x86_64 & ARM64, ARM32)  (when using single node, example: Raspberry Pi)

and for KVM hypervisor: [Proxmox](https://www.proxmox.com/en/proxmox-ve) based on Debian with CEPH (include RADOS) or ZFS storage support.

## Links

* Website (NGINX/Apache, PHP, SSH/SFTP) -> [github.com/Tob1asDocker/php](https://github.com/Tob1asDocker/php/blob/master/k8s.yaml)
* MariaDB -> [github.com/Tob1asDocker/rpi-mariadb](https://github.com/Tob1asDocker/rpi-mariadb/blob/master/k8s.yaml)
* MinIO -> [github.com/Tob1asDocker/minio](https://github.com/Tob1asDocker/minio/blob/main/k8s.yaml)
