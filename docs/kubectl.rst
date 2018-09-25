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
  kubectl get deployments nginx -o jsonpath --template={.spec.selector.matchLabels} && echo

Note the extra echo in the last example is used to add a line break.

To create a deployment in imperative way use kubectl run. If you don't want to create a deployment and just a pod pass --restart=Never. See `this StackOverflow question <https://stackoverflow.com/questions/45279572/how-to-start-a-pod-in-command-line-without-deployment-in-kubernetes?rq=1>`_.

.. code-block:: bash

  kubectl run nginx --image=nginx:1.7.12
  kubectl run httpd --image=httpd:2.4 --port=80 --restart=Never  

.. code-block:: bash

  kubectl label pods POD color=red
  kubectl label pods POD --overwrite color=green
  kubectl label pods POD color-

  kubectl	run	alpaca-prod --image=gcr.io/kuar-demo/kuard-amd64:1 --replicas=2 --labels="ver=1,app=alpaca,env=prod"
  kubectl	run	alpaca-test	--image=gcr.io/kuar-demo/kuard-amd64:2 --replicas=1 --labels="ver=2,app=alpaca,env=test"
  kubectl	run	bandicoot-prod --image=gcr.io/kuar-demo/kuard-amd64:2 --replicas=2 --labels="ver=2,app=bandicoot,env=prod"
  kubectl	run	bandicoot-staging	--image=gcr.io/kuar-demo/kuard-amd64:2 --replicas=1 --labels="ver=2,app=bandicoot,env=staging"
  kubectl get deployments --show-labels -L env,ver

Run a pod with just one container from a MySQL image to use the mysql client and connect to existing MySQL service in that cluster. Note --restart=Never sets a restart policy the creates a pod. The default, Always, would create a deployment. Also note --rm to remove the pod after it exits.

.. code-block:: bash

  kubectl run -it --image=mysql:5.7.17 --restart=Never --env="MYSQL_ROOT_PASSWORD=secret" mysql-client -- mysql -u root -psecret -h NAME-OF-EXISTING-MYSQL-SERVICE-IN-CLUSTER

Deployment
--------------------------------------------------------------------------------

`Each application should run from one deployment <https://stackoverflow.com/questions/43217006/kubernetes-multi-pod-deployment>`_.

Execute in container
--------------------------------------------------------------------------------

.. code-block:: bash

  kubectl exec -it POD -- sh
  kubectl exec -it POD -- cat /tmp/some-file