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

Some examples of `JSONPath <https://kubernetes.io/docs/reference/kubectl/jsonpath/>`_.

.. code-block:: bash

  kubectl get pod --namespace=kube-system etcd-ripley -o=jsonpath='{range .status.containerStatuses[*]}{"image:\t"}{.image}{"\n"}{end}'