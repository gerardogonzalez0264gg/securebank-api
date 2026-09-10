# Pipeline CI/CD de SecureBank

## Objetivo

El pipeline CI/CD de SecureBank tiene como objetivo automatizar diferentes etapas del ciclo de desarrollo y permitir incorporar controles de seguridad durante el proceso de desarrollo.

## Flujo del pipeline

El flujo conceptual definido para SecureBank es:

1. Commit
2. Build
3. Unit Test
4. Security Test
5. Package
6. Deploy

## Etapas

### 1. Commit

El proceso comienza cuando se realiza un cambio en el repositorio.

Los cambios deben ser revisados antes de incorporarse a la rama principal.

### 2. Build

En esta etapa se prepara el proyecto para las siguientes etapas del pipeline.

### 3. Unit Test

Se ejecutan las pruebas unitarias para verificar el funcionamiento de componentes individuales.

### 4. Security Test

Se realizan controles orientados a detectar problemas de seguridad.

Estos controles forman parte del enfoque DevSecOps y permiten incorporar seguridad desde las primeras etapas del desarrollo.

### 5. Package

Se prepara el artefacto que será utilizado en las siguientes etapas.

### 6. Deploy

El artefacto preparado puede ser utilizado para realizar el despliegue hacia el entorno correspondiente.

## Seguridad del pipeline

El pipeline debe considerar los siguientes controles:

- No almacenar secretos directamente en los archivos del repositorio.
- Utilizar mecanismos seguros para gestionar secretos.
- Limitar los permisos utilizados por el pipeline.
- Utilizar acciones y herramientas confiables.
- Mantener la configuración del pipeline versionada en el repositorio.
- Incorporar controles de seguridad durante el ciclo de desarrollo.

## Estado actual

Este documento representa el diseño conceptual del pipeline de SecureBank.

La implementación funcional del pipeline se realizará únicamente cuando sea requerida por las actividades del curso.
