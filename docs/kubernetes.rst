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

If you get Port 10251 is in use.

.. code-block:: bash

  $ netstat -lnp | grep 1025
  tcp6       0      0 :::10251                :::*                    LISTEN      4366/kube-scheduler
  tcp6       0      0 :::10252                :::*                    LISTEN      4353/kube-controlle
  $ kill 4366
  $ kill 4353

See:

`<https://github.com/kubernetes/minikube>`_

`<https://github.com/kubernetes/minikube/issues/2575>`_

`<https://github.com/kubernetes/minikube/issues/2622>`_


Normal install of minikube as root
------------------------------------------------------------

root@armitage:~# curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && mv minikube /usr/local/bin/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 40.7M  100 40.7M    0     0  6608k      0  0:00:06  0:00:06 --:--:-- 6932k

I also tried the command below without --apiserver-ips and --apiserver-name and I was able to access from other host as 192.168.1.204 (the local IP of this host)

root@armitage:~# minikube start --vm-driver=none --apiserver-ips 127.0.0.1 --apiserver-name localhost
Starting local Kubernetes v1.10.0 cluster...
Starting VM...
Getting VM IP address...
Moving files into cluster...
Downloading kubeadm v1.10.0
Downloading kubelet v1.10.0
Finished Downloading kubelet v1.10.0
Finished Downloading kubeadm v1.10.0
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.

===================
WARNING: IT IS RECOMMENDED NOT TO RUN THE NONE DRIVER ON PERSONAL WORKSTATIONS
	The 'none' driver will run an insecure kubernetes apiserver as root that may leave the host vulnerable to CSRF attacks

When using the none driver, the kubectl config and credentials generated will be root owned and will appear in the root home directory.
You will need to move the files to the appropriate location and then set the correct permissions.  An example of this is below:

	sudo mv /root/.kube $HOME/.kube # this will write over any previous configuration
	sudo chown -R $USER $HOME/.kube
	sudo chgrp -R $USER $HOME/.kube
	
	sudo mv /root/.minikube $HOME/.minikube # this will write over any previous configuration
	sudo chown -R $USER $HOME/.minikube
	sudo chgrp -R $USER $HOME/.minikube 

This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
Loading cached images from config file.
root@armitage:~# 


Uninstall minikube as root user
------------------------------------------------------------

Careful because it deletes all containers and their volumes. See `<https://github.com/kubernetes/minikube/issues/1043>`_ and `<https://github.com/kubernetes/minikube/issues/2146>`_.

minikube stop
minikube delete
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
rm -rf ~/.kube
rm -rf ~/.minikube
rm /usr/local/bin/minikube
rm -rf /etc/kubernetes/ # this seems to be enough to recreate minikube
systemctl stop '*kubelet*.mount'
docker system prune -af --volumes
docker images
systemctl stop kubelet.service 
systemctl disable kubelet.service 

systemctl status kubelet.service 

Mount directories
------------------------------------------------------------


Dashboard not working with --vm-driver=none
------------------------------------------------------------

root@armitage:~# minikube dashboard --logtostderr --v=5
W0504 15:19:58.594836   24041 root.go:148] Error reading config file at /root/.minikube/config/config.json: open /root/.minikube/config/config.json: no such file or directory
I0504 15:19:58.594982   24041 notify.go:109] Checking for updates...
Could not find finalized endpoint being pointed to by kubernetes-dashboard: Error validating service: Error getting service kubernetes-dashboard: services "kubernetes-dashboard" not found

Keep using VirtualBox for now until I can deploy dashboard on my own? Don't think so. Only problem with vmdriver=none seems to be dashboard. Learn how to expose it. See difference between service hello-minikube being type NodePort and service kubernetes being type ClusterIP

root@armitage:~# kubectl get services --all-namespaces 
NAMESPACE     NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
default       hello-minikube         NodePort    10.107.126.7     <none>        8080:30263/TCP   20m
default       kubernetes             ClusterIP   10.96.0.1        <none>        443/TCP          22m
kube-system   kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP    22m
kube-system   kubernetes-dashboard   ClusterIP   10.111.107.230   <none>        443/TCP          16m
root@armitage:~# kubectl get services -n kube-system
NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP   22m
kubernetes-dashboard   ClusterIP   10.111.107.230   <none>        443/TCP         16m
root@armitage:~# kubectl get services -n default
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hello-minikube   NodePort    10.107.126.7   <none>        8080:30263/TCP   20m
kubernetes       ClusterIP   10.96.0.1      <none>        443/TCP          22m
root@armitage:~# kubectl get services 
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hello-minikube   NodePort    10.107.126.7   <none>        8080:30263/TCP   20m
kubernetes       ClusterIP   10.96.0.1      <none>        443/TCP          22m

I think I have to manually deploy dashboard as explained at https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

