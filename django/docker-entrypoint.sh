#! /bin/bash
set -e

source /root/.venv/zinibu/bin/activate
pip install --requirement /tmp/editable-requirements.txt

if [ "$1" = 'runserver' ]; then
	exec gosu root django-admin runserver --settings=zinibu.settings.locals3 --pythonpath=$(pwd) 0.0.0.0:8000
fi

exec "$@"
