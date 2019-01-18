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

  $ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

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

By default, your cluster will not schedule pods on the master for security reasons. If you want to be able to schedule pods on the master, e.g. for a single-machine Kubernetes cluster for development, run:

.. code-block:: bash

  $ kubectl taint nodes --all node-role.kubernetes.io/master-
  
===

1/17/19

before trying to upgrade kubeadm

$ kubectl version
Client Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.2", GitCommit:"17c77c7898218073f14c8d573582e8d2313dc740", GitTreeState:"clean", BuildDate:"2018-10-24T06:54:59Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"11", GitVersion:"v1.11.2", GitCommit:"bb9ffb1654d4a729bb4cec18ff088eacc153c239", GitTreeState:"clean", BuildDate:"2018-08-07T23:08:19Z", GoVersion:"go1.10.3", Compiler:"gc", Platform:"linux/amd64"}

upgrade plan didn't work so I did

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo kubeadm upgrade apply 1.13.2

upgrade didn't work so I reset the local test cluster

sudo kubeadm reset
sudo kubeadm init pod-network-cidr=10.244.0.0/16

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

  kubeadm join 192.168.1.183:6443 --token smyeu2.qvcej08e7sgha6lt --discovery-token-ca-cert-hash sha256:8ecdfcd403aba95f92f72f013dcdfe64538bf9e18d885da4289fb92109da3d27

Now I need to remove old $HOME/.kube and run the suggested commands and then deploy a pod network (I got Weave Net working). 

sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl version


CrashLoopBackOff for coredns pods
-------------------------------------------------------

https://coredns.io/plugins/loop/#troubleshooting

.. code-block:: bash

  $ kubectl get pod --namespace=kube-system

https://kubernetes.io/docs/tasks/debug-application-cluster/debug-pod-replication-controller/

replace local DNS in /etc/resolv.conf like this

.. code-block:: bash

  #nameserver 127.0.1.1
  #https://developers.google.com/speed/public-dns/
  nameserver 8.8.8.8

.. code-block:: bash

  $ kubectl -n kube-system delete pod coredns-7655b945bc-zs665

take a look at the logs of the current container:

.. code-block:: bash

  $ kubectl logs ${POD_NAME} ${CONTAINER_NAME}

For example:

.. code-block:: bash

  $ kubectl logs -n kube-system coredns-7655b945bc-k2xgt coredns 
