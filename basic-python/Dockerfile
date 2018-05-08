FROM python:3.6.5-slim-stretch as builder
WORKDIR /root

RUN set -e \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    git-core \
  && rm -rf /var/lib/apt/lists/*

ARG SSH_PRIVATE_KEY
RUN mkdir -p /root/.ssh/ \
  && echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa \
  && chmod 600 /root/.ssh/id_rsa \
  && echo "StrictHostKeyChecking no " > /root/.ssh/config

# Private repositories can be cloned now. The following will work.
# pip install -e git://git.example.com/MyProject#egg=MyProject

# temporal
#RUN set -e \
#  && git clone https://github.com/cooperhewitt/py-cooperhewitt-swatchbook

#COPY requirements.txt /root/requirements.txt
#
#RUN python -m venv /env \
#  && . /env/bin/activate \
#  && pip install --upgrade pip \
#  && pip install --no-cache-dir -r requirements.txt

FROM python:3.6.5-slim-stretch
LABEL maintainer="Alexis Bellido <a@zinibu.com>"
WORKDIR /root

COPY --from=builder /env /env
COPY --from=builder /root/py-cooperhewitt-swatchbook /root/py-cooperhewitt-swatchbook
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# will install git manually inside container to test ssh key

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
