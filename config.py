import os

# Configuración leída desde variables de entorno (nunca escrita en el código)
DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_USER = os.environ.get("DB_USER", "citaya_app")
DB_PASSWORD = os.environ["DB_PASSWORD"]
