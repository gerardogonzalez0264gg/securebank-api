"""Pruebas del consolidador: scanners -> findings.json (entrada del Security Gate)."""
import json

import consolidate_findings as cf


def _write(path, data):
    path.write_text(json.dumps(data), encoding="utf-8")
    return str(path)


def test_gitleaks_cuenta_resultados():
    doc = {"runs": [{"results": [{"ruleId": "a"}, {"ruleId": "b"}]}]}
    assert cf.parse_gitleaks(doc) == {"count": 2}
    assert cf.parse_gitleaks({"runs": [{"results": []}]}) == {"count": 0}


def test_sarif_sast_usa_security_severity_si_existe():
    doc = {"runs": [{"tool": {"driver": {"rules": [
        {"properties": {"security-severity": "9.8"}},
        {"properties": {"security-severity": "7.5"}},
        {"properties": {"security-severity": "5.0"}},
        {"properties": {"security-severity": "2.0"}},
    ]}}, "results": [{"ruleIndex": 0}, {"ruleIndex": 1}, {"ruleIndex": 2}, {"ruleIndex": 3}]}]}
    assert cf.parse_sarif_sast(doc) == {"critical": 1, "high": 1, "medium": 1, "low": 1}


def test_sarif_sast_sin_score_usa_level():
    doc = {"runs": [{"tool": {"driver": {"rules": [{"defaultConfiguration": {"level": "note"}}]}},
                     "results": [{"level": "error"}, {"level": "warning"}, {"ruleIndex": 0}]}]}
    assert cf.parse_sarif_sast(doc) == {"critical": 0, "high": 1, "medium": 1, "low": 1}


def test_sarif_limpio_da_ceros():
    assert cf.parse_sarif_sast({"runs": [{"tool": {"driver": {"rules": []}}, "results": []}]}) == cf.empty_counts()


def test_trivy_cuenta_unicos_y_marca_kev():
    doc = {"Results": [
        {"Vulnerabilities": [
            {"VulnerabilityID": "CVE-1", "PkgName": "flask", "Severity": "HIGH"},
            {"VulnerabilityID": "CVE-1", "PkgName": "flask", "Severity": "HIGH"},  # duplicado
            {"VulnerabilityID": "CVE-2", "PkgName": "bcrypt", "Severity": "MEDIUM"},
            {"VulnerabilityID": "CVE-3", "PkgName": "gunicorn", "Severity": "CRITICAL"},
        ]},
        {"Vulnerabilities": None},
    ]}
    counts, kev = cf.parse_trivy(doc, kev_ids=frozenset({"CVE-2"}))
    assert counts == {"critical": 1, "high": 1, "medium": 1, "low": 0}
    assert kev == [{"id": "CVE-2", "package": "bcrypt", "severity": "MEDIUM"}]


def test_zap_mapea_riskcode_e_ignora_informativos():
    doc = {"site": [{"alerts": [
        {"riskcode": "3"}, {"riskcode": "2"}, {"riskcode": "2"}, {"riskcode": "1"}, {"riskcode": "0"},
    ]}]}
    assert cf.parse_zap(doc) == {"critical": 0, "high": 1, "medium": 2, "low": 1}


def test_coverage_y_catalogo_kev():
    assert cf.parse_coverage({"totals": {"percent_covered": 83.456}}) == {"percent": 83.46}
    assert cf.parse_kev_catalog({"vulnerabilities": [{"cveID": "CVE-9"}, {"x": 1}]}) == frozenset({"CVE-9"})


def test_main_consolida_todo(tmp_path):
    out = tmp_path / "findings.json"
    argv = [
        "--gitleaks", _write(tmp_path / "g.sarif", {"runs": [{"results": []}]}),
        "--sast", _write(tmp_path / "s.sarif", {"runs": [{"tool": {"driver": {"rules": []}}, "results": []}]}),
        "--sca", _write(tmp_path / "t.json", {"Results": []}),
        "--dast", _write(tmp_path / "z.json", {"site": []}),
        "--coverage", _write(tmp_path / "c.json", {"totals": {"percent_covered": 90}}),
        "--context", _write(tmp_path / "ctx.json", {"_comment": "x", "exposure_level": "internet"}),
        "--commit", "abc", "--branch", "main", "--build", "7", "-o", str(out),
    ]
    assert cf.main(argv) == 0
    data = json.loads(out.read_text(encoding="utf-8"))
    assert data["meta"]["commit"] == "abc" and data["meta"]["build"] == "7"
    assert data["secrets"] == {"count": 0}
    assert data["coverage"] == {"percent": 90.0}
    assert data["context"] == {"exposure_level": "internet"}  # _comment filtrado
    assert data["kev"] == []


def test_reporte_faltante_omite_la_seccion_para_fallar_cerrado(tmp_path, capsys):
    out = tmp_path / "findings.json"
    cf.main(["--sast", str(tmp_path / "no-existe.sarif"),
             "--dast", _write(tmp_path / "z.json", {"site": []}), "-o", str(out)])
    data = json.loads(out.read_text(encoding="utf-8"))
    assert "sast" not in data and "secrets" not in data  # la política los bloqueará
    assert "dast" in data
    assert "no se pudo leer" in capsys.readouterr().err


def test_reporte_corrupto_no_se_asume_limpio(tmp_path):
    bad = tmp_path / "bad.json"
    bad.write_text("{no es json", encoding="utf-8")
    out = tmp_path / "findings.json"
    cf.main(["--sca", str(bad), "-o", str(out)])
    assert "sca" not in json.loads(out.read_text(encoding="utf-8"))


def test_formato_inesperado_no_rompe_y_omite(tmp_path):
    out = tmp_path / "findings.json"
    cf.main(["--coverage", _write(tmp_path / "c.json", {"sin": "totals"}), "-o", str(out)])
    assert "coverage" not in json.loads(out.read_text(encoding="utf-8"))
