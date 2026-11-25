# Plan de mitigación (Sección 2)

Un plan por cada hallazgo High o Medium. Cada fila se cierra solo cuando un **nuevo scan de ZAP ya no reporta el hallazgo** (principio base de los Quality Gates de la Sesión 9).

| Hallazgo | Acción correctiva | Responsable | Plazo | Verificación |
|---|---|---|---|---|
| BOLA · `GET /users/{id}` (API1, CWE-639, T04) | Ownership check centralizado: `require_owner` compara `token.sub` con el id del recurso; rol admin como excepción; audit log de intentos | Backend team | Sprint 1 | `pytest tests/security/test_bola.py`: `/users/otro → 403` |
| Cabeceras ausentes · CSP, HSTS, X-Frame-Options (A05, CWE-693/1021/319) | `after_request` con `SECURITY_HEADERS` en `src/app.py` (equivalente a `helmet()` en Express) | Backend team | Sprint 1 | Re-scan ZAP: hallazgo cerrado; `test_headers_de_seguridad_presentes` |
| Cookies inseguras · `session` (CWE-1004/614) | La API usa Bearer JWT y no emite cookies; si se agregan, `HttpOnly` + `Secure` + `SameSite=Strict` | Backend team | Sprint 1 | Inspección de `Set-Cookie`; re-scan ZAP |
| IDs secuenciales predecibles (refuerzo BOLA) | Migrar `users.id` a UUID v4 | Backend team + DBA | Sprint 2 | Revisión de esquema; sin IDs enumerables en respuestas |
| Cobertura limitada del crawler en API JSON | Publicar `openapi.yaml` y correr `zap-api-scan.py` en nightly/release | Seguridad + Backend | Sprint 2 | Nightly con endpoints `/users/{id}` y `/login` descubiertos |

## Política aplicable (POL-REPO-001)

- El PR que agrega el job `dast` toca `.github/workflows/` y `src/auth`: **2 aprobaciones**, una del Lead de seguridad (R.02, matriz §4).
- Sin secretos en el código: el entorno de test genera `JWT_SECRET` y las contraseñas de seed en cada ejecución y las enmascara en los logs (R.01).
- Acciones de GitHub oficiales con versión fija e imagen de ZAP con tag fijo (R.06).

## Riesgos residuales

- Baseline no cubre autorización ni lógica de negocio; BOLA y similares dependen de tests dedicados.
- Cualquier hallazgo que ZAP reporte y no esté en esta tabla debe triagearse antes de la Sesión 9.
