Docker swarm mode, stack and services
==========================================================

You need to set up a swarm to use secrets even if using just one node.

$ docker swarm init

The host where you run that becomes a node that is both manager and worker by default.

$ docker stack deploy -c compose/basic-django.yml basicdjango
$ docker service ls

$ docker service logs basicdjango_app -f
$ docker service logs basicdjango_database

$ docker exec -it basicdjango_app.1.lkcqcb3eosm5bx00lxapi61l7 docker-entrypoint.sh pip freeze
$ docker exec -it basicdjango_app.1.lkcqcb3eosm5bx00lxapi61l7 docker-entrypoint.sh django-admin migrate
$ docker exec -it basicdjango_app.1.lkcqcb3eosm5bx00lxapi61l7 docker-entrypoint.sh django-admin createsuperuser

$ docker service ps basicdjango_web
$ docker service ps basicdjango_app
$ docker service ps basicdjango_database

use IP when accessing as service http://127.0.0.1:8000/, localhost host name does not work

find db container, the container ID below is just an example, and psql to it.

$ docker ps
$ docker exec -it basicdjango_database.1.i54qy0wzlcs534y02jwpgt214 psql -U user1 -d db1

when running as service the volumes are created using the service name
$ docker volume ls
DRIVER              VOLUME NAME
local               basicdjango_database
local               basicdjango_media
local               basicdjango_static
