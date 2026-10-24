import os
from flask import Flask, jsonify

app = Flask(__name__)

# Variable de entorno que usaremos para simular errores en Kubernetes (Fase 7)
APP_ENV = os.environ.get("APP_ENV", "dev")


@app.route("/")
def inicio():
    return jsonify(mensaje="Hola desde el laboratorio DevOps de Sergio", ambiente=APP_ENV)


@app.route("/health")
def health():
    # Endpoint de salud: lo usan las probes de Kubernetes y los monitoreos
    return jsonify(estado="ok"), 200


def sumar(a, b):
    return a + b


if __name__ == "__main__":
    # Por defecto solo local (seguro). El contenedor define HOST=0.0.0.0
    host = os.environ.get("HOST", "127.0.0.1")
    app.run(host=host, port=8000)
