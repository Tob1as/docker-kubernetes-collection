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

## Operators

A [Prometheus-Operator](https://github.com/prometheus-operator/prometheus-operator) is used for monitoring.  
(If you use Rancher, it can be installed as an app. It is recommended to set a volume for Prometheus and Grafana so that there is no data loss.)  
  
Some deployments in this project can be replaced by operators.  
A search/list for operators is available at [OperatorHub.io](https://operatorhub.io/)

## SSL / TLS

For this Examples i used also self signed certificate create with easy-rsa ([#1](https://github.com/OpenVPN/easy-rsa),[#2](https://github.com/Tob1as/docker-tools#easy-rsa)), when you want use Let's Encrypt you can use [Cert-Manager](https://cert-manager.io/docs/).

## more Examples

You can find other examples (e.g. databases) in my other Docker [Projects](https://github.com/Tob1as) beginn with `docker-*`.

## Feedback

If you have feedback, questions or improvements, create an issue or an MR.
