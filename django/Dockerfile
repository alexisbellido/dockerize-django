FROM python:3.5.2-slim

COPY requirements.txt /tmp/
COPY entrypoint.sh /root/

# Install requisites for building Python packages
RUN apt-get -y update \
  && apt-get install -y curl \
  && apt-get install -y python3-dev \
  && apt-get install -y postgresql-client-9.4 \
  && apt-get install -y libpq-dev \
  && apt-get install -y python3-setuptools \
  && apt-get install -y libjpeg62-turbo-dev \
  && apt-get install -y libopenjpeg-dev \
  && apt-get install -y libfreetype6-dev \
  && apt-get install -y libtiff5-dev \
  && apt-get install -y liblcms2-dev \
  && apt-get install -y libwebp-dev \
  && apt-get install -y tk8.6-dev \
  && apt-get install -y python3-tk

RUN /usr/local/bin/pyvenv /root/.venv/zinibu

RUN . /root/.venv/zinibu/bin/activate \
  && curl https://bootstrap.pypa.io/get-pip.py | python \
  && pip install --upgrade pip \
  && pip install --requirement /tmp/requirements.txt

WORKDIR /root/project
EXPOSE 8000

# use a bash script with exec form, see https://github.com/evonove/docker-library/blob/master/python/Dockerfile
# review CMD to accept parameters from docker run

# Set the default command to run when starting the container
#RUN chmod a+x /root/entrypoint.sh
#CMD ls -l
#ENTRYPOINT ["/root/entrypoint.sh"]
