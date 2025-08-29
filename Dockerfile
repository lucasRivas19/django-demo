FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    APP_HOME=/app

WORKDIR $APP_HOME

RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat-traditional \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# puerto por defecto de gunicorn
EXPOSE 5050

# espera a que la DB esté (si usás sqlite no hace falta, lo dejamos igual)
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:5050", "--workers", "2"]
