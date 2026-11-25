# Pruebas de Seguridad

Esta carpeta está destinada a las pruebas relacionadas con la seguridad de SecureBank.

## Objetivo

Identificar vulnerabilidades y verificar que los controles de seguridad implementados sean adecuados.

## Aspectos a verificar

- Autenticación.
- Autorización.
- Validación de entradas.
- Inyección SQL.
- Control de acceso.
- Protección de información sensible.
- Gestión de secretos.
- Configuración segura.
- Seguridad de los contenedores.
- Controles de seguridad del proceso CI/CD.

## Pruebas disponibles

- `test_bola.py` (Sesión 8): Alice no puede leer `GET /users/{id}` de Bob (403), enumeración de IDs y cabeceras de seguridad. Se ejecuta con `python -m pytest tests/security`.
