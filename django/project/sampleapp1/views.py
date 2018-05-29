from datetime import datetime

from django.http import HttpResponse

from sampleapp2.views import text


def index(request):
    print("print to console at {0}".format(str(datetime.now())))
    return HttpResponse("Hello, world. A view from sampleapp1. Text from sampleapp2: {text}.".format(
        text = text
    ))
