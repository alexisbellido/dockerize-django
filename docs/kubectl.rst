Running kubectl Commands
==========================================

Make sure you have autocompletion enabled to get the most out of kubectl.

You can use contexts to run kubectl commands against a particular namespace in a cluster. Let's create my-context to interact with objects in the kube-system namespace but first let's see what's the current context.

.. code-block:: bash

  kubectl config get-contexts

Now create a context to access the kube-system namespace and start using it.

.. code-block:: bash

  kubectl config set-context my-context --namespace=kube-system --cluster=kubernetes --user=kubernetes-admin
  kubectl config use-context my-context
  
Once you can go back to original context.

.. code-block:: bash

  kubectl config use-context kubernetes-admin@kubernetes

The configuration for contexts is stored in /etc/kubernetes/admin.conf for the root user or, if you are using kubectl as non-root, in ~/.kube/config.

Some examples of `JSONPath <https://kubernetes.io/docs/reference/kubectl/jsonpath/>`_.

.. code-block:: bash

  kubectl get pod --namespace=kube-system etcd-ripley -o=jsonpath='{range .status.containerStatuses[*]}{"image:\t"}{.image}{"\n"}{end}'

.. code-block:: bash
  
  kubectl get pod kubernetes-dashboard-767dc7d4d-tcbp7 -o=jsonpath='{range .status.containerStatuses[*]}{"image: "}{.image}{"\ncontainerID: "}{.containerID}{"\n"}{end}
  kubectl get pods --namespace=kube-system -o jsonpath --template='{.items[*].metadata.name}'
  
Tests with labels.

.. code-block:: bash

  kubectl label pods POD color=red
  kubectl label pods POD --overwrite color=green
  kubectl label pods POD color-

  kubectl	run	alpaca-prod --image=gcr.io/kuar-demo/kuard-amd64:1 --replicas=2 --labels="ver=1,app=alpaca,env=prod"
  kubectl	run	alpaca-test	--image=gcr.io/kuar-demo/kuard-amd64:2 --replicas=1 --labels="ver=2,app=alpaca,env=test"
  kubectl	run	bandicoot-prod --image=gcr.io/kuar-demo/kuard-amd64:2 --replicas=2 --labels="ver=2,app=bandicoot,env=prod"
  kubectl	run	bandicoot-staging	--image=gcr.io/kuar-demo/kuard-amd64:2 --replicas=1 --labels="ver=2,app=bandicoot,env=staging"
  kubectl get deployments --show-labels -L env,ver
  
Execute in container

.. code-block:: bash

  kubectl exec -it POD -- sh
  kubectl exec -it POD -- cat /tmp/some-file