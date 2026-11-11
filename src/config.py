"""Configuración de SecureBank API.

Regla: ningún secreto vive en el código. Todo se lee desde variables de
entorno (inyectadas por GitHub Secrets / Vault) y la app no arranca si falta
alguno o si es débil.
"""
import os
from dataclasses import dataclass, field

_PLACEHOLDERS = {"replace_me", "changeme", "password", "secret", "admin"}
_MIN_JWT_SECRET_LEN = 32


class ConfigError(RuntimeError):
    """Configuración ausente o insegura."""


def _required(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise ConfigError(f"Falta la variable de entorno obligatoria: {name}")
    if value.lower() in _PLACEHOLDERS:
        raise ConfigError(f"{name} contiene un valor de ejemplo; usa un secreto real")
    return value


@dataclass(frozen=True)
class Settings:
    # repr=False: los secretos nunca se imprimen en logs ni trazas
    database_url: str = field(repr=False)
    jwt_secret: str = field(repr=False)
    jwt_ttl_minutes: int = 15  # tokens de vida corta


def load_settings() -> Settings:
    jwt_secret = _required("JWT_SECRET")
    if len(jwt_secret) < _MIN_JWT_SECRET_LEN:
        raise ConfigError(
            f"JWT_SECRET debe tener al menos {_MIN_JWT_SECRET_LEN} caracteres"
        )
    ttl = int(os.environ.get("JWT_TTL_MINUTES", "15"))
    if not 1 <= ttl <= 60:
        raise ConfigError("JWT_TTL_MINUTES debe estar entre 1 y 60")
    return Settings(
        database_url=_required("DATABASE_URL"),
        jwt_secret=jwt_secret,
        jwt_ttl_minutes=ttl,
    )
