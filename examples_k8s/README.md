# Examples for Kubernetes (K8S)

My recommendation for Kubernetes: **Rancher** by SUSE:
* https://rancher.com/ | https://github.com/rancher (CNCF-certified)
* [Rancher](https://rancher.com/products/rancher) - Dashbaord/GUI for cluster operations, monitoring and more
* [RKE](https://rancher.com/products/rke) - Rancher Kubernetes Engine (AMD64/x86_64) for on-premise installation
  * RKE v1: [Docs](https://rke.docs.rancher.com/installation) , [GitHub](https://github.com/rancher/rke)
  * RKE v2: [Docs](https://docs.rke2.io/install/quickstart/) , [GitHub](https://github.com/rancher/rke2/) - Recommended! (used k3s in background)
* [k3s](https://rancher.com/products/k3s) - Lightweight Kubernetes - Optimized for both x86 and Arm processors (ARM64 and ARMv7, example: Raspberry Pi) [Docs](https://docs.k3s.io/)/[GitHub](https://github.com/k3s-io/k3s)
* [Longhorn](https://rancher.com/products/longhorn) - Persistent Storage (AMD64/x86_64 & ARM64) [Docs](https://longhorn.io/docs/)/[GitHub](https://github.com/longhorn/longhorn)
* [local-path-provisioner](https://github.com/rancher/local-path-provisioner) - Persistent Storage (AMD64/x86_64 & ARM64, ARM32)  (when local path is needed or single node, example: Raspberry Pi)
* [NeuVector](https://neuvector.com/) for [#Security](#security)

If you don't want use Rancher, then install Kubernetes with [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).  

KVM hypervisor: [Proxmox](https://www.proxmox.com/en/proxmox-ve) based on [Debian](https://www.debian.org/) with [CEPH](https://ceph.io/en/discover/) and ZFS storage support. If you want use VMs for Kubernetes Nodes.  

Help for install Kubernetes Tools? See my install [Script](https://github.com/Tob1asDocker/Collection/blob/master/scripts/kubernetes_tools_install.sh) for Linux Debian/Raspbian.  

## Operators
  
Some deployments in this project can be replaced by operators.  
A search/list for operators is available at [OperatorHub.io](https://operatorhub.io/)

Examples:
* **Monitoring (Prometheus/Grafana/Alertmanager)**:  
Prometheus-Operator [GitHub](https://github.com/prometheus-operator/kube-prometheus) / [Docs](https://prometheus-operator.dev/docs/prologue/introduction/)  
(If you use Rancher, it can be installed as an app. It is recommended to set a volume for Prometheus and Grafana so that there is no data loss.)
* (ECK) Elasticsearch-Operator: [GitHub](https://github.com/elastic/cloud-on-k8s) / [Docs](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html)
* Keycloak-Operator: [GitHub](https://github.com/keycloak/keycloak/tree/main/operator) / [Docs](https://www.keycloak.org/operator/installation#_installing_by_using_kubectl_without_operator_lifecycle_manager)
  * and Keycloak-Realm-Operator: [GitHub](https://github.com/keycloak/keycloak-realm-operator)
* MinIO-Operator: [GitHub](https://github.com/minio/operator) / [Docs](https://min.io/docs/minio/kubernetes/upstream/)
* MongoDB-Operator: [GitHub](https://github.com/mongodb/mongodb-kubernetes-operator)
* PostgreSQL-Operator: [GitHub](https://github.com/zalando/postgres-operator) / [Docs](https://postgres-operator.readthedocs.io/en/latest/)
  * for TimescaleDB Community License set in [Spilo-Dockerfile](https://github.com/zalando/spilo/blob/master/postgres-appliance/Dockerfile#L48) TIMESCALEDB_APACHE_ONLY=false and build docker image.
* RabbitMQ-Operator: [GitHub](https://github.com/rabbitmq/cluster-operator) / [Docs](https://www.rabbitmq.com/kubernetes/operator/operator-overview.html)
* Redis-Operator: [GitHub](https://github.com/spotahome/redis-operator)
* VerneMQ-Operator: [GitHub](https://github.com/vernemq/vmq-operator) / [Docs](https://docs.vernemq.com/guides/vernemq-on-kubernetes#deploy-vernemq-using-the-kubernetes-operator)

## Ingress (Proxy)

* NGINX (default)
  * [#1 (used by RKE)](https://github.com/kubernetes/ingress-nginx)
  * [#2 (by NGINX)](https://github.com/nginxinc/kubernetes-ingress)
* [Traefik](https://github.com/traefik/traefik-helm-chart)
* [HAProxy](https://github.com/haproxytech/kubernetes-ingress)

## SSL / TLS

For this Examples i used also self signed certificate create with easy-rsa ([#1](https://github.com/OpenVPN/easy-rsa),[#2](https://github.com/Tob1as/docker-tools#easy-rsa)), when you want use Let's Encrypt you can use [Cert-Manager](https://cert-manager.io/docs/) ([GitHub](https://github.com/cert-manager/cert-manager)).

## Security

[NeuVector](https://neuvector.com/) by SUSE: Full Lifecycle Container Security Platform delivers the only cloud-native security with uncompromising end-to-end protection from DevOps vulnerability protection to automated run-time security, and featuring a true Layer 7 container firewall. [Docs](https://open-docs.neuvector.com/)/[GitHub](https://github.com/neuvector/neuvector)

## more Examples

You can find other examples (e.g. databases) in my other Docker [Projects](https://github.com/Tob1as) beginn with `docker-*`.

## Help

### Secrets

https://kubernetes.io/docs/concepts/configuration/secret/

Convert String to base64:
```powershell
# Windows Powershell
[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('value'))
```
```sh
# Linux Shell
echo -n 'value' | base64
```

## Feedback

If you have feedback, questions or improvements, create an issue or an MR.
