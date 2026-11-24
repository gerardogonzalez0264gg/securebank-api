#!/usr/bin/env python3
"""Consolida los reportes de los 4 scanners + coverage en un único findings.json.

Es la entrada del Security Gate (policy/security-policy-v1.rego).
Solo usa la biblioteca estándar. Si un reporte falta o está corrupto, esa
sección se OMITE y la política bloquea (falla cerrada): nunca se asume "0 hallazgos".

Uso:
  python scripts/consolidate_findings.py \
      --gitleaks gitleaks.sarif --sast sast.sarif --sca sca.json \
      --dast zap-out/report.json --coverage coverage.json \
      --context config/security-context.json --kev kev.json \
      --commit "$GITHUB_SHA" --branch "$GITHUB_REF_NAME" --build "$GITHUB_RUN_NUMBER" \
      -o findings.json
"""
import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

SEVERITIES = ("critical", "high", "medium", "low")


def empty_counts() -> dict:
    return {s: 0 for s in SEVERITIES}


def load_json(path):
    """Devuelve el JSON o None si el archivo no existe / está corrupto."""
    if not path:
        return None
    try:
        return json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        print(f"[consolidate] AVISO: no se pudo leer {path}: {exc}", file=sys.stderr)
        return None


# ───────────────────────── Parsers ─────────────────────────
def _sarif_results(doc):
    return [r for run in doc.get("runs", []) for r in run.get("results", [])]


def parse_gitleaks(doc) -> dict:
    return {"count": len(_sarif_results(doc))}


def _bucket_from_score(score: float) -> str:
    # Convención GitHub para security-severity (escala CVSS)
    if score >= 9.0:
        return "critical"
    if score >= 7.0:
        return "high"
    if score >= 4.0:
        return "medium"
    return "low"


_LEVEL_TO_SEVERITY = {"error": "high", "warning": "medium", "note": "low", "none": "low"}


def parse_sarif_sast(doc) -> dict:
    counts = empty_counts()
    for run in doc.get("runs", []):
        rules = run.get("tool", {}).get("driver", {}).get("rules", [])
        for res in run.get("results", []):
            props = dict(res.get("properties", {}))
            idx = res.get("ruleIndex")
            if isinstance(idx, int) and 0 <= idx < len(rules):
                props = {**rules[idx].get("properties", {}), **props}
            raw = props.get("security-severity")
            try:
                bucket = _bucket_from_score(float(raw)) if raw is not None else None
            except (TypeError, ValueError):
                bucket = None
            if bucket is None:
                level = res.get("level")
                if not level and isinstance(idx, int) and 0 <= idx < len(rules):
                    level = rules[idx].get("defaultConfiguration", {}).get("level")
                bucket = _LEVEL_TO_SEVERITY.get(level or "warning", "medium")
            counts[bucket] += 1
    return counts


def parse_trivy(doc, kev_ids=frozenset()):
    """Cuenta vulnerabilidades únicas (CVE + paquete). Devuelve (conteos, hallazgos KEV)."""
    counts = empty_counts()
    kev_hits = []
    seen = set()
    for result in doc.get("Results", []) or []:
        for vuln in result.get("Vulnerabilities", []) or []:
            key = (vuln.get("VulnerabilityID"), vuln.get("PkgName"))
            if key in seen:
                continue
            seen.add(key)
            sev = str(vuln.get("Severity", "")).lower()
            if sev in counts:
                counts[sev] += 1
            if vuln.get("VulnerabilityID") in kev_ids:
                kev_hits.append({"id": vuln["VulnerabilityID"], "package": vuln.get("PkgName"),
                                 "severity": str(vuln.get("Severity", "")).upper()})
    return counts, kev_hits


_ZAP_RISK = {"3": "high", "2": "medium", "1": "low"}  # "0" = informational, no cuenta


def parse_zap(doc) -> dict:
    counts = empty_counts()  # ZAP no tiene nivel Critical
    for site in doc.get("site", []) or []:
        for alert in site.get("alerts", []) or []:
            bucket = _ZAP_RISK.get(str(alert.get("riskcode")))
            if bucket:
                counts[bucket] += 1
    return counts


def parse_coverage(doc) -> dict:
    return {"percent": round(float(doc["totals"]["percent_covered"]), 2)}


def parse_kev_catalog(doc) -> frozenset:
    return frozenset(v["cveID"] for v in doc.get("vulnerabilities", []) if "cveID" in v)


# ───────────────────────── Ensamblado ─────────────────────────
def consolidate(args) -> dict:
    findings = {
        "meta": {
            "commit": args.commit,
            "branch": args.branch,
            "build": args.build,
            "timestamp": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        },
        "kev": [],
    }

    context = load_json(args.context)
    if context:
        findings["context"] = {k: v for k, v in context.items() if not k.startswith("_")}

    kev_catalog = load_json(args.kev)
    kev_ids = parse_kev_catalog(kev_catalog) if kev_catalog else frozenset()
    if args.sca and not kev_catalog:
        print("[consolidate] AVISO: sin catálogo KEV; no se evalúa exploitability", file=sys.stderr)

    try:
        if (doc := load_json(args.gitleaks)) is not None:
            findings["secrets"] = parse_gitleaks(doc)
        if (doc := load_json(args.sast)) is not None:
            findings["sast"] = parse_sarif_sast(doc)
        if (doc := load_json(args.sca)) is not None:
            findings["sca"], findings["kev"] = parse_trivy(doc, kev_ids)
        if (doc := load_json(args.dast)) is not None:
            findings["dast"] = parse_zap(doc)
        if (doc := load_json(args.coverage)) is not None:
            findings["coverage"] = parse_coverage(doc)
    except (KeyError, TypeError, ValueError, AttributeError) as exc:
        print(f"[consolidate] ERROR: formato inesperado de un reporte: {exc!r}", file=sys.stderr)
    return findings


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    for name in ("gitleaks", "sast", "sca", "dast", "coverage", "context", "kev"):
        p.add_argument(f"--{name}")
    p.add_argument("--commit", default="unknown")
    p.add_argument("--branch", default="unknown")
    p.add_argument("--build", default="local")
    p.add_argument("-o", "--output", default="findings.json")
    return p


def main(argv=None) -> int:
    args = build_parser().parse_args(argv)
    findings = consolidate(args)
    Path(args.output).write_text(json.dumps(findings, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    present = [s for s in ("secrets", "sast", "sca", "dast", "coverage") if s in findings]
    print(f"[consolidate] {args.output} escrito · secciones: {', '.join(present) or 'ninguna'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
