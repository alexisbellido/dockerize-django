Run Kubernetes locally with Minikube
==========================================

`Official Minikube documentation <https://kubernetes.io/docs/setup/minikube/>`_.

`Install kubectl binary using curl <https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-using-curl>`_.

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

Follow these steps under `Linux Continuous Integration without VM Support <https://github.com/kubernetes/minikube>`_ to run without virtual machine on Linux.

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl

export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir $HOME/.kube || true
touch $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config
sudo -E ./minikube start --vm-driver=none

# this for loop waits until kubectl can access the api server that Minikube has created
for i in {1..150}; do # timeout for 5 minutes
   ./kubectl get po &> /dev/null
   if [ $? -ne 1 ]; then
      break
  fi
  sleep 2
done

# kubectl commands are now able to interact with Minikube cluster

===================
WARNING: IT IS RECOMMENDED NOT TO RUN THE NONE DRIVER ON PERSONAL WORKSTATIONS
	The 'none' driver will run an insecure kubernetes apiserver as root that may leave the host vulnerable to CSRF attacks

When using the none driver, the kubectl config and credentials generated will be root owned and will appear in the root home directory.
You will need to move the files to the appropriate location and then set the correct permissions.  An example of this is below:

.. code-block:: bash

	sudo mv /root/.kube $HOME/.kube # this will write over any previous configuration
	sudo chown -R $USER $HOME/.kube
	sudo chgrp -R $USER $HOME/.kube
	
	sudo mv /root/.minikube $HOME/.minikube # this will write over any previous configuration
	sudo chown -R $USER $HOME/.minikube
	sudo chgrp -R $USER $HOME/.minikube 

This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true

Loading cached images from config file.

Uninstall minikube as root user
------------------------------------------------------------

Careful because it deletes all containers and their volumes. See `<https://github.com/kubernetes/minikube/issues/1043>`_ and `<https://github.com/kubernetes/minikube/issues/2146>`_.

.. code-block:: bash

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


Dashboard and --vm-driver=none
------------------------------------------------------------

Deploy dashboard with proxy as explained at `<https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/>`_ and grant admin access for local `<https://github.com/kubernetes/dashboard/wiki/Access-control>`_.

.. code-block:: bash

  root@armitage:~# minikube dashboard --logtostderr --v=5

Check `Docker Machine env <https://docs.docker.com/machine/reference/env/>`_ command to understand more about the docker daemon being used. This is per shell so you can reset by opening another terminal or delete DOCKER_* variables. When using minikube with --vm-driver=none the existing Docker on localhost is used.