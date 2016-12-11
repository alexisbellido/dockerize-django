make haproxy work without ssl first and with ssl later. I have an haproxy directory, map to either or haproxy.cfg or haproxy-ssl.cfg with the rest of the stack, If using haproxy-ssl.cfg map the ssl cert
do not use a second frontend from varnish servers, instead pass from each varnish to its own nginx

Dockerfile has to create dir for ssl

pass my haproxy conf files using volume mapping:
docker run -d --name my-running-haproxy -v /path/to/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:1.5

pass my nginx conf files using volume mapping:
docker run --name some-nginx -v /some/nginx.conf:/etc/nginx/nginx.conf:ro -d nginx

I have a varnish directory, varnish contains the defaults for the daemon, default.vcl is the original used for haproxy and default.vcl.2 works with elb


I have stopped zinibu, nginx and varnish on znbweb2 and modified varnish's default.vcl for znbweb1 with what's below (original in znbweb1:~/backup)

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

add nginx using my own default.conf, create my image to accept paramater for default.conf to connect to gunicorn instance on same host
uses upstream in nginx conf for proxy_pass server, see: http://scottwb.com/blog/2013/10/28/always-on-https-with-nginx-behind-an-elb/ and http://nginx.org/en/docs/http/ngx_http_upstream_module.html
for gunicorn see tcp example of http://docs.gunicorn.org/en/stable/deploy.html
the rewrite should be:
rewrite ^ http://example.com$request_uri? permanent; # see https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/#taxing-rewrites

# investigate: add Strict-Transport-Security to server block in nginx to prevent man in the middle attacks
add_header Strict-Transport-Security "max-age=31536000"; 
# Add HTTP Strict Transport Security for good measure.
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains;";

if not using s3, create local static and media directories inside project (better just use s3)
make it all work
docker compose
back to add varnish
haproxy
docker compose
logrotate

Latest docker run:

postgresql
docker run -itd --network=zinibu -v /home/alexis/mydocker/zinibu:/root/zinibu -v /home/alexis/mydocker/djapps:/root/djapps --env PROJECT_NAME=zinibu --env SETTINGS_MODULE=locals3 --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --env POSTGRES_HOST=db1 -p 33333:8000 --hostname=app1 --name=app1 alexisbellido/python:v11

access psql:

docker exec -it db1 psql -h db1 -U user1 -d db1

check mount and restore from db dump
docker inspect db1
docker exec -it db1 psql -h db1 -U user1 -d db1 -f /var/lib/postgresql/data/db1_11112016_0157.sql

nginx 
docker run --network=zinibu --name some-nginx -v /home/alexis/mydocker/zinibu/static:/usr/share/nginx/html -p 33334:80 -d nginx:1.10.2

gunicorn with django project
docker run -d --network=zinibu --env POSTGRES_USER=user1 --env POSTGRES_PASSWORD=user_secret --env POSTGRES_DB=db1 --hostname=db1 --name=db1 postgres:9.4

haproxy non-ssl:
docker run -d --network zinibu -p 35001:8998 -p 35002:80 -p 35003:443 --name lb1 -v /home/alexis/mydocker/dockerize-django/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro alexisbellido/haproxy:v2

use docker compose to automate the initial complete setup and then see how to add more containers to running setup
