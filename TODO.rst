TODO
==================================================

try replicaset for mysql with volume and then with persistent volume claim to keep database after pod restart. Try PostgreSQL when MySQL done.

create pod just for django gnuicorn image, volume mapping to make sure it starts and when ready add nginx in front to same Pod

create pod with two containers and use kubectl exec to access each of the containers using -c (container) option

verify nginx and gunicorn in same pod are started correctly because there's no depends_on for k8s or just use readiness probe for each container in pod? there is no built-in dependency management equivalent to depends_on available. In general, we assume loosely coupled services and as a good practice there should be no hard dependency in terms of start-up order, but retries and timeouts should be used.

see `<https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/>`_ to install single-instance deployment with MySQL. For Django replace with PostgreSQL.

try recreating museum yaml with k8s and config.yaml and django project mounted

use kubernetes/test-project/museum-dev-pod-vol.yaml
delete kubernetes/test-project/museum-development.yml once ported to k8s

Passing arguments to container using imperative commands, see `<https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run>`_.

kubectl run museum --image=alexisbellido/museum:2.1 development
kubectl get deployments
kubectl get pod
kubectl describe pod museum-58cc44bb69-t2j52 
kubectl logs -f museum-58cc44bb69-t2j52 

File "<frozen importlib._bootstrap>", line 219, in _call_with_frames_removed
File "/root/project/project/settings.py", line 19, in <module>
  with open('/run/secrets/config.yaml', 'r') as f:
FileNotFoundError: [Errno 2] No such file or directory: '/run/secrets/config.yaml'

Yes, I think I should use a pod for nginx+gunicorn

Move final k8s config to museum project when done

namespace or labels for test, staging and production?

Use k8s Service type ExternalName for database with Django so that for local development I run PostgreSQL from a container (or should I run one independent pod behind the service?) but production runs something like AWS RDS. A similar approach may work for Elasticsearch and Redis.

k8s persistent volume to run database for local development. A singleton instance as a pod.

===========

branch in progress: master

add node to local kubernetes

==
verify nginx 1.15.0 works with command: production from app service, see note in basic-django.yml
==

modify Django project to use /run/secrets/config.yaml and copy generic result to config.yaml.orig, which is the version kept in repo

set up compose file to use production command for django docker-entrypoint.sh

redis

Docker images need to be in public registry or built locally for this to work so far. See how to use images from private registry.

Explore how K8s to use secrets similar to Docker's.

Never embed configuration or secrets into a Docker image. Instead, when building a Docker image, expect that any required runtime configuration and secrets will be supplied to the container using the orchestration runtime (Kubernetes Secrets, Docker Secrets), or, for for non-sensitive data, environment variables (docker compose) or configmaps (k8s). Sane configuration defaults are okay. Be careful to not include secrets in hidden layers of an image. Running a Docker container in production should be the assembly of an image with various configuration and secrets. It doesn’t matter if you are running this container in Docker, Kubernetes, Swarm or another orchestration layer, the orchestration platform should be responsible for creating containers by assembling these parts into a running container.


bash until when using Docker Compose to wait for PostgreSQL? See Django cookiecutter

logging from development and production to STDOUT and STDERR or to file in container
https://docs.djangoproject.com/en/2.0/topics/logging/
do I need to use docker logging drivers?

Django Dockerfile # TODO do I still different settings per environment? ENV SETTINGS_MODULE local

set up private GitHub to test token

the goal with secrets is not to put the private information in a pod definition or docker image
should I use secrets for SSH keys with docker compose or keep multi-stage build approach?
k8s: allow a pod to access a git repository using SSH keys

maybe don't use base.py approach (see repo ventanazul.com:git/zinibu-project.git) and just work with env vars in one settings.py


https://docs.djangoproject.com/en/dev/internals/contributing/writing-code/coding-style/
https://pypi.org/project/flake8/
.editorconfig

k8s uses configmaps for configuration files, port numbers, environment variables and other non-sensitive data. What's equivalent for Docker compose?

Test redis and add to README for Django
To use Redis pass REDIS_HOST and, for the sake of being implicit, REDIS_PORT, with the same development server:

.. code-block:: bash

  $ docker run -d --network=project_network -w /root -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v $SSH_AUTH_SOCK:/run/ssh_agent -e SSH_AUTH_SOCK=/run/ssh_agent -v "$PWD"/django-project:/root/django-project -v "$PWD"/django-apps:/root/django-apps --env PROJECT_NAME=django-project --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=dbserver1 --env REDIS_HOST=redis1 --env REDIS_PORT=6379 -p 33332:8000 --name=app1-dev alexisbellido/django:1.11 development


==
Docket secrets

$ docker swarm init
Swarm initialized: current node (rf4ca83cwjohnbwvkd8qyhkqk) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-0nqr5pgghlfm8y8zmnt340pkk1ydkxwsnrdb7jncpslp81s4pg-6zkkg1qri8q0jmhrmp61krpnp 192.168.1.183:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

$ docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-0nqr5pgghlfm8y8zmnt340pkk1ydkxwsnrdb7jncpslp81s4pg-dajk360m447hklyaskaksy5x9 192.168.1.183:2377

==

PostgreSQL basics.

try web container in front of development and production app container to see if /static served with /admin

include a basic Django app from private git repo in image
include a basic Django app from private repo as editable

Use bind mounting for development too

learn about docker volumes for AWS and K8s

Do I use hostname for compose? what's different hostname and name?

At some point push basics to Docker Hub

50x and 40x pages for Django, see Nginx config
check nginx access log for health check of static and dynamic, or just dynamic from some app and forget static?

Use different setting files or environment variables with Docker Compose or K8s to use different environments.

varnish

local ssl and self-signed certificate

haproxy

Keep everything generic and when needed move to private Git repositories and Docker registry.

Make it easy to pass configuration variables. Should I continue with multiple settings approach in Django or do something via orchestration?

Use multi-stage builds and everything, including project code, should be in Docker images. Think about assest. Maybe different file system or volume.

Start with Docker compose and then make it portable to ECS and K8S.

Docker containers can connect to MySQL container exposing port 3306 and running on another host by using that other host's IP (192.168.1.5 in this example).

.. code-block:: bash

  $ docker run -it --rm mysql:5.7.17 /bin/bash
  root@b9516d51b37f:/# mysql -u root -h 192.168.1.5 collection

Standard Django setup will use PostgreSQL but later for custom application try multidatabase to write to second MySQL legacy database. Use Django's raw queries to write to legacy database.

PostgreSQL JSONb

===

I'll continue here once I've explored the basics with the `Ansible and Docker project <https://github.com/alexisbellido/ansible-and-docker/>`_.

I'm going to finish the basic docker-compose flow without Ansible and leave it as an option of this project and then I'm going to decide if I make it all work with Ansible Container or if I just use a little Ansible to run hosts and start containers inside.

I may not need to do anything from the container with bash scripts, or maybe don't need Dockerfile when using Ansible container with Docker. See https://thenewstack.io/ansible-container-playbooks-sole-build-management-tool/ ("Dockerfiles are basically shell script. And one of the reasons we wrote Ansible in the first place is that shell script gets pretty ugly pretty fast. Ansible is the main definition language that goes into the containers themselves.").

Ansible to create directory structure and other basics on host. May no longer bee needed with ECS or Kubernetes.

update docker-compose (use version 3?) specific to local development and use variations of app server to use local, s3, etc. the new composer should use a shorter name to create easier own network and try to use Django project and replace djapps with django-apps and with relative paths (https://docs.docker.com/compose/compose-file/#volumes). Once done and test Django project is running, merge into master and continue with next steps.

use symlinks for nginx to get static files directly from webpack's directory without using collectstatic, maybe include something in Django's settings files to make it  easier.
check django-zinibu-main.git to see how webpack.config.js can build files in Django directories.
static produced by webpack is in /home/alexis/mydocker/djapps/django-zinibu-main/znbmain/static
inspect nginx container to see what directory should be symlinked, or maybe change zinibu.settings.local right from Django to use a different static dir
the webpack setup already accepts a parameter to sent built files to a static directory in the Django project, see django-zinibu-main
docker inspect web2 | less

make sure image alexisbellido/django:1.11 works and push it to Docker Hub before getting to compose

update compose to use app2-local with
    image: "alexisbellido/django:1.11"

server should be removed from the load balancer before it’s upgraded

document instructions for launching the stack with docker composer (it's just docker-compose up -d from directory compose-complete)

continue with other containers from docker compose

make haproxy work without ssl first and with ssl later. I have an haproxy directory, map to either or haproxy.cfg or haproxy-ssl.cfg with the rest of the stack, If using haproxy-ssl.cfg map the ssl cert
do not use a second frontend from varnish servers, instead pass from each varnish to its own nginx

If using SSL:
for local dev with haproxy and use haproxy to terminate ssl and redirect non-www, non-https to https://www.
for AWS use ELB to terminate SSL and use varnish to redirect non-www, non-https to https://www.

Dockerfile has to create dir for ssl

for elb or no haproxy try this for varnish:

====
#change backend to this, so each varnish points to its own webhead

backend bk_appsrv_static_znblb1 {
  #.host = "172.31.63.150";
  .host = "znbweb2";
  #.port = "80";
  .port = "81";
  .probe = {
    #.url = "/haproxycheck";
    .url = "/app-check/";
    .expected_response = 200;
    .timeout = 1s;
    .interval = 3s;
    .window = 2;
    .threshold = 2;
    .initial = 2;
  }
}


# disable to test elb
#    # unless Django's sessionid or message cookies are in the request, don't pass ANY cookies (referral_source, utm, etc)
#    # also, anything inside /media or /static should be cached
#    if (req.url ~ "^/media" || req.url ~ "^/static" || (req.http.Cookie !~ "logged_in" && req.http.Cookie !~ "sessionid" && req.http.Cookie !~ "messages" && req.http.Cookie !~ "csrftoken")) {
#      unset req.http.Cookie;
#      return (hash);
#    }
# end disable to test elb

# enable to test elb
    if (req.url ~ "^/media" || req.url ~ "^/static") {
      unset req.http.Cookie;
      return (hash);
    }

    if (req.http.Cookie ~ "logged_in") {
      return (pass);
    }
# end enable to test elb

====

and keep the static and media apart; it "should" work
and then I need an external LB going to varnish servers and internal LB to go from each varnish to the app servers

move db to postgresql (uses postgres user?)

uses upstream in nginx conf for proxy_pass server, see: http://scottwb.com/blog/2013/10/28/always-on-https-with-nginx-behind-an-elb/ and http://nginx.org/en/docs/http/ngx_http_upstream_module.html

for gunicorn see tcp example of http://docs.gunicorn.org/en/stable/deploy.html

the rewrite from non-www and non-https is being done by varnish

if not using s3, create local static and media directories inside project (better just use s3)
docker compose
back to add varnish
haproxy
docker compose
logrotate

Latest docker run:

add redis support to django image

use docker compose to automate the initial complete setup and then see how to add more containers to running setup

==

make applications from django/editable-requirements.txt available in PyPi and document that they can be kept editable during development

==

dumping postgresql and running django commands with docker

docker exec -it db2 psql -h db2 -U user2 -d db2
docker exec -it db2 pg_dump -Fc -v -h db2 -U user2 db2 > db2-$(date +"%m%d%Y-%H%M%S").dump
docker exec -it db2 "pg_dump -Fc -v -h db2 -U user2 db2 > db2-$(date +"%m%d%Y-%H%M%S").dump"
docker exec -it db2 pg_dump -Fc -v -h db2 -U user2 -W db2 > db2-$(date +"%m%d%Y-%H%M%S").dump
docker exec -it db2 /bin/bash
docker cp db2:/tmp/db2-* .
docker cp db2:/tmp/db2-03042017-215219.dump .
cd mydocker/
docker ps
cd mydocker/
cd dockerize-django/
docker ps
docker inspect app2-dev | less
docker exec -it app2-dev docker-entrypoint.sh shell

update elasticsearch (24 hours * 300 days with $(()) bash calculation)
docker exec -it app2-dev docker-entrypoint.sh update_index $((24*360))
