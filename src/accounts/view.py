from flask import Blueprint, request, render_template_string

bp = Blueprint("welcome", __name__)


@bp.route("/welcome")
def welcome():
    name = request.args.get("name", "")
    return render_template_string(f"<h1>Hola {name}</h1>")