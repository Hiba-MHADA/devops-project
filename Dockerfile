# Dockerfile
FROM python:3.11-slim

LABEL maintainer='ton-email@example.com'
LABEL version='1.0.0'

# Utilisateur non-root (sécurité)
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copier requirements en premier (cache Docker)
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code
COPY app/ .

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

CMD ["python", "app.py"]
