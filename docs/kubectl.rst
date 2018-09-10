Running kubectl Commands
==========================================

Some examples of `JSONPath <https://kubernetes.io/docs/reference/kubectl/jsonpath/>`_.

.. code-block:: bash

  kubectl get pod --namespace=kube-system etcd-ripley -o=jsonpath='{range .status.containerStatuses[*]}{"image:\t"}{.image}{"\n"}{end}'