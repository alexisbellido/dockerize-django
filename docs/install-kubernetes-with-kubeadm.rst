Install Kubernetes on Ubuntu with kubeadm
===================================================

`Official documentation <https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/>`_.

Make sure kubelet and kubeadm are the same version from package repository.

Disable swap now.

.. code-block:: bash

  swapoff -a
  cat /proc/swaps

Disable swap in /etc/fstab permanently.

.. code-block:: bash

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
  
Use Kubernetes dashboard with bearer token as described on `<https://github.com/kubernetes/dashboard>`_ and `<https://github.com/kubernetes/dashboard/wiki/Creating-sample-user>`_.

.. code-block:: bash

  kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

.. code-block:: bash

  Name:         admin-user-token-8md5q
  Namespace:    kube-system
  Labels:       <none>
  Annotations:  kubernetes.io/service-account.name=admin-user
                kubernetes.io/service-account.uid=c3a3ee04-b2ec-11e8-8dcc-f01faf2a4d5f

  Type:  kubernetes.io/service-account-token

  Data
  ====
  ca.crt:     1025 bytes
  namespace:  11 bytes
  token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLThtZDVxIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJjM2EzZWUwNC1iMmVjLTExZTgtOGRjYy1mMDFmYWYyYTRkNWYiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.ssFJl6HGWYtZKAIdjaWcQ5oRIh_h9jeJkP3vEwIyzk41_rAuYUcClWClmMajxSTAlLY2mf3QYOPHqU84QosLVJevqxam4aR090ZYXtJOfQ4WJzSutKH9TLiQVQgCeUP3Rcv8GaTq4AmEwcBUCSb3EKjibtGp2gEVtw9-H_VnK7s7-6-S0an8C8jer8BF9XRMuUEKPPj9-WjeBCILK0yU2Ubb_UczMSprbUO8ub6nPAuEmipEgFaZW0UfSLKVeLO68eDEkMH3cnt-eswgXvRCzX5v-OtGTQGDdtPwwJB1l8iyYadswFeXFjeS-gj_jpsQm-MzmTHzz6u8684TQ06HQA