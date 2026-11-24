# Pruebas de Integración

Esta carpeta está destinada a las pruebas de integración de SecureBank.

## Objetivo

Verificar que los diferentes componentes y módulos del sistema funcionen correctamente cuando interactúan entre sí.

## Aspectos a verificar

- Integración entre módulos.
- Comunicación con la base de datos.
- Flujo de autenticación.
- Flujo de cuentas.
- Flujo de transferencias.
- Manejo de errores entre componentes.

## Pruebas de política

Las pruebas de la política Rego viven junto a ella (`policy/security-policy-v1_test.rego`, `opa test policy/`). Las entradas de ejemplo «verde», «rojo» y «debate #482» están en `tests/policy/fixtures/`.
