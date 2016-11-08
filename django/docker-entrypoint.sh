#! /bin/bash

# Activate virtual environment
source /root/.venv/django/bin/activate

# Variables from Dockerfile: PROJECT_NAME, PORT, SETTINGS_MODULE
export PROJECTDIR=/root/$PROJECT_NAME
export DJANGO_SETTINGS_MODULE=$PROJECT_NAME.settings.$SETTINGS_MODULE

cd $PROJECTDIR

# Install editable applications from mounted volume if required
python -c 'import znbcache' 
if [ $? -eq 1 ]; then
	pip install --requirement /tmp/editable-requirements.txt
fi

if [ "$1" == "development" ]; then
	export PROJECT_RUNNING_DEV=true
	exec gosu root django-admin runserver --pythonpath=$(pwd) 0.0.0.0:$PORT
elif [ "$1" == "production" ]; then
	export PROJECT_RUNNING_DEV=false
	export USER=root
    	export GROUP=root
	export NUM_WORKERS=3
	export BIND_HOST=`cat /etc/hostname`
	export BIND_PORT=$PORT
	export LOGFILE=/var/log/$PROJECT_NAME.log

	if [ "$2" == "--log-level=debug" ]; then
		export LOGLEVEL=debug
	elif [ "$2" == "--log-level=critical" ]; then
		export LOGLEVEL=critical
	else
		export LOGLEVEL=info
	fi

	exec gosu root gunicorn --workers=$NUM_WORKERS --user=$USER --group=$GROUP --bind $BIND_HOST:$BIND_PORT --log-level=$LOGLEVEL --log-file=$LOGFILE 2>>$LOGFILE $PROJECT_NAME.wsgi:application

elif [ "$1" == "update_index" ]; then
	django-admin.py update_index --age=$2 --pythonpath=$(pwd)

elif [ "$1" == "shell" ]; then
	django-admin.py shell --pythonpath=$(pwd)

elif [ "$1" == "setenv" ]; then
	echo "==================================="
	echo "Done! The environment variables have been set to run the $PROJECT_NAME project."
	echo "==================================="

elif [ "$1" == "collectstatic" ]; then
	echo "==================================="
	echo "Django collect static files"
	echo "==================================="
	django-admin.py collectstatic --pythonpath=$(pwd) --noinput

else
	exec "$@"

fi
