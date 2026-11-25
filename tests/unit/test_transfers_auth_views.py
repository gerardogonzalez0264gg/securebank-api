"""Pruebas unitarias de calc, export, auth, accounts y config."""
import subprocess

import pytest

from src.app import create_app
from src.auth.auth import hash_password, verify_password
from src.config import ConfigError, load_settings


@pytest.fixture()
def client():
    return create_app().test_client()


# ── transfers/calc ──
def test_rate_calcula_expresion_valida(client):
    resp = client.post("/rate", data={"expression": "(1 + 2) * 4 / 2"})
    assert resp.status_code == 200 and resp.get_json()["result"] == 6


@pytest.mark.parametrize("expr", ["__import__('os').system('id')", "1 +", "1 / 0", "2 ** 8"])
def test_rate_rechaza_expresiones_peligrosas_o_invalidas(client, expr):
    assert client.post("/rate", data={"expression": expr}).status_code == 400


# ── transfers/export ──
def test_export_rechaza_nombres_fuera_de_la_lista_blanca(client):
    assert client.get("/export?f=../../etc/passwd").status_code == 400


def test_export_nombre_valido_usa_lista_blanca(client, monkeypatch):
    calls = []

    def fake_run(cmd, **kwargs):
        calls.append((cmd, kwargs))
        return subprocess.CompletedProcess(cmd, 0, stdout=b"ok")

    monkeypatch.setattr("src.transfers.export.subprocess.run", fake_run)
    resp = client.get("/export?f=daily")
    assert resp.status_code == 200 and resp.data == b"ok"
    assert calls[0][0] == ["cat", "reports/daily.txt"] and calls[0][1]["shell"] is False


# ── auth ──
def test_hash_y_verificacion_de_password():
    stored = hash_password("una-clave-de-prueba")
    assert verify_password("una-clave-de-prueba", stored)
    assert not verify_password("otra", stored)


def test_verify_password_con_hash_invalido_devuelve_false():
    assert verify_password("x", "no-es-un-hash-bcrypt") is False


# ── accounts ──
def test_welcome_escapa_html(client):
    body = client.get("/welcome?name=<script>alert(1)</script>").get_data(as_text=True)
    assert "<script>" not in body and "&lt;script&gt;" in body


# ── config ──
def test_config_falla_si_falta_secreto(monkeypatch):
    monkeypatch.delenv("JWT_SECRET", raising=False)
    with pytest.raises(ConfigError):
        load_settings()


def test_config_rechaza_secreto_corto_y_placeholder(monkeypatch):
    monkeypatch.setenv("JWT_SECRET", "corto")
    with pytest.raises(ConfigError):
        load_settings()
    monkeypatch.setenv("JWT_SECRET", "changeme")
    with pytest.raises(ConfigError):
        load_settings()


def test_config_rechaza_ttl_fuera_de_rango(monkeypatch):
    monkeypatch.setenv("JWT_TTL_MINUTES", "999")
    with pytest.raises(ConfigError):
        load_settings()
