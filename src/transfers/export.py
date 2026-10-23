import os
import subprocess
from flask import Blueprint, request, abort

bp = Blueprint("export", __name__)
REPORTS_DIR = "reports"


@bp.route("/export")
def export_report():
    filename = os.path.basename(request.args["f"])
    if not filename:
        abort(400)
    result = subprocess.run(
        ["cat", os.path.join(REPORTS_DIR, filename)],
        capture_output=True,
        check=True,
    )
    return result.stdout
