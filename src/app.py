from flask import Flask, jsonify

from src.config import load_settings
from src.accounts.view import bp as welcome_bp
from src.users.users import bp as users_bp
from src.transfers.calc import bp as calc_bp
from src.transfers.export import bp as export_bp

# Cabeceras de seguridad (hallazgos típicos de ZAP Baseline: A05 Misconfiguration)
SECURITY_HEADERS = {
    "Content-Security-Policy": "default-src 'none'; frame-ancestors 'none'",
    "X-Frame-Options": "DENY",
    "X-Content-Type-Options": "nosniff",
    "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
    "Referrer-Policy": "no-referrer",
    "Cache-Control": "no-store",
}


def create_app() -> Flask:
    app = Flask(__name__)
    app.config["SETTINGS"] = load_settings()  # falla si faltan secretos
    for bp in (welcome_bp, users_bp, calc_bp, export_bp):
        app.register_blueprint(bp)

    @app.get("/health")
    def health():
        return jsonify({"status": "ok"})

    @app.after_request
    def add_security_headers(response):
        for name, value in SECURITY_HEADERS.items():
            response.headers.setdefault(name, value)
        return response

    return app


app = create_app()
