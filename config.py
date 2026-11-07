import os

# Configuracion leida desde variables de entorno (nunca escrita en el codigo).
# Si falta la base de datos, la app arranca igual y /db responde 503.
DB_HOST = os.environ.get("DB_HOST")
DB_PORT = int(os.environ.get("DB_PORT", "5432"))
DB_NAME = os.environ.get("DB_NAME", "labdevops")
DB_USER = os.environ.get("DB_USER")
DB_PASSWORD = os.environ.get("DB_PASSWORD")

BEDROCK_REGION = os.environ.get("BEDROCK_REGION", "us-east-1")
BEDROCK_MODEL_ID = os.environ.get("BEDROCK_MODEL_ID", "us.amazon.nova-micro-v1:0")


def db_configurada():
    return all([DB_HOST, DB_USER, DB_PASSWORD])
