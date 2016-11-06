Container for Django project
==========================================


My Docker Hub user is *alexisbellido* and I'm calling my network *zinibu*:

Create a bridge network for your containers on your host.

  ``docker network create -d bridge zinibu``

Build the image from this directory:

  ``docker build -t alexisbellido/python:v5 .``

Run a container from the image:

  ``docker run -itd --network=zinibu -v /home/alexis/mydocker/project:/root/project -v /home/alexis/mydocker/djapps:/root/djapps --hostname=app1 -p 192.168.1.202:33001:8000 --name=app1 alexisbellido/python:v5``
