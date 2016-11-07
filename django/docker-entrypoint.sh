#! /bin/bash
set -e

source /root/.venv/project/bin/activate

# Install editable applications from mounted volume if required
python -c 'import znbcache' 
if [ $? -eq 1 ]; then
	pip install --requirement /tmp/editable-requirements.txt
fi

# TODO accept arguments from from docker run using CMD in Dockerfile
# TODO use it to indicate settings file and other options

if [ "$1" = 'runserver' ]; then
	exec gosu root django-admin runserver --settings=zinibu.settings.locals3 --pythonpath=$(pwd) 0.0.0.0:8000
fi

exec "$@"
