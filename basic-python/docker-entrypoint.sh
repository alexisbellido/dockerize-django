#!/bin/bash

# Activate virtual environment and expands positional parameters
source /root/.venv/app/bin/activate
exec "$@"
