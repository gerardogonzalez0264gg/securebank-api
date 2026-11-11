from flask import Blueprint, request, render_template

bp = Blueprint("welcome", __name__, template_folder="templates")


@bp.route("/welcome")
def welcome():
    name = request.args.get("name", "")
    return render_template("welcome.html", name=name)
