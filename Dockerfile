# Imagen base pequeña
FROM python:3.12-slim

# Parches de seguridad del sistema operativo (Trivy bloqueó zlib1g sin parchar)
RUN apt-get update \
 && apt-get upgrade -y --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Primero las dependencias (aprovecha la caché de capas)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Luego el código
COPY app.py .

# No correr como root (buena práctica de seguridad)
USER 1000
ENV HOST=0.0.0.0
EXPOSE 8000
CMD ["python", "app.py"]
