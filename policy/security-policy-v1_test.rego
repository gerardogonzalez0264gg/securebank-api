# Tests de la política: opa test policy/ -v
package securepipeline.gate_test

import rego.v1

import data.securepipeline.gate

clean := {
	"meta": {"commit": "abc1234", "branch": "main"},
	"context": {"business_criticality": "critical", "exposure_level": "internet", "mitigations": []},
	"secrets": {"count": 0},
	"sast": {"critical": 0, "high": 0, "medium": 0, "low": 2},
	"sca": {"critical": 0, "high": 1, "medium": 3, "low": 5},
	"dast": {"critical": 0, "high": 0, "medium": 2, "low": 4},
	"coverage": {"percent": 85.0},
	"kev": [],
}

# ── Caso que PASA ──
test_build_limpio_despliega if {
	gate.allow with input as clean
	gate.result.decision == "DEPLOY" with input as clean
}

# ── Casos que BLOQUEAN (uno por regla) ──
test_secreto_bloquea if {
	i := object.union(clean, {"secrets": {"count": 1}})
	not gate.allow with input as i
	"Secrets = 1 (máximo 0)" in gate.deny with input as i
}

test_critical_en_sast_bloquea if {
	i := object.union(clean, {"sast": {"critical": 1, "high": 0, "medium": 0, "low": 0}})
	not gate.allow with input as i
	"SAST Critical = 1 (máximo 0)" in gate.deny with input as i
}

test_critical_en_sca_bloquea if {
	i := object.union(clean, {"sca": {"critical": 1, "high": 0, "medium": 0, "low": 0}})
	"SCA Critical = 1 (máximo 0)" in gate.deny with input as i
}

test_high_en_codigo_propio_bloquea if {
	i := object.union(clean, {"dast": {"critical": 0, "high": 1, "medium": 0, "low": 0}})
	"DAST High = 1 (máximo 0 en código propio)" in gate.deny with input as i
}

test_sca_high_sobre_limite_bloquea if {
	i := object.union(clean, {"sca": {"critical": 0, "high": 2, "medium": 0, "low": 0}})
	not gate.allow with input as i
}

test_medium_sobre_limite_bloquea if {
	i := object.union(clean, {"sast": {"critical": 0, "high": 0, "medium": 11, "low": 0}})
	not gate.allow with input as i
}

test_coverage_bajo_bloquea if {
	i := object.union(clean, {"coverage": {"percent": 79.9}})
	not gate.allow with input as i
	"Coverage = 79.9% (mínimo 80%)" in gate.deny with input as i
}

test_coverage_justo_en_el_umbral_pasa if {
	i := object.union(clean, {"coverage": {"percent": 80}})
	gate.allow with input as i
}

test_kev_bloquea_aunque_sea_medium if {
	i := object.union(clean, {"kev": [{"id": "CVE-2099-0001", "package": "x", "severity": "MEDIUM"}]})
	not gate.allow with input as i
	"CVE explotado activamente (CISA KEV): CVE-2099-0001" in gate.deny with input as i
}

# ── Falla cerrada ──
test_scanner_ausente_bloquea if {
	i := object.remove(clean, ["sca"])
	not gate.allow with input as i
	"sca: el scanner no reportó resultados (falla cerrada)" in gate.deny with input as i
}

test_entrada_vacia_bloquea if {
	not gate.allow with input as {}
}

# ── Criterios de riesgo ──
test_contexto_estricto_limita_sca_high_a_1 if {
	gate.max_sca_high == 1 with input as clean
}

test_sin_exposicion_internet_relaja_a_2 if {
	i := object.union(clean, {"context": {"business_criticality": "critical", "exposure_level": "internal", "mitigations": []}})
	gate.max_sca_high == 2 with input as i
	gate.max_medium == 15 with input as i
}

test_compensating_controls_suman_un_high if {
	i := object.union(clean, {"context": {"business_criticality": "critical", "exposure_level": "internet", "mitigations": ["waf", "rate_limiting"]}})
	gate.max_sca_high == 2 with input as i
}

test_un_solo_control_no_alcanza if {
	i := object.union(clean, {"context": {"business_criticality": "critical", "exposure_level": "internet", "mitigations": ["waf"]}})
	gate.max_sca_high == 1 with input as i
}

test_contexto_ausente_asume_el_mas_estricto if {
	i := object.remove(clean, ["context"])
	gate.max_sca_high == 1 with input as i
	gate.max_medium == 10 with input as i
}

# ── Caso de debate (build #482: 0 Critical · 3 High · 12 Medium) ──
test_caso_debate_482_bloquea_en_contexto_estricto if {
	i := object.union(clean, {
		"sca": {"critical": 0, "high": 3, "medium": 12, "low": 0},
		"sast": {"critical": 0, "high": 0, "medium": 0, "low": 0},
		"dast": {"critical": 0, "high": 0, "medium": 0, "low": 0},
	})
	not gate.allow with input as i
	count(gate.deny) == 2 with input as i
}
