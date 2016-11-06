#! /bin/bash
set -e

source /root/.venv/zinibu/bin/activate
pip install --requirement /tmp/editable-requirements.txt
django-admin runserver --settings=zinibu.settings.locals3 --pythonpath=$(pwd)
