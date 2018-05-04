Run Kubernetes locally with Minikube
==========================================

This works on Linux, runs as root and uses `--vm-driver=none` to run the Kubernetes components on the host and bypass the virtual machine.

.. code-block:: bash

  $ sudo su
  $ minikube start --vm-driver=none --apiserver-ips 127.0.0.1 --apiserver-name localhost
  $ ls -l /root/.kube/
  $ kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.4 --port=8080
  $ minikube ssh # won't work because there's no virtual machine
  $ ls -l
  $ docker ps # Docker runs on host
  $ kubectl expose deployment hello-minikube --type=NodePort
  $ kubectl get pod
  $ minikube ip
  $ curl $(minikube service hello-minikube --url)

See:

`<https://github.com/kubernetes/minikube>`_
`<https://github.com/kubernetes/minikube/issues/2575>`_
`<https://github.com/kubernetes/minikube/issues/2622>`_
