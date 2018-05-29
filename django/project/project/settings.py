"""
Django settings for project project.

Generated by 'django-admin startproject' using Django 2.0.5.

For more information on this file, see
https://docs.djangoproject.com/en/2.0/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/2.0/ref/settings/
"""

import os

# Normally you should not import ANYTHING from Django directly
# into your settings, but ImproperlyConfigured is an exception.
from django.core.exceptions import ImproperlyConfigured
def get_env_variable(var_name):
    """Get the environment variable or return exception."""
    try:
        return os.environ[var_name]
    except KeyError:
        error_msg = "Set the {} environment variable".format(var_name)
        raise ImproperlyConfigured(error_msg)

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/2.0/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '_zej7#h!p3cxcg*+*#v7pk-$n@d#u+vy4*9cjnc#(gm49&=x)$'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = []

# << test production
# DEBUG = False
# ALLOWED_HOSTS = ['*']
# test production >>


# Application definition

INSTALLED_APPS = [
    'sampleapp1.apps.Sampleapp1Config',
    'sampleapp2.apps.Sampleapp2Config',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'project.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'project.wsgi.application'


# Database
# https://docs.djangoproject.com/en/2.0/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}

# TODO logging to docker logs
import logging
import sys

# LOGGING = {
#   'version': 1,
#   'disable_existing_loggers': False,
#   'formatters': {
#       'verbose': {
#           'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
#       },
#   },
#   'handlers': {
#       'console': {
#           'level': 'INFO',
#           'class': 'logging.FileHandler',
#           'filename': '/var/log/debug.log',
#           'formatter': 'verbose'
#       },
#   },
#   'loggers': {
#       '': {
#           'handlers': ['console'],
#           'level': 'INFO',
#       }
#   },
# }

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
        'basic': {
            'format': '%(name)s %(levelname)s %(asctime)s %(message)s'
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'basic'
        },
        'stream': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
            'stream': sys.stdout
        },
    },
    'loggers': {
        'project': {
            'handlers': ['stream', 'console'],
            'level': 'DEBUG',
        },
    }
}
# END LOGGING CONFIGURATION

# logger = logging.getLogger(__name__)
# import pprint
# logger.info(pprint.pformat(vars(object)))

# logger = logging.getLogger('project')
# logger.info('miau 222...')
# logger.debug('miau 123...')

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': get_env_variable('PROJECT_DATABASES_DEFAULT_NAME'),
        'USER': get_env_variable('PROJECT_DATABASES_DEFAULT_USER'),
        'PASSWORD': get_env_variable('PROJECT_DATABASES_DEFAULT_PASSWORD'),
        'HOST': get_env_variable('PROJECT_DATABASES_DEFAULT_HOST'),
        'PORT': get_env_variable('PROJECT_DATABASES_DEFAULT_PORT'),
    }
}

# Password validation
# https://docs.djangoproject.com/en/2.0/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/2.0/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'America/New_York'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/2.0/howto/static-files/

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')