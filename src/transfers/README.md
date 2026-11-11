# Módulo de Transferencias

Este módulo representa las funcionalidades relacionadas con las transferencias bancarias de SecureBank.

## Responsabilidades

- Realizar transferencias bancarias.
- Validar la información de las transferencias.
- Gestionar la cuenta de origen.
- Gestionar la cuenta de destino.
- Registrar las operaciones realizadas.

## Consideraciones de seguridad

Las transferencias representan una funcionalidad crítica del sistema.

Antes de realizar una transferencia se debe comprobar que el usuario esté autenticado y autorizado para operar sobre la cuenta de origen.

También se deben validar los datos recibidos para evitar manipulación de parámetros e inyecciones.

## Endpoint crítico

El endpoint de transferencia utilizado en el modelo de amenazas es:

POST /transfer
