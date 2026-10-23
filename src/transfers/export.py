import subprocess
from flask import Blueprint, request

bp = Blueprint("export", __name__)


@bp.route("/export")
def export_report():
    filename = request.args["f"]
    output = subprocess.check_output("cat reports/" + filename, shell=True)
    return output