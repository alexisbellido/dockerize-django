#!/bin/bash

# Activate virtual environment
source /root/.venv/django/bin/activate

export HOSTNAME=`cat /etc/hostname`

# Django variables from Dockerfile and/or docker run:
# PROJECT_NAME, PORT, SETTINGS_MODULE
# POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, POSTGRES_HOST, POSTGRES_PORT

export PROJECTDIR=/root/$PROJECT_NAME
export DJANGO_SETTINGS_MODULE=$PROJECT_NAME.settings.$SETTINGS_MODULE

#  replace to use variables used by postgres Docker image

export PROJECT_DATABASES_ENGINE=postgresql
export PROJECT_DATABASES_DEFAULT_NAME=$POSTGRES_DB
export PROJECT_DATABASES_DEFAULT_USER=$POSTGRES_USER
export PROJECT_DATABASES_DEFAULT_PASSWORD=$POSTGRES_PASSWORD

export PROJECT_DATABASES_DEFAULT_HOST=$POSTGRES_HOST
export PROJECT_DATABASES_DEFAULT_PORT=$POSTGRES_PORT

export PROJECT_RUNNING_DEV=true

export PROJECT_REDIS_HOST=$REDIS_HOST
export PROJECT_REDIS_PORT=$REDIS_PORT

cd $PROJECTDIR

# Editable Python packages have to be installed later
# because the volume is not accessible when running Dockerfile.
# This is a way to check and install editable requirements only if not already installed.

# python -c 'import znbcache'
# if [ $? -eq 1 ]; then
# 	pip install --requirement /tmp/editable-requirements.txt
# fi

# See Dockerfile's CMD to see parameter passed as default

if [ "$1" == "development" ]; then
	exec gosu root django-admin runserver --pythonpath=$(pwd) 0.0.0.0:$PORT

elif [ "$1" == "production" ]; then
	export PROJECT_RUNNING_DEV=false
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

	exec gosu root gunicorn --workers=$NUM_WORKERS --user=$USER --group=$GROUP --bind $BIND_HOST:$BIND_PORT --log-level=$LOGLEVEL --log-file=$LOGFILE 2>>$LOGFILE $PROJECT_NAME.wsgi:application

elif [ "$1" == "update_index" ]; then
	django-admin.py update_index --age=$2 --pythonpath=$(pwd)

elif [ "$1" == "shell" ]; then
	django-admin.py shell --pythonpath=$(pwd)

elif [ "$1" == "setenv" ]; then
	# Nothing done here, the source at the top is enough to activate the virtual
	# environment
	echo "==================================="
	echo "Done! The environment variables have been set to run the $PROJECT_NAME project."
	echo "==================================="

elif [ "$1" == "pip-install" ]; then
	# Loop over list of packages in a file and pip -e install them
	if [ -z "$2" ]
		then
    	echo "Provide a file with list of packages to install. Follow pip's requirements format."
		else
			for package in `cat $2`
			do
				if [ -d "$package" ]; then
					echo "Processing $package"
					pip install $package
				fi
			done
		fi

elif [ "$1" == "collectstatic-all" ]; then
	echo "==================================="
	echo "Django collect static files including admin files"
	echo "==================================="
	django-admin.py collectstatic --pythonpath=$(pwd) --noinput

elif [ "$1" == "collectstatic" ]; then
	echo "==================================="
	echo "Django collect static files"
	echo "==================================="
	django-admin.py collectstatic --pythonpath=$(pwd) --noinput --ignore admin*

else
	exec "$@"

fi
