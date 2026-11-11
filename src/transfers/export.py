import subprocess
from flask import Blueprint, request, abort

bp = Blueprint("export", __name__)

REPORTS = {
    "daily": "reports/daily.txt",
    "monthly": "reports/monthly.txt",
}


@bp.route("/export")
def export_report():
    name = request.args.get("f", "")
    if name not in REPORTS:
        abort(400)
    result = subprocess.run(
        ["cat", REPORTS[name]], shell=False, capture_output=True, check=True
    )
    return result.stdout
