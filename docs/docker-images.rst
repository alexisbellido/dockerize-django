Managing Docker Images
======================================================================

You can give an image a new tag and then remove the old tag using docker rmi. It won't remove the image as long as it's associated to other tag.

.. code-block:: bash

  $ docker tag <old_name> <new_name>
  $ docker rmi <old_name>

Use hash from Git
------------------------------------------

One approach to tagging images is by adding the latest hash from git to the version, included as [HASH] in examples below.

You can use either the large or short versions.

.. code-block:: bash

  $ git log -1 --pretty=%H
  $ git log -1 --pretty=%h
  $ echo $(git log -1 --pretty=%H)
  
.. code-block:: bash

  $ docker tag organization/project:1.2.[HASH] XXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/organization/project:1.2.[HASH]

Here the version of the project is 1.2 and we add the hash via bash command substitution. If using a script we could use an environment variable.

.. code-block:: bash

  $ docker tag organization/project:1.2.$(git log -1 --pretty=%H) XXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/organization/project:1.2.$(git log -1 --pretty=%H)


.. code-block:: bash

  $ docker build -t XXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/organization/project:1.2.[HASH] .
  $ docker push XXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/organization/project:1.2.[HASH]

Use dates
------------------------------------------

For example, adding -YYYYMMDD to the version. Example shows manual approach as well as bash command substitution.

.. code-block:: bash

  $ docker tag organization/project:1.2-20181003 XXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/organization/project:1.2-20181003
  $ docker tag organization/project:1.2-$(date +%Y%m%d) XXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/organization/project:1.2-$(date +%Y%m%d)

