# Arquitectura de SecureBank API

## Estructura del proyecto

El proyecto se organiza en diferentes componentes para separar
responsabilidades y facilitar el mantenimiento y la seguridad.

### src/

Contiene los componentes principales de la aplicación.

- auth/: autenticación y autorización.
- accounts/: gestión de cuentas.
- transfers/: operaciones de transferencia.
- users/: gestión de usuarios.

### tests/

Contiene las pruebas del sistema.

- unit/: pruebas unitarias.
- integration/: pruebas de integración.

### docs/

Contiene la documentación técnica y de seguridad.

- architecture.md: documentación de la arquitectura.
- threat-model.md: modelo de amenazas.

### .github/

Contiene configuraciones relacionadas con GitHub y CI/CD.

- workflows/ci.yml: pipeline automatizado.
- CODEOWNERS: responsables de revisión del código.

## Principios

La arquitectura busca aplicar:

- separación de responsabilidades;
- mínimo privilegio;
- revisión de cambios;
- automatización de pruebas;
- seguridad desde el diseño.
