#!/bin/bash
set -e

# Kubernetes Tools (kubectl, helm, rke, k3s) install on Debian/Raspbian 11 bullseye!
# 
# Source-URL: https://github.com/Tob1asDocker/Collection/blob/master/scripts/kubernetes_tools_install.sh
# Created: 2022-03-17 ; last Update: 2022-03-19
#

# colors
n=`tput sgr0`     # normal/reset
r=`tput setaf 1`  # red
g=`tput setaf 2`  # green
y=`tput setaf 3`  # yellow
b=`tput setaf 4`  # blue
lb=`tput setaf 6` # lightblue

if [ $(id -u) -ne 0 ]; then
    echo "${r}Use \"root\"-User or \"sudo ./kubernetes_tools_install.sh\"!${n}";
    exit 0
fi

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

if ! command_exists docker; then
    echo "${y}>> INFO: Recommended install Container Engine (Docker)${n}"
    echo "${b}>> Docker Install script: https://github.com/Tob1asDocker/Collection/blob/master/scripts/docker+docker-compose_install.sh${n}"
fi

# Install some required packages
install_requirements () {
    echo "${b}>> Install some required packages${n}"
    apt update
    apt install -y \
        apt-transport-https \
        ca-certificates \
        curl
}

# Install KUBECTL <https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/>
install_kubectl () {
    if ! command_exists kubectl; then
    
        echo "${b}>> Install KUBECTL${n}"
        
        # Download the Google Cloud public signing key
        curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
        
        # Add the Kubernetes apt repository
        echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
        
        # Update apt package index with the new repository and install kubectl
        apt-get update
        apt-get install -y kubectl
        
        # show version
        kubectl version --client
    else 
        echo "${lb}>> KUBECTL is exists.${n}"
    fi
}

# kubectl bash completion
kubectl_add_bash_completion () {
    if command_exists kubectl; then
        echo "${b}>> kubectl: add bash completion${n}"
        kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null
    else
        echo "${y}>> kubectl not found. bash completion failed.${n}"
    fi
}

# kubectl editor
kubectl_set_editor () {
    if command_exists kubectl && [ ! -f "/etc/profile.d/kubeeditor.sh" ] ; then
        echo "${b}>> kubectl: set default editor${n}"
        echo "export KUBE_EDITOR=nano" > /etc/profile.d/kubeeditor.sh
    else
        echo "${y}>> kubectl not found. set editor failed.${n}"
    fi
}

# Install HELMv3 <https://helm.sh/docs/intro/install/>
install_helm () {
    if ! command_exists helm; then
        
        echo "${b}>> Install HELM${n}"
        
        # Download the public signing key
        curl https://baltocdn.com/helm/signing.asc | apt-key add -
        
        # Add the Helm apt repository
        echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
        
        # Update apt package index with the new repository and install helm
        apt-get update
        apt-get install -y helm
        
        # show version
        helm version
	    
    else 
        echo "${lb}>> HELM is exists.${n}"
    fi
}

# helm bash completion
helm_add_bash_completion () {
    if command_exists helm; then
        echo "${b}>> helm: add bash completion${n}"
        helm completion bash  | tee /etc/bash_completion.d/helm > /dev/null
    else
        echo "${y}>> helm not found. bash completion failed.${n}"
    fi
}

# Install RKE <https://rancher.com/docs/rke/latest/en/installation/>
install_rke () {
    #if ! command_exists rke; then
    
        echo "${b}>> Install RKE (Rancher Kubernetes Engine)${n}"
        
        # get latest stable version
        RKE_VERSION=$(curl -s https://api.github.com/repos/rancher/rke/releases/latest | grep 'tag_name' | cut -d\" -f4)
		
        ARCH=$(uname -m)
        case $ARCH in
            amd64)
                ARCH=amd64
                ;;
            x86_64)
                ARCH=amd64
                ;;
            arm64)
                ARCH=arm64
                ;;
            aarch64)
                ARCH=arm64
                ;;
            arm*)
                ARCH=arm
                ;;
            *)
                fatal "${r}Unsupported architecture $ARCH ${n}"
        esac
        
        # download
        curl -L https://github.com/rancher/rke/releases/download/${RKE_VERSION}/rke_`uname -s | tr '[:upper:]' '[:lower:]'`-${ARCH} -o /usr/bin/rke
        
        # set file permission
        chmod +x /usr/bin/rke
        
        # show version
        rke --version
        
        # info for cluster.yml config
        echo -e "${b}>> Install RKE finish. \n>> RKE Docs: \n>> - https://rancher.com/docs/rke/latest/en/config-options/ \n>> - example: https://rancher.com/docs/rke/latest/en/example-yamls/ ${n}"
        
    #else 
    #    echo "${lb}>> RKE is exists.${n}"
    #fi
}

# RKE example Cluster.yml <https://rancher.com/docs/rke/latest/en/config-options/> <https://rancher.com/docs/rke/latest/en/example-yamls/>
rke_config () {
    if command_exists rke && [ ! -f "cluster.yml" ] ; then
        echo "${b}>> RKE example cluster.yml is create ...${n}"
        host_name=$(uname -n)                                                     # 'hostname -s' or 'uname -n'
        #ip_address=$(hostname -I | cut -d' ' -f1)                                # "hostname -I | cut -d' ' -f1" or 'curl https://checkip.amazonaws.com' or 'curl https://ifconfig.me/ip'
        user_name=$(last -Fwp now | grep 'logged in' | head -n 1 | cut -d' ' -f1) # get last login user
		
        cat << EOF > cluster.yml
nodes:
    - address: $host_name   # hostname, domain or ip-address
      #internal_address: 10.0.0.100
      hostname_override: $host_name
      user: $user_name
      port: 22
      role:
        - controlplane
        - etcd
        - worker
      ssh_key_path: ~/.ssh/id_rsa
      #ssh_key: |-
      #  -----BEGIN OPENSSH PRIVATE KEY-----
      #  -----END OPENSSH PRIVATE KEY-----

enable_cri_dockerd: true

#private_registries:
#  - url: docker.io
#    user: DOCKER_USERNAME
#    password: DOCKER_PASSWORD
#    is_default: false  # All system images will be pulled using this registry. 

cluster_name: $host_name

services:
  etcd:
    backup_config:
      interval_hours: 24
      retention: 7
      #s3backupconfig:
      #  access_key: S3_ACCESS_KEY
      #  secret_key: S3_SECRET_KEY
      #  bucket_name: s3-bucket-name
      #  region: "eu-central-1"
      #  folder: "" # Optional
      #  endpoint: s3.amazonaws.com
      #  custom_ca: |-
      #    -----BEGIN CERTIFICATE-----
      #    $CERTIFICATE
      #    -----END CERTIFICATE-----
  kube-api:
    service_cluster_ip_range: 10.43.0.0/16
    service_node_port_range: 30000-32767
  kube-controller:
    cluster_cidr: 10.42.0.0/16
    service_cluster_ip_range: 10.43.0.0/16
  kubelet:
    cluster_domain: cluster.local
    cluster_dns_server: 10.43.0.10

network:
  plugin: canal
  #mtu: 1400
  #options:
  #  canal_iface: eth1
  #  canal_flannel_backend_type: vxlan
  #  canal_autoscaler_priority_class_name: system-cluster-critical
  #  canal_priority_class_name: system-cluster-critical

ingress:
  provider: nginx

#addons: |-
#  ---
#  apiVersion: v1
#  kind: Pod
#  metadata:
#    name: toolbox
#    namespace: default
#  spec:
#    containers:
#    - name: toolbox
#      image: tobi312/tools:toolbox
#      resources:
#        requests:
#          memory: "64Mi"
#          cpu: "0.1"
#        limits:
#          memory: "512Mi"
#          cpu: "0.5"
  
#addons_include:
#  - https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
EOF

        echo -e "${b}>> ...Done! cluster.yml was created. \n>> - You can show/edit this and then use \"rke up\" to create the cluster. \n>> - Before add ssh-key to target host! \n>> - Then use \"kube_config_cluster.yml\" as \"~/.kube/config\" to connect with kubectl to cluster.${n}"
        
        # when error: "FATA[0023] [[network] Host [****] is not able to connect to the following ports: [****:2379]. Please check network policies and firewall rules]"
        # then: https://github.com/rancher/rke/issues/955#issuecomment-685571566 (IPv6 ?) (and https://github.com/rancher/rancher/issues/14249#issuecomment-400941075)
        #
        # cleanup after cluster remove (rke remove): https://github.com/rancher/rancher/files/2144217/rancher_clean-dirs.sh.txt    

    else 
        echo "${lb}>> RKE example Cluster.yml is exists or RKE is not exists.${n}"
    fi
}

# Install K3s <https://rancher.com/docs/k3s/latest/en/installation/install-options/#options-for-installation-from-binary> <https://k3s.io/>
install_k3s () {
    #if ! command_exists k3s; then
    
        echo "${b}>> Install K3s (Lightweight Kubernetes)${n}"
        
        # get latest stable version
        K3S_VERSION=$(curl -s https://api.github.com/repos/k3s-io/k3s/releases/latest | grep 'tag_name' | cut -d\" -f4)
        
        ARCH=$(uname -m)
        case $ARCH in
            amd64)
                ARCH=amd64
                SUFFIX=
                ;;
            x86_64)
                ARCH=amd64
                SUFFIX=
                ;;
            arm64)
                ARCH=arm64
                SUFFIX=-${ARCH}
                ;;
            aarch64)
                ARCH=arm64
                SUFFIX=-${ARCH}
                ;;
            arm*)
                ARCH=arm
                SUFFIX=-${ARCH}hf
                ;;
            *)
                fatal "${r}Unsupported architecture $ARCH ${n}"
        esac
		
        # download
        curl -L https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/k3s${SUFFIX} -o /usr/bin/k3s
        
        # set file permission
        chmod +x /usr/bin/k3s
        
        # show version
        k3s --version
    
    #else 
    #    echo "${lb}>> K3s is exists.${n}"
    #fi
}

# Main
main () {
    install_requirements
    install_kubectl
    kubectl_add_bash_completion
    kubectl_set_editor
    install_helm
    helm_add_bash_completion
    install_rke
    rke_config
    #install_k3s  # when use this, rke and rke_config not needed!
    echo "${g}>> install done! (Recommended: Restart you shell session!)${n}"
}

main