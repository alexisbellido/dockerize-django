FROM python:3.5.2-slim

COPY requirements.txt /tmp/
COPY entrypoint.sh /root/

RUN apt-get -y update && apt-get install -y curl
RUN /usr/local/bin/pyvenv /root/.venv/zinibu
RUN . /root/.venv/zinibu/bin/activate \
  && curl https://bootstrap.pypa.io/get-pip.py | python \
  && pip install --upgrade pip \
  && pip install --requirement /tmp/requirements.txt


# use VOLUME somewhere to copy the django project, which should be created with django-admin startproject zinibu
# and then we set that as work dir

WORKDIR /root/zinibu
EXPOSE 8000

# use a bash script with exec form, see https://github.com/evonove/docker-library/blob/master/python/Dockerfile
# review CMD to accept parameters from docker run

# Set the default command to run when starting the container
#RUN chmod a+x /root/entrypoint.sh
#CMD ls -l
#ENTRYPOINT ["/root/entrypoint.sh"]
