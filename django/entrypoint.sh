#! /bin/bash
set -e

source /root/.venv/zinibu/bin/activate
cd /root/zinibu
django-admin runserver --settings=zinibu.settings --pythonpath=$(pwd)
