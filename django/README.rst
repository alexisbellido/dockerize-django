Container for Django project
==========================================


My Docker Hub user is *alexisbellido* and I'm calling my network *zinibu*:

Create a bridge network for your containers on your host.

  ``docker network create -d bridge zinibu``

Build the image from this directory:

  ``docker build -t alexisbellido/python:v5 .``

Run the container passing parameters.

For Django development server:
  ``docker run -itd --network=zinibu -v /home/alexis/mydocker/zinibu:/root/zinibu -v /home/alexis/mydocker/djapps:/root/djapps --env PROJECT_NAME=zinibu --env PORT=8000 --env SETTINGS_MODULE=locals3 -P --hostname=app8 --name=app8 alexisbellido/python:v9 development``

For Django via gunicorn (specifying how to map the port on the host):
  ``docker run -itd --network=zinibu -v /home/alexis/mydocker/zinibu:/root/zinibu -v /home/alexis/mydocker/djapps:/root/djapps --env PROJECT_NAME=zinibu --env PORT=8000 --env SETTINGS_MODULE=locals3 -p 192.168.1.202:33001:8000 --hostname=app9 --name=app9 alexisbellido/python:v9 production``

Note the environment variables:
SETTINGS_MODULE, used for DJANGO_SETTINGS_MODULE
PROJECT_NAME, the name of your project
PORT

==

Latest docker run:

docker run -itd --network=zinibu -v /home/alexis/mydocker/zinibu:/root/zinibu -v /home/alexis/mydocker/djapps:/root/djapps --env PROJECT_NAME=zinibu --env PORT=8000 --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=app1 -P --hostname=app1 --name=app1 alexisbellido/python:v11

docker run -d --network=zinibu --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --hostname=db1 --name=db1 postgres:9.4
