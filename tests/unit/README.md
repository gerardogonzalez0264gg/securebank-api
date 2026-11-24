# Pruebas Unitarias

Esta carpeta está destinada a las pruebas unitarias del proyecto SecureBank.

## Objetivo

Las pruebas unitarias permiten comprobar componentes individuales del sistema de forma aislada.

## Aspectos a verificar

- Reglas de negocio.
- Validación de datos.
- Funciones relacionadas con autenticación.
- Funciones relacionadas con cuentas.
- Funciones relacionadas con transferencias.
- Manejo de errores.
- Controles de seguridad a nivel de componente.

## Pruebas disponibles

- `test_consolidate_findings.py` (Sesión 9): parsers de Gitleaks, Semgrep, Trivy, ZAP y coverage; falla cerrada ante reportes faltantes o corruptos.
- `test_transfers_auth_views.py`: calc, export, auth, accounts y config.
