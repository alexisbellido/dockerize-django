TODO
==================================================

configure Django local settings without S3 for Docker setup

use symlinks for nginx to get static files directly from webpack's directory without using collectstatic, maybe include something in Django's settings files to make it  easier.

update composer (use version 3?) specific to local development and use variations of app server to use local, s3, etc. the new composer should use a shorter name to create easier own network and try to use Django project and djapps with relative paths (https://docs.docker.com/compose/compose-file/#volumes)

make sure image alexisbellido/django:1.11 works and push it to Docker Hub before getting to compose

update compose to use app2-local with 
    image: "alexisbellido/django:1.11"

Why this error:
root@app2-local $ source /usr/local/bin/docker-entrypoint.sh setenv
root@app2-local $ django-admin.py help --pythonpath=$(pwd)
Note that only Django core commands are listed as settings are not properly configured (error: Set the PROJECT_RUNNING_DEV environment variable).


ansible talks to docker, investigate

server is removed from the load balancer before it’s upgraded

test setuptools stuff to put apps inside django project or separate dirs from other repos, with ansible?

Find a way to install project-specific Python packages on the virtual environment inside the container. Ansible?

merge feature/django1.11 into master when I have a basic django 1.11 project running

document instructions for launching the stack with docker composer (it's just docker-compose up -d from directory compose-complete)

continue with other containers from docker compose

should I automate the docker run commands with just bash or some salt? maybe they are not that many commands and manual and some composer will be enough

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
