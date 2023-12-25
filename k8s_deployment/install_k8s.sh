#! /bin/bash
### Please refer to: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/ for latest version
sudo apt-get update -y
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

#### For containers (docker) setup
#### Please refer to: https://docs.docker.com/engine/install/ubuntu/  for latest version

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg -y; done
#1: Set up Docker's apt repository.
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg -y
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$(lsb_release -cs)") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
# Don't install containerd (because k8s requires CRI, which containerd does not support)
sudo apt-get install docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin -y

### For container run-time interface (cri-dockerd)
## Suggested by: https://github.com/Mirantis/cri-dockerd?tab=readme-ov-file#using-cri-dockerd
## Please refer to: https://github.com/Mirantis/cri-dockerd?tab=readme-ov-file#using-cri-dockerd
# We select the easiest way, install by release binary: https://github.com/Mirantis/cri-dockerd/releases
#1> Download release deb file
VERSION=0.3.8
ARCH=3-0.ubuntu-jammy_amd64
wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VERSION}/cri-dockerd_${VERSION}.${ARCH}.deb
# 2> Install
sudo dpkg -i ./cri-dockerd*


### For container run-time interface (containerd) --> Deprecated
# Please refer to: https://github.com/containerd/containerd/blob/main/docs/getting-started.md
# containerd config default > ./config.toml
# To use the systemd cgroup driver in /etc/containerd/config.toml with runc, set
# SystemdCgroup = true
# Use Stream Editor command: https://www.cyberciti.biz/faq/how-to-use-sed-to-find-and-replace-text-in-files-in-linux-unix-shell/
# sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' config.toml
# sudo cp -r ./config.toml /etc/containerd/config.toml
# sudo sysctl --system
# sudo systemctl restart containerd

### In order to fix CRI:
# Remove service: https://www.baeldung.com/linux/create-remove-systemd-services