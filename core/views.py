from django.http import HttpResponse

def hello(request):
    return HttpResponse("Hola. es la prueba de Deploy usando Jenkins. 👋")