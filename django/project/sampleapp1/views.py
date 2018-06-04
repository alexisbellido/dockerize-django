from datetime import datetime
import socket

from django.http import HttpResponse

from sampleapp2.views import text


def index(request):
    print("print to console at {0}".format(str(datetime.now())))
    return HttpResponse("<h1>Hello, world. A view from sampleapp1</h1><p>Text from sampleapp2: {text}</p><p> Hostname: {hostname}</p>".format(
        text = text,
        hostname = socket.gethostname()
    ))
