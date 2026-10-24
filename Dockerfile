# Imagen base pequeña
FROM python:3.12-slim

WORKDIR /app

# Primero las dependencias (aprovecha la caché de capas)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Luego el código
COPY app.py .

# No correr como root (buena práctica de seguridad)
USER 1000

EXPOSE 8000
CMD ["python", "app.py"]