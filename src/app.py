from flask import Flask

from src.config import load_settings
from src.accounts.view import bp as welcome_bp
from src.users.users import bp as users_bp
from src.transfers.calc import bp as calc_bp
from src.transfers.export import bp as export_bp


def create_app() -> Flask:
    app = Flask(__name__)
    app.config["SETTINGS"] = load_settings()  # falla si faltan secretos
    for bp in (welcome_bp, users_bp, calc_bp, export_bp):
        app.register_blueprint(bp)
    return app


app = create_app()
