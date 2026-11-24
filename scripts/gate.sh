#!/usr/bin/env bash
# Security Gate: evalúa policy/security-policy-v1.rego sobre findings.json con OPA.
#   scripts/gate.sh [findings.json] [gate-result.json]
# Exit code: 0 = DEPLOY · 1 = BLOCK (el job de CI falla) · 2 = error de ejecución
set -euo pipefail

FINDINGS="${1:-findings.json}"
RESULT="${2:-gate-result.json}"
POLICY_DIR="$(cd "$(dirname "$0")/../policy" && pwd)"

command -v opa >/dev/null || { echo "opa no está instalado" >&2; exit 2; }
command -v jq  >/dev/null || { echo "jq no está instalado" >&2; exit 2; }

# Las pruebas de la política deben pasar antes de usarla para decidir
opa test "$POLICY_DIR" >/dev/null || { echo "Las pruebas de la política fallan (opa test)" >&2; exit 2; }

opa eval -d "$POLICY_DIR/security-policy-v1.rego" -i "$FINDINGS" \
  --format json 'data.securepipeline.gate.result' \
  | jq '.result[0].expressions[0].value' > "$RESULT"

DECISION="$(jq -r '.decision // "BLOCK"' "$RESULT")"

{
  echo "## Security Gate · ${DECISION}"
  echo
  echo "Política v$(jq -r '.policy_version' "$RESULT") · commit \`$(jq -r '.meta.commit // "n/a"' "$RESULT")\` · build $(jq -r '.meta.build // "n/a"' "$RESULT")"
  echo
  if [ "$DECISION" = "BLOCK" ]; then
    echo "| Regla violada |"
    echo "|---|"
    jq -r '.deny[] | "| " + . + " |"' "$RESULT"
  else
    echo "Todas las reglas se cumplen."
  fi
} | tee -a "${GITHUB_STEP_SUMMARY:-/dev/null}"

[ "$DECISION" = "DEPLOY" ]
