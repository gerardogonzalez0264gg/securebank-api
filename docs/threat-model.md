# Threat Model - SecureBank API

## 1. Objetivo

El objetivo de este Threat Model es identificar y analizar las principales amenazas de seguridad de SecureBank API antes de incorporar los controles de seguridad al ciclo DevSecOps.

El análisis considera los activos, amenazas, vulnerabilidades, riesgos y controles asociados al sistema.

Se utiliza el modelo STRIDE para clasificar las amenazas.

---

## 2. Activos

Los principales activos que deben protegerse son:

| ID  | Activo                    | Descripción                                                           |
| --- | ------------------------- | --------------------------------------------------------------------- |
| A01 | Datos de clientes         | Información personal de los usuarios.                                 |
| A02 | Saldos de cuentas         | Información relacionada con el dinero disponible en las cuentas.      |
| A03 | Tokens JWT                | Información utilizada para mantener la autenticación de los usuarios. |
| A04 | Credenciales              | Información utilizada para autenticar a los usuarios.                 |
| A05 | Transferencias            | Operaciones financieras realizadas por los usuarios.                  |
| A06 | Historial de movimientos  | Registro de operaciones realizadas.                                   |
| A07 | Base de datos             | Almacén de información del sistema.                                   |
| A08 | API REST                  | Servicios y endpoints utilizados por los clientes.                    |
| A09 | Infraestructura           | Servidores, contenedores e infraestructura utilizada por SecureBank.  |
| A10 | Secretos de configuración | Credenciales, claves y otros secretos utilizados por el sistema.      |

---

## 3. Componentes del sistema

SecureBank está compuesto conceptualmente por:

* Cliente o usuario.
* Frontend web.
* Backend REST API.
* Servicio de autenticación.
* Base de datos.
* Contenedores e imágenes Docker.
* Dependencias de terceros.
* Infraestructura de red.

### Módulos principales

* Autenticación.
* Cuentas.
* Transferencias.
* Usuarios.
* Movimientos e historial.

---

## 4. Actores

### Usuario legítimo

Usuario que utiliza SecureBank para autenticarse, consultar sus cuentas y realizar operaciones autorizadas.

### Atacante externo

Actor que intenta acceder al sistema, obtener información, modificar datos o realizar operaciones no autorizadas.

### Usuario comprometido

Cuenta legítima cuyas credenciales o tokens han sido obtenidos por un atacante.

### Administrador

Actor con permisos superiores para administrar determinados recursos del sistema.

---

## 5. Superficie de ataque

La superficie de ataque corresponde al conjunto de puntos mediante los cuales un atacante puede intentar acceder al sistema o extraer información.

En SecureBank se consideran:

* Endpoints REST expuestos.
* Formularios del frontend.
* Servicio de autenticación.
* Puerto de la base de datos.
* Contenedores e imágenes Docker.
* Dependencias de terceros.
* Variables de entorno.
* Secretos.
* Tokens de autenticación.
* Peticiones HTTP enviadas a la API.

---

## 6. Data Flow Diagram (DFD) conceptual

El flujo principal del sistema se representa de la siguiente manera:

```text
[Usuario]
    |
    | HTTPS
    v
[Frontend Web]
    |
    | Solicitudes HTTP/HTTPS
    v
[Backend REST API]
    |
    +--------------------+
    |                    |
    v                    v
[Servicio de          [Base de
 Autenticación]         Datos]
    |
    v
[Tokens JWT]
```

### Flujos principales

1. El usuario interactúa con el frontend.
2. El frontend envía solicitudes al backend REST API.
3. El backend procesa las solicitudes.
4. El servicio de autenticación valida la identidad del usuario.
5. El backend consulta o modifica información en la base de datos.
6. Las operaciones realizadas generan información que puede formar parte del historial de movimientos.

---

## 7. Fronteras de confianza

Una frontera de confianza representa un punto donde cambia el nivel de confianza y donde deben aplicarse controles de validación, autenticación y autorización.

En SecureBank se identifican las siguientes fronteras:

### TB01 - Internet ↔ Frontend

El usuario accede desde una zona externa hacia el frontend público.

### TB02 - Frontend ↔ API

Las solicitudes del frontend ingresan al backend y deben ser validadas.

### TB03 - API ↔ Servicio de autenticación

La API debe validar correctamente la identidad y autenticación del usuario.

### TB04 - API ↔ Base de datos

La API accede a información privada almacenada en la base de datos.

### TB05 - Zona pública ↔ Infraestructura interna

Los recursos internos deben permanecer protegidos frente a accesos externos no autorizados.

---

## 8. Modelo STRIDE

STRIDE clasifica las amenazas en seis categorías:

* S - Spoofing: suplantación de identidad.
* T - Tampering: manipulación de datos.
* R - Repudiation: repudio de acciones.
* I - Information Disclosure: divulgación de información.
* D - Denial of Service: denegación de servicio.
* E - Elevation of Privilege: elevación de privilegios.

---

## 9. Amenazas identificadas

### T01 - Suplantación mediante credenciales filtradas

**Categoría:** Spoofing

**Activo afectado:** Credenciales y cuentas de usuarios.

**Amenaza:** Un atacante utiliza credenciales obtenidas previamente para autenticarse como un usuario legítimo.

**Vulnerabilidad:** Uso de credenciales comprometidas o controles de autenticación insuficientes.

**Impacto:** Acceso no autorizado a la cuenta del usuario.

**Probabilidad:** Alta.

**Riesgo:** Alto.

**Control:** Autenticación fuerte, protección de credenciales, gestión segura de secretos y controles contra intentos de autenticación.

---

### T02 - Manipulación del monto de una transferencia

**Categoría:** Tampering

**Activo afectado:** Transferencias.

**Amenaza:** Un atacante modifica el monto enviado en una solicitud de transferencia.

**Vulnerabilidad:** Falta de validación adecuada de los parámetros recibidos por el backend.

**Impacto:** Transferencias por montos diferentes a los autorizados.

**Probabilidad:** Media.

**Riesgo:** Alto.

**Control:** Validación de entradas y reglas de negocio en el backend.

---

### T03 - Repudio de una transferencia

**Categoría:** Repudiation

**Activo afectado:** Historial de movimientos.

**Amenaza:** Un usuario niega haber realizado una transferencia.

**Vulnerabilidad:** Ausencia de registros de auditoría íntegros y trazables.

**Impacto:** Dificultad para demostrar quién realizó una operación.

**Probabilidad:** Media.

**Riesgo:** Medio.

**Control:** Auditoría de operaciones, registros íntegros y trazabilidad de las transacciones.

---

### T04 - Exposición de información de otra cuenta

**Categoría:** Information Disclosure

**Activo afectado:** Datos de clientes y saldos.

**Amenaza:** Un usuario consulta información perteneciente a otra cuenta modificando el identificador utilizado por el endpoint.

**Vulnerabilidad:** Falta de autorización a nivel de objeto, conocida como BOLA (Broken Object Level Authorization).

**Impacto:** Exposición de información financiera y personal.

**Probabilidad:** Alta.

**Riesgo:** Alto.

**Control:** Autorización por recurso y validación de propiedad de la cuenta.

---

### T05 - Denegación de servicio contra el login

**Categoría:** Denial of Service

**Activo afectado:** Servicio de autenticación.

**Amenaza:** Un atacante realiza una gran cantidad de intentos de autenticación para consumir los recursos del servicio.

**Vulnerabilidad:** Ausencia de mecanismos adecuados de limitación de solicitudes.

**Impacto:** Indisponibilidad o degradación del servicio de autenticación.

**Probabilidad:** Alta.

**Riesgo:** Alto.

**Control:** Rate limiting, monitoreo y controles contra abuso.

---

### T06 - Elevación de privilegios mediante JWT manipulado

**Categoría:** Elevation of Privilege

**Activo afectado:** Tokens JWT y autorización.

**Amenaza:** Un usuario intenta modificar información contenida en un token para obtener privilegios superiores.

**Vulnerabilidad:** Validación incorrecta de la firma o de los permisos asociados al token.

**Impacto:** Acceso a operaciones administrativas o restringidas.

**Probabilidad:** Media.

**Riesgo:** Alto.

**Control:** Validación de firma JWT, autorización basada en permisos y validación de roles en el backend.

---

### T07 - Inyección SQL

**Categoría:** Tampering

**Activo afectado:** Base de datos.

**Amenaza:** Un atacante introduce comandos SQL maliciosos mediante entradas controladas por el usuario.

**Vulnerabilidad:** Construcción insegura de consultas SQL.

**Impacto:** Manipulación o exposición de información almacenada en la base de datos.

**Probabilidad:** Alta.

**Riesgo:** Alto.

**Control:** Consultas parametrizadas, validación de entradas y pruebas de seguridad.

---

### T08 - Exposición de secretos

**Categoría:** Information Disclosure

**Activo afectado:** Secretos de configuración y credenciales.

**Amenaza:** Credenciales o secretos son expuestos en el código, repositorio o configuración.

**Vulnerabilidad:** Gestión insegura de secretos.

**Impacto:** Acceso no autorizado a recursos del sistema.

**Probabilidad:** Media.

**Riesgo:** Alto.

**Control:** Utilizar mecanismos seguros de gestión de secretos y evitar almacenar credenciales directamente en el repositorio.

---

### T09 - Explotación de dependencias vulnerables

**Categoría:** Elevation of Privilege

**Activo afectado:** Aplicación e infraestructura.

**Amenaza:** Un atacante aprovecha una vulnerabilidad conocida en una dependencia de terceros.

**Vulnerabilidad:** Uso de dependencias vulnerables o sin control de versiones.

**Impacto:** Compromiso de la aplicación o ejecución de acciones no autorizadas.

**Probabilidad:** Media.

**Riesgo:** Alto.

**Control:** Análisis de composición de software (SCA), actualización de dependencias y control de versiones.

---

### T10 - Ejecución del contenedor con privilegios excesivos

**Categoría:** Elevation of Privilege

**Activo afectado:** Infraestructura y contenedores.

**Amenaza:** Un atacante que compromete la aplicación obtiene permisos elevados dentro del contenedor.

**Vulnerabilidad:** Configuración insegura del contenedor, como ejecución con usuario root.

**Impacto:** Mayor capacidad para comprometer recursos del sistema.

**Probabilidad:** Media.

**Riesgo:** Alto.

**Control:** Ejecutar contenedores con usuarios sin privilegios y aplicar configuraciones seguras.

---

## 10. Matriz de riesgos

La prioridad del riesgo se determina utilizando:

**Riesgo = Probabilidad × Impacto**

| ID  | Amenaza                              | Probabilidad | Impacto | Nivel |
| --- | ------------------------------------ | ------------ | ------- | ----- |
| T01 | Credenciales filtradas               | Alta         | Alto    | Alto  |
| T02 | Manipulación de transferencia        | Media        | Alto    | Alto  |
| T03 | Repudio de transferencia             | Media        | Medio   | Medio |
| T04 | BOLA                                 | Alta         | Alto    | Alto  |
| T05 | Denegación de servicio               | Alta         | Alto    | Alto  |
| T06 | Manipulación de JWT                  | Media        | Alto    | Alto  |
| T07 | SQL Injection                        | Alta         | Alto    | Alto  |
| T08 | Exposición de secretos               | Media        | Alto    | Alto  |
| T09 | Dependencias vulnerables             | Media        | Alto    | Alto  |
| T10 | Contenedor con privilegios excesivos | Media        | Alto    | Alto  |

---

## 11. Caso de abuso - POST /transfer

### Funcionalidad legítima

Un usuario autenticado desea transferir dinero entre cuentas.

### Caso de abuso

Un atacante intenta modificar los parámetros de la solicitud para realizar una transferencia no autorizada o transferir dinero desde una cuenta que no le pertenece.

### Amenazas principales

* Manipulación del monto.
* BOLA.
* Falta de autorización.
* Modificación de parámetros.
* Acceso a cuentas de otros usuarios.

### Controles requeridos

* Autenticación del usuario.
* Autorización sobre la cuenta de origen.
* Validación de la propiedad de la cuenta.
* Validación del monto.
* Validación de los parámetros.
* Registro de la operación.
* Auditoría de las transferencias.

---

## 12. Security Stories

### SS01 - Autorización de cuentas

Como usuario autenticado, quiero que el sistema valide que soy propietario o tengo autorización sobre una cuenta antes de acceder a ella, para evitar accesos no autorizados.

### SS02 - Protección de transferencias

Como usuario autenticado, quiero que el sistema valide mi autorización sobre la cuenta de origen antes de realizar una transferencia, para evitar transferencias desde cuentas ajenas.

### SS03 - Protección de entradas

Como sistema, quiero validar las entradas recibidas por la API, para reducir el riesgo de inyección y manipulación de parámetros.

### SS04 - Protección de credenciales

Como organización, quiero mantener las credenciales y secretos fuera del código fuente, para reducir el riesgo de exposición.

### SS05 - Trazabilidad

Como organización, quiero registrar las operaciones financieras realizadas, para mantener trazabilidad y facilitar la investigación de incidentes.

---

## 13. Controles de seguridad

Los principales controles identificados son:

* Autenticación fuerte.
* Autorización por recurso.
* Validación de entradas.
* Consultas parametrizadas.
* Rate limiting.
* Auditoría y trazabilidad.
* Gestión segura de secretos.
* Análisis SAST.
* Análisis SCA.
* Análisis DAST.
* Configuración segura de contenedores.
* Revisiones de código.
* Protección de ramas.
* Controles de seguridad en CI/CD.

---

## 14. Conclusión

El Threat Model identifica las principales amenazas que pueden afectar a SecureBank API.

El análisis permite relacionar cada amenaza con los activos afectados, vulnerabilidades, riesgos y controles correspondientes.

El caso de `POST /transfer` demuestra la importancia de aplicar autenticación y autorización a nivel de recurso para evitar accesos y transferencias no autorizadas.

Este modelo servirá como base para incorporar controles de seguridad durante las siguientes etapas del ciclo DevSecOps.
