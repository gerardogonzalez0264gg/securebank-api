# SecurePipeline · Security Policy v1.0
# Proyecto: SecureBank API · Fecha: 2026-11-23
#
# Entrada: findings.json consolidado (scripts/consolidate_findings.py).
# Salida:  data.securepipeline.gate.result  ->  {allow, deny[], limits, metrics, meta}
# Justificación de cada umbral: policy/README.md
package securepipeline.gate

import rego.v1

policy_version := "1.0"

default allow := false

allow if count(deny) == 0

# ───────────────────────── Umbrales base ─────────────────────────
max_secrets := 0 # Tolerancia cero (Secret Scan)

max_critical := 0 # Tolerancia cero en codigo propio (SAST + DAST)

max_first_party_high := 0 # High en codigo propio (SAST + DAST): lo corregimos nosotros

# SCA Critical: tolerancia cero sin compensating controls; con ellos se acepta deuda acotada
max_sca_critical := 0 if not has_compensating_controls

max_sca_critical := 3 if has_compensating_controls

min_coverage := 80 # % de líneas de src/ cubiertas por tests

# ───────────────── Criterios de riesgo (diapositiva 14) ─────────────────
# Contexto, exposición y compensating controls vienen de config/security-context.json.
# Falla cerrada: si el contexto no llega, se asume el escenario más estricto.
exposure := object.get(input, ["context", "exposure_level"], "internet")

criticality := object.get(input, ["context", "business_criticality"], "critical")

mitigations := object.get(input, ["context", "mitigations"], [])

required_mitigations := {"waf", "rate_limiting"}

exposed if exposure == "internet"

business_critical if criticality in {"high", "critical"}

strict_context if {
	exposed
	business_critical
}

# Siempre definido (true/false): se imprime en los mensajes de bloqueo
missing_mitigations := required_mitigations - {m | some m in mitigations}

has_compensating_controls := count(missing_mitigations) == 0

# High en dependencias (SCA): deuda acotada, mas estricta si el activo es critico y publico
sca_high_base := 2 if strict_context

sca_high_base := 4 if not strict_context

compensating_bonus := 4 if has_compensating_controls

compensating_bonus := 0 if not has_compensating_controls

max_sca_high := sca_high_base + compensating_bonus

# Medium agregados: más tolerancia si no hay exposición a Internet
max_medium := 10 if exposed

max_medium := 15 if not exposed

# ───────────────────────── Falla cerrada ─────────────────────────
required_scanners := {"secrets", "sast", "sca", "dast", "coverage"}

missing_scanners contains s if {
	some s in required_scanners
	not input[s]
}

deny contains msg if {
	some s in missing_scanners
	msg := sprintf("%s: el scanner no reportó resultados (falla cerrada)", [s])
}

# ───────────────────────── Reglas de bloqueo ─────────────────────────
deny contains msg if {
	input.secrets.count > max_secrets
	msg := sprintf("Secrets = %d (máximo %d)", [input.secrets.count, max_secrets])
}

deny contains msg if {
	some s in {"sast", "dast"}
	input[s].critical > max_critical
	msg := sprintf("%s Critical = %d (maximo %d; codigo propio, tolerancia cero)", [upper(s), input[s].critical, max_critical])
}

deny contains msg if {
	input.sca.critical > max_sca_critical
	msg := sprintf("SCA Critical = %d (maximo %d; compensating controls=%v)", [input.sca.critical, max_sca_critical, has_compensating_controls])
}

deny contains msg if {
	some s in {"sast", "dast"}
	input[s].high > max_first_party_high
	msg := sprintf("%s High = %d (máximo %d en código propio)", [upper(s), input[s].high, max_first_party_high])
}

deny contains msg if {
	input.sca.high > max_sca_high
	msg := sprintf(
		"SCA High = %d (máximo %d; exposición=%s, criticidad=%s, compensating controls=%v)",
		[input.sca.high, max_sca_high, exposure, criticality, has_compensating_controls],
	)
}

deny contains msg if {
	total_medium > max_medium
	msg := sprintf("Medium total = %d (máximo %d; exposición=%s)", [total_medium, max_medium, exposure])
}

deny contains msg if {
	input.coverage.percent < min_coverage
	msg := sprintf("Coverage = %.1f%% (mínimo %d%%)", [input.coverage.percent, min_coverage])
}

# Exploitability real: un CVE en el catálogo KEV de CISA bloquea sin importar la severidad
deny contains msg if {
	count(kev_ids) > 0
	msg := sprintf("CVE explotado activamente (CISA KEV): %s", [concat(", ", sort(kev_ids))])
}

kev_ids contains id if {
	some f in object.get(input, "kev", [])
	id := f.id
}

total_medium := sum([input[s].medium | some s in {"sast", "sca", "dast"}; input[s].medium])

# ───────────────────────── Evidencia auditable ─────────────────────────
result := {
	"policy_version": policy_version,
	"allow": allow,
	"decision": decision,
	"deny": sort(deny),
	"limits": {
		"max_secrets": max_secrets,
		"max_critical": max_critical,
		"max_first_party_high": max_first_party_high,
		"max_sca_high": max_sca_high,
		"max_medium": max_medium,
		"min_coverage": min_coverage,
	},
	"risk_context": {
		"business_criticality": criticality,
		"exposure_level": exposure,
		"mitigations": mitigations,
	},
	"meta": object.get(input, "meta", {}),
}

decision := "DEPLOY" if allow

decision := "BLOCK" if not allow
