#!/bin/bash
set -e

source /env/bin/activate

export HOSTNAME=`cat /etc/hostname`
export PROJECT_DIR=/root/$PROJECT_NAME

# To run django-admin without passing --pythonpath and --settings
export PYTHONPATH=$PROJECT_DIR
export DJANGO_SETTINGS_MODULE=$PROJECT_NAME.settings
# TODO do I still need different settings per environment?
#export DJANGO_SETTINGS_MODULE=$PROJECT_NAME.settings.$SETTINGS_MODULE

cd $PROJECT_DIR

if [ "$1" == "production" ]; then
	export USER=root
	export GROUP=root
	export NUM_WORKERS=3
	export BIND_HOST=$HOSTNAME
	export BIND_PORT=$PORT
	export LOGFILE=/var/log/$PROJECT_NAME.log
	if [ "$2" == "--log-level=debug" ]; then
		export LOGLEVEL=debug
	elif [ "$2" == "--log-level=critical" ]; then
		export LOGLEVEL=critical
	else
		export LOGLEVEL=info
	fi
	# exec gosu root gunicorn --workers=$NUM_WORKERS --user=$USER --group=$GROUP --bind $BIND_HOST:$BIND_PORT --log-level=$LOGLEVEL --log-file=$LOGFILE 2>>$LOGFILE $PROJECT_NAME.wsgi:application
	exec gunicorn --workers=$NUM_WORKERS --user=$USER --group=$GROUP --bind $BIND_HOST:$BIND_PORT --log-level=$LOGLEVEL --log-file=$LOGFILE 2>>$LOGFILE $PROJECT_NAME.wsgi:application
elif [ "$1" == "development" ]; then
	exec django-admin runserver 0.0.0.0:$PORT
else
	exec "$@"
fi