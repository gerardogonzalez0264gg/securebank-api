"""Emisión y validación de tokens JWT de acceso (HS256, vida corta)."""
from datetime import datetime, timedelta, timezone

import jwt
from flask import current_app


def issue_token(user_id: int, role: str = "user") -> str:
    settings = current_app.config["SETTINGS"]
    now = datetime.now(timezone.utc)
    claims = {
        "sub": str(user_id),
        "role": role,
        "iat": now,
        "exp": now + timedelta(minutes=settings.jwt_ttl_minutes),
    }
    return jwt.encode(claims, settings.jwt_secret, algorithm="HS256")


def decode_token(token: str) -> dict:
    settings = current_app.config["SETTINGS"]
    # algorithms fijo: evita "alg=none" y confusión de algoritmos (T06)
    return jwt.decode(
        token,
        settings.jwt_secret,
        algorithms=["HS256"],
        options={"require": ["sub", "exp"]},
    )
