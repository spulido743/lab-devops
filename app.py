import logging
import os

import boto3
import psycopg
from botocore.exceptions import BotoCoreError, ClientError
from flask import Flask, jsonify, request

import config

app = Flask(__name__)
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("lab-devops")

# Variable de entorno que usaremos para simular errores en Kubernetes
APP_ENV = os.environ.get("APP_ENV", "dev")


def conectar_db():
    # RDS PostgreSQL 15+ exige TLS por defecto: sslmode=require
    return psycopg.connect(
        host=config.DB_HOST,
        port=config.DB_PORT,
        dbname=config.DB_NAME,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
        sslmode="require",
        connect_timeout=3,
    )


def cliente_bedrock():
    # boto3 busca credenciales en su cadena: Pod Identity, IRSA, variables, aws login...
    return boto3.client("bedrock-runtime", region_name=config.BEDROCK_REGION)


@app.route("/")
def inicio():
    return jsonify(mensaje="Hola desde el laboratorio DevOps de Sergio", ambiente=APP_ENV)


@app.route("/health")
def health():
    # Liveness: el proceso esta vivo. No depende de nada externo.
    return jsonify(estado="ok"), 200


@app.route("/ready")
def ready():
    # Readiness: puedo atender trafico. Si la base esta configurada y no responde, 503.
    if not config.db_configurada():
        return jsonify(estado="ok", db="no-configurada"), 200
    try:
        with conectar_db() as conn:
            conn.execute("SELECT 1")
        return jsonify(estado="ok", db="ok"), 200
    except psycopg.Error as e:
        log.warning("readiness: base de datos no disponible: %s", e.__class__.__name__)
        return jsonify(estado="no-listo", db=e.__class__.__name__), 503


@app.route("/db")
def db():
    if not config.db_configurada():
        return jsonify(error="base de datos no configurada"), 503
    try:
        with conectar_db() as conn:
            conn.execute(
                "CREATE TABLE IF NOT EXISTS visitas ("
                "id SERIAL PRIMARY KEY, ambiente TEXT NOT NULL, "
                "creada TIMESTAMPTZ NOT NULL DEFAULT now())"
            )
            conn.execute("INSERT INTO visitas (ambiente) VALUES (%s)", (APP_ENV,))
            total = conn.execute("SELECT count(*) FROM visitas").fetchone()[0]
        return jsonify(visitas=total, ambiente=APP_ENV), 200
    except psycopg.Error as e:
        log.error("db: %s: %s", e.__class__.__name__, e)
        return jsonify(error=e.__class__.__name__), 503


@app.route("/ai")
def ai():
    pregunta = request.args.get("q", "Explica en una frase que es Kubernetes.")[:500]
    try:
        respuesta = cliente_bedrock().converse(
            modelId=config.BEDROCK_MODEL_ID,
            messages=[{"role": "user", "content": [{"text": pregunta}]}],
            inferenceConfig={"maxTokens": 200, "temperature": 0.3},
        )
        texto = respuesta["output"]["message"]["content"][0]["text"]
        return jsonify(modelo=config.BEDROCK_MODEL_ID, respuesta=texto, tokens=respuesta.get("usage", {})), 200
    except ClientError as e:
        codigo = e.response["Error"]["Code"]
        log.error("ai: %s", codigo)
        return jsonify(error=codigo), 502
    except BotoCoreError as e:
        log.error("ai: %s", e.__class__.__name__)
        return jsonify(error=e.__class__.__name__), 502


def sumar(a, b):
    return a + b


if __name__ == "__main__":
    # Solo para desarrollo local. En el contenedor corre gunicorn.
    app.run(host=os.environ.get("HOST", "127.0.0.1"), port=8000)
