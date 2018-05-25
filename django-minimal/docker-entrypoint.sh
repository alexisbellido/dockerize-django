#!/bin/bash
set -e

source /env/bin/activate

export PROJECT_DIR=/root/$PROJECT_NAME
export DJANGO_SETTINGS_MODULE=$PROJECT_NAME.settings.$SETTINGS_MODULE

cd $PROJECT_DIR

echo $1
echo $2

# exec django-admin runserver --pythonpath=$(pwd) 0.0.0.0:$PORT
exec "$@"
