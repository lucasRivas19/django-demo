from django.http import HttpResponse

def hello(request):
    return HttpResponse("Hi!!. Estoy de prueba de Deploy usando Jenkins Waven. 👋")