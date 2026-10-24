# Laboratorio DevOps

App mínima en Python (Flask) para practicar CI/CD, DevSecOps y Kubernetes con herramientas gratuitas.

- `GET /` responde un saludo y el ambiente.
- `GET /health` responde el estado de salud.

## Correr localmente
```bash
pip install -r requirements.txt
pytest -v
python app.py
```
