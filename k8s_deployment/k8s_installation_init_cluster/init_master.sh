#! /bin/bash
## This is a shell script to initialize a Kubernetes cluster with an assumption
## that your master host machine already installed kubeadm, kubectl, kubelet & container runtime
## Refer to: 
## https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# Clean up first
#systemctl restart cri-docker.service
# $yes | sudo kubeadm reset -f
# Note: If using multiple container interfaces (CRI) endpoints.
# We must specify the endpoint: 
# For instance: We used cri-dockerd with Docker Engine
yes | sudo kubeadm reset -f --cri-socket unix:///var/run/cri-dockerd.sock


### Temporarily turn off "swap configuration" mechanism.
## For disalbe swap permanently: https://tecadmin.net/disable-swapfile-on-ubuntu/
sudo swapoff -a


### Init cluster
# $ sudo kubeadm init --pod-network-cidr=10.244.0.0/16
# Note: If using multiple container interfaces (CRI) endpoints.
# We must specify the endpoint: 
# For instance: We used cri-dockerd with Docker Engine
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket unix:///var/run/cri-dockerd.sock

### output message of the above command if sucess would looks like:
### ---------------
# Your Kubernetes control-plane has initialized successfully!

# To start using your cluster, you need to run the following as a regular user:

#   mkdir -p $HOME/.kube
#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#   sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Alternatively, if you are the root user, you can run:

#   export KUBECONFIG=/etc/kubernetes/admin.conf

# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#   https://kubernetes.io/docs/concepts/cluster-administration/addons/

# Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join 192.168.2.18:6443 --token regfmr.a4qbvicng9ln29wl \
# 	--discovery-token-ca-cert-hash sha256:6a44703f6871c755b06362ad2204d091cdc8073f3e2647e6c3deaac9872ed890
### -------------------

mkdir -p $HOME/.kube
yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

### Deploy a pod network.
### Here we use: https://github.com/flannel-io/flannel#flannel
## Please refer to: https://github.com/kubernetes/design-proposals-archive/blob/main/network/networking.md
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

### To test the setup result:
kubectl get nodes
kubectl get pods -A

### In order to schedule other pods in the same master host (single-machine for development)
### Please refer to: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
kubectl taint nodes --all node-role.kubernetes.io/control-plane-


### Join a node (if you have more than 01 machine node) - Run this command on another machine
# sudo kubeadm join 192.168.2.18:6443 --token regfmr.a4qbvicng9ln29wl \
# 	--discovery-token-ca-cert-hash sha256:6a44703f6871c755b06362ad2204d091cdc8073f3e2647e6c3deaac9872ed890

### If there is any errors during the above, please reset
# sudo kubeadm reset --cri-socket unix:///var/run/cri-dockerd.sock


#### Restart daemon
#Daemon reload
# $ systemctl daemon-reload
# $ systemctl enable cri-docker.service
# $ systemctl enable --now cri-docker.socket
# Apply sysctl params without reboot
# $ sudo sysctl --system