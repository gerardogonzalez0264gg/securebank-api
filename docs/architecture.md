# Arquitectura - SecureBank API

## 1. Descripción general

SecureBank API es una plataforma financiera simulada utilizada para practicar la aplicación de principios DevSecOps.

El sistema está compuesto por un frontend web, una API REST, un servicio de autenticación y una base de datos.

La arquitectura permite separar las responsabilidades de presentación, procesamiento de solicitudes, autenticación y almacenamiento de información.

---

## 2. Componentes principales

### Frontend Web

Es la interfaz utilizada por los usuarios para interactuar con SecureBank.

Sus principales responsabilidades son:

* Permitir el inicio de sesión.
* Permitir consultar información de cuentas.
* Permitir realizar operaciones.
* Enviar solicitudes a la API REST.

### Backend REST API

Es el componente encargado de procesar las solicitudes provenientes del frontend.

Sus principales módulos son:

* Autenticación.
* Cuentas.
* Transferencias.
* Usuarios.
* Movimientos e historial.

La API contiene los endpoints que permiten acceder a las funcionalidades de SecureBank.

### Servicio de autenticación

Es responsable de gestionar la autenticación de los usuarios.

Entre los elementos relacionados con este componente se encuentran:

* Login.
* Credenciales.
* Sesiones.
* Tokens JWT.

### Base de datos

Es el componente encargado de almacenar la información de SecureBank.

Entre los datos almacenados se consideran:

* Datos de usuarios.
* Datos de clientes.
* Información de cuentas.
* Saldos.
* Transferencias.
* Movimientos e historial.

---

## 3. Flujo principal

El flujo principal de comunicación es:

```text
Usuario
   |
   | HTTPS
   v
Frontend Web
   |
   | Solicitud HTTP/HTTPS
   v
Backend REST API
   |
   +----------------------+
   |                      |
   v                      v
Servicio de          Base de Datos
Autenticación
   |
   v
Tokens JWT
```

### Flujo de una solicitud

1. El usuario interactúa con el frontend.
2. El frontend envía una solicitud hacia la API REST.
3. La API recibe y procesa la solicitud.
4. Cuando corresponde, se valida la autenticación del usuario.
5. La API verifica los permisos necesarios para realizar la operación.
6. La API consulta o modifica información en la base de datos.
7. La respuesta es enviada nuevamente al frontend.

---

## 4. Módulos de la API

### Auth

Gestiona las funciones relacionadas con la autenticación de usuarios.

Ejemplos:

* Login.
* Validación de credenciales.
* Gestión de sesión.
* Tokens JWT.

### Accounts

Gestiona las cuentas bancarias.

Ejemplos:

* Consulta de cuentas.
* Consulta de saldos.
* Acceso a información de cuentas.

### Transfers

Gestiona las transferencias bancarias.

Endpoint crítico utilizado durante el Threat Modeling:

```text
POST /transfer
```

Este endpoint requiere controles de autenticación, autorización y validación de entradas.

### Users

Gestiona la información relacionada con los usuarios.

Ejemplos:

* Registro.
* Perfil.
* Información del usuario.

### Movements

Gestiona el historial e información relacionada con las operaciones realizadas.

---

## 5. Límites de confianza

La arquitectura contiene diferentes fronteras de confianza.

### Internet ↔ Frontend

El usuario se encuentra fuera de la infraestructura de SecureBank y accede al frontend.

### Frontend ↔ API

Las solicitudes provenientes del frontend ingresan a la API y deben ser validadas.

### API ↔ Servicio de autenticación

La API debe comprobar la identidad del usuario y la validez de la autenticación.

### API ↔ Base de datos

La API accede a información privada almacenada en la base de datos.

### Zona pública ↔ Infraestructura interna

Los recursos internos deben estar protegidos frente a accesos externos no autorizados.

En cada frontera de confianza se deben aplicar controles de validación, autenticación y autorización.

---

## 6. Superficie de ataque

Los principales puntos de exposición de la arquitectura son:

* Endpoints REST.
* Formularios del frontend.
* Servicio de autenticación.
* Tokens JWT.
* Base de datos.
* Contenedores e imágenes Docker.
* Dependencias de terceros.
* Variables de entorno.
* Secretos.
* Solicitudes HTTP/HTTPS.

---

## 7. Consideraciones de seguridad

La arquitectura debe considerar los siguientes controles:

* Autenticación de usuarios.
* Autorización basada en recursos.
* Validación de entradas.
* Protección de credenciales.
* Gestión segura de secretos.
* Cifrado de comunicaciones mediante HTTPS.
* Protección de la base de datos.
* Registro y auditoría de operaciones.
* Configuración segura de contenedores.
* Análisis de dependencias.
* Controles de seguridad integrados al pipeline DevSecOps.

---

## 8. Relación con el Threat Model

La arquitectura sirve como base para el Threat Model de SecureBank.

Los puntos donde los datos atraviesan fronteras de confianza representan lugares donde deben aplicarse controles de seguridad.

El endpoint `POST /transfer` es especialmente relevante debido a que una falla de autorización podría permitir que un usuario acceda o realice operaciones sobre recursos que no le pertenecen.

El Threat Model asociado se encuentra en:

```text
docs/threat-model.md
```

---

## 9. Resumen

La arquitectura de SecureBank separa el frontend, la API REST, el servicio de autenticación y la base de datos.

Esta separación permite identificar los flujos de información, las fronteras de confianza y los principales puntos de ataque que deben ser considerados durante el ciclo DevSecOps.
