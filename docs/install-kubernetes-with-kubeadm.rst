Install Kubernetes on Ubuntu with kubeadm
===================================================

`Official documentation <https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/>`_.

Make sure kubelet and kubeadm are the same version from package repository.

Disable swap now.

.. code-block:: bash

  swapoff -a
  cat /proc/swaps

Disable swap in /etc/fstab permanently.

root~# kubeadm init pod-network-cidr=10.244.0.0/16

.. code-block:: bash

  ...
  ...
  [bootstraptoken] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
  [bootstraptoken] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
  [bootstraptoken] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
  [bootstraptoken] creating the "cluster-info" ConfigMap in the "kube-public" namespace
  [addons] Applied essential addon: CoreDNS
  [addons] Applied essential addon: kube-proxy

  Your Kubernetes master has initialized successfully!

  To start using your cluster, you need to run the following as a regular user:

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

  You should now deploy a pod network to the cluster.
  Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    https://kubernetes.io/docs/concepts/cluster-administration/addons/

  You can now join any number of machines by running the following on each node
  as root:

    kubeadm join 192.168.1.183:6443 --token 4fz4o2.ystkm89oo9whd3s4 --discovery-token-ca-cert-hash sha256:9de18c4e625581344bc17cd79c25b063cc498cb1cb565659705c999d57d9e345

===

Restarting the kubelet.

.. code-block:: bash

  systemctl daemon-reload
  systemctl restart kubelet

If getting connection refused with kubectl apply -f (as when installing a pod network add-on such as flannel) check if KUBECONFIG is set.

.. code-block:: bash

  export KUBECONFIG=/etc/kubernetes/admin.conf
  
==

Weave Net is the pod network that I got working.

.. code-block:: bash

  kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"