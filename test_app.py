from app import app, sumar


def test_sumar():
    assert sumar(2, 3) == 5


def test_health():
    cliente = app.test_client()
    respuesta = cliente.get("/health")
    assert respuesta.status_code == 200
    assert respuesta.get_json()["estado"] == "ok"
