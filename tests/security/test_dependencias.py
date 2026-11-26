"""S6 · Prueba de dependencias sin CVE conocidos (comentada a propósito).

Necesita `pip-audit` instalado y acceso a PyPI/OSV, por eso no corre en la suite normal.
Para activarla: instalar `pip-audit==2.10.1` y descomentar el código.
Evidencia actual en reports/securebank-vulns.json (PyJWT 2.10.1 → 2.15.0, 17 → 0 CVE).
"""
# import json
# import subprocess
# from pathlib import Path
#
# ROOT = Path(__file__).resolve().parents[2]
#
#
# def test_requirements_sin_vulnerabilidades_conocidas():
#     out = subprocess.run(
#         ["pip-audit", "-r", str(ROOT / "requirements.txt"), "-f", "json"],
#         shell=False, capture_output=True, text=True,
#     )
#     deps = json.loads(out.stdout)["dependencies"]
#     vulns = [(d["name"], v["id"]) for d in deps for v in d.get("vulns", [])]
#     assert vulns == [], f"Dependencias con CVE: {vulns}"
#
#
# def test_pyjwt_en_version_corregida():
#     req = (ROOT / "requirements.txt").read_text()
#     assert "PyJWT==2.15.0" in req
