"""API1:2023 BOLA — Alice (id=100) no puede leer a Bob (id=101).

Estos tests son el criterio de verificación del plan de mitigación
(Sesión 8): `GET /users/<otro_id>` debe responder 403.
"""
import secrets
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))


@pytest.fixture()
def client(tmp_path, monkeypatch):
    monkeypatch.setenv("JWT_SECRET", secrets.token_urlsafe(48))
    monkeypatch.setenv("DATABASE_URL", "sqlite:///test.db")

    from lab.dast.seed import seed
    import src.users.users as users_module
    from src.app import create_app

    db = str(tmp_path / "test.db")
    monkeypatch.setattr(users_module, "DB_PATH", db)
    pw_alice, pw_bob = secrets.token_urlsafe(12), secrets.token_urlsafe(12)
    seed(db, pw_alice, pw_bob)

    app = create_app()
    test_client = app.test_client()
    test_client.alice_pw = pw_alice
    return test_client


def _token(client, username, password):
    resp = client.post("/login", data={"username": username, "password": password})
    assert resp.status_code == 200
    return resp.get_json()["access_token"]


def _get(client, path, token=None):
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    return client.get(path, headers=headers)


def test_sin_token_401(client):
    assert _get(client, "/users/100").status_code == 401


def test_token_invalido_401(client):
    assert _get(client, "/users/100", "no.es.un.jwt").status_code == 401


def test_alice_lee_su_propio_usuario(client):
    token = _token(client, "alice", client.alice_pw)
    resp = _get(client, "/users/100", token)
    assert resp.status_code == 200
    assert resp.get_json()["username"] == "alice"


def test_alice_no_puede_leer_a_bob_403(client):
    token = _token(client, "alice", client.alice_pw)
    resp = _get(client, "/users/101", token)
    assert resp.status_code == 403
    assert "balance" not in resp.get_json()


def test_enumeracion_de_ids_siempre_403(client):
    token = _token(client, "alice", client.alice_pw)
    for other in (1, 99, 101, 102, 103):
        assert _get(client, f"/users/{other}", token).status_code == 403


def test_headers_de_seguridad_presentes(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    for header in ("Content-Security-Policy", "X-Frame-Options",
                   "Strict-Transport-Security", "X-Content-Type-Options"):
        assert header in resp.headers
