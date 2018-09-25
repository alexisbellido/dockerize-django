Docker and MySQL
==========================================================

Execute mysql client inside a running container. Note environment variables to use full width.

.. code-block:: bash

  docker exec -i -e COLUMNS="`tput cols`" -e LINES="`tput lines`" CONTAINER mysql -u root -h 192.168.1.183


Docker way of running a container to use its MySQL client. It could connect to other host.

.. code-block:: bash
  docker run -it --rm mysql:5.5.60 mysql -u root -h 192.168.1.183

Confirm a host has a port open. In this example, for MySQL.

.. code-block:: bash

  nc -vz 192.168.1.5 3306
  
Kubernetes way to connect to MySQL on a different host by creating a pod to run the MySQL client and deleting the pod on exit.

.. code-block:: bash

  kubectl run -it --rm --image=mysql:5.7.17 --restart=Never mysql-client -- mysql -u root -h 192.168.1.5
  
Connect to MySQL service in cluster. The IP to connect is the exposed Cluster IP.

.. code-block:: bash

  kubectl run -it --rm --image=mysql:5.7.17 --restart=Never mysql-client -- mysql -u root -h 10.108.154.73 -psecret

Connect to service with no selector, which required an endpoint to indicate IP and port. Note how the host (-h) uses a K8s service name. See service-with-no-selector.yaml.

.. code-block:: bash

  kubectl run -it --rm --image=mysql:5.7.17 --restart=Never mysql-client -- mysql -u root -p -h external-mysql-ip

See `<https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/>`_.
