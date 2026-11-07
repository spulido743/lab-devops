import app as modulo
from app import app, sumar


def test_sumar():
    assert sumar(2, 3) == 5


def test_health():
    respuesta = app.test_client().get("/health")
    assert respuesta.status_code == 200
    assert respuesta.get_json()["estado"] == "ok"


def test_ready_sin_db_configurada():
    respuesta = app.test_client().get("/ready")
    assert respuesta.status_code == 200
    assert respuesta.get_json()["db"] == "no-configurada"


def test_db_sin_configurar_responde_503():
    respuesta = app.test_client().get("/db")
    assert respuesta.status_code == 503


class BedrockFalso:
    def converse(self, **kwargs):
        assert kwargs["messages"][0]["content"][0]["text"] == "hola"
        return {
            "output": {"message": {"content": [{"text": "respuesta simulada"}]}},
            "usage": {"inputTokens": 1, "outputTokens": 2},
        }


def test_ai_con_bedrock_simulado(monkeypatch):
    monkeypatch.setattr(modulo, "cliente_bedrock", lambda: BedrockFalso())
    respuesta = app.test_client().get("/ai?q=hola")
    assert respuesta.status_code == 200
    assert respuesta.get_json()["respuesta"] == "respuesta simulada"
