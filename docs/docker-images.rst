Managing Docker Images
======================================================================

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

Here the version of the project is 1.2 and we add the hash including the git log command. This could be scripted too.

.. code-block:: bash

  $ docker tag organization/project:1.2.$(git log -1 --pretty=%H) XXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/organization/project:1.2.$(git log -1 --pretty=%H)


.. code-block:: bash

  $ docker build -t XXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/organization/project:1.2.[HASH] .
  $ docker push XXXXXXXXXX.dkr.ecr.us-east-1.amazonaws.com/organization/project:1.2.[HASH]


