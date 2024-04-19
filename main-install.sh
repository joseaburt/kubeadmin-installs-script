sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# ----------------

sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

sudo kubeadm init

sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


echo "=================================="
echo "=================================="
echo "   INSTALLING CALICO              "
echo "=================================="
echo "=================================="

echo "1. Install the Tigera Calico operator and custom resource definitions."
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/tigera-operator.yaml

echo "2. Install Calico by creating the necessary custom resource. For more information on configuration options available in this manifest, see the installation reference."
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/custom-resources.yaml

echo "4. Remove the taints on the control plane so that you can schedule pods on it."
kubectl taint nodes --all node-role.kubernetes.io/control-plane- node-role.kubernetes.io/master-

echo "5. Confirm that you now have a node in your cluster with the following command."
kubectl get nodes -o wide

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubectl get nodes