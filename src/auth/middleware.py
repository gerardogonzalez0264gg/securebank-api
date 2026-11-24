"""Middleware de autenticación y autorización a nivel de objeto (BOLA).

Autenticación = ¿quién eres?  ->  require_auth
Autorización  = ¿puedes tocar ESTE recurso?  ->  require_owner
El chequeo de ownership vive en un solo lugar y no se repite por handler.
"""
import logging
from functools import wraps

import jwt
from flask import g, jsonify, request

from src.auth.tokens import decode_token

audit = logging.getLogger("securebank.audit")


def require_auth(view):
    @wraps(view)
    def wrapper(*args, **kwargs):
        header = request.headers.get("Authorization", "")
        scheme, _, token = header.partition(" ")
        if scheme.lower() != "bearer" or not token:
            return jsonify({"error": "unauthorized"}), 401
        try:
            g.claims = decode_token(token)
        except jwt.InvalidTokenError:
            return jsonify({"error": "unauthorized"}), 401
        return view(*args, **kwargs)

    return wrapper


def require_owner(param: str = "user_id"):
    """El sub del token debe ser dueño del recurso (o rol admin)."""

    def decorator(view):
        @wraps(view)
        @require_auth
        def wrapper(*args, **kwargs):
            is_admin = g.claims.get("role") == "admin"
            if str(kwargs[param]) != g.claims["sub"] and not is_admin:
                # audit log: patrón de enumeración de IDs ajenos
                audit.warning(
                    "bola_attempt sub=%s requested=%s path=%s ip=%s",
                    g.claims["sub"], kwargs[param], request.path, request.remote_addr,
                )
                return jsonify({"error": "forbidden"}), 403
            return view(*args, **kwargs)

        return wrapper

    return decorator
