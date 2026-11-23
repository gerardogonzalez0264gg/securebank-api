# Notas del hardening para SecureBank API

## 1. Lo que encontramos mal en los manifiestos (M1 – M5)

- **M1 (frontend-deployment.yaml — Crítico):** Está corriendo con privileged: true y usando la imagen con tag :latest, así que no tenemos trazabilidad ni un *digest* fijo.
- **M2 (api-deployment.yaml — Crítico):** Corre como root (runAsUser: 0) y no tiene configurado runAsNonRoot ni capabilities.drop.
- **M3 (db-secret.yaml — Alto):** Los secretos están metidos directo en las variables de entorno (env) del *Deployment* y los *Secrets* no tienen cifrado en reposo.
- **M4 (worker-deployment.yaml — Alto):** Le faltan límites de recursos (resources.limits) y no tiene el sistema de archivos raíz en solo lectura (readOnlyRootFilesystem).
- **M5 (serviceaccount.yaml — Crítico):** Tiene un RoleBinding directo a cluster-admin y monta el *token* automáticamente en *Pods* que ni siquiera lo usan.

## 2. Qué cambiamos en deployment.hardened.yaml

- **automountServiceAccountToken: false:** Para que el *Pod* no monte credenciales de la API de Kubernetes por defecto si no las necesita.
- **runAsNonRoot: true y runAsUser: 10001:** Evita que el contenedor arranque como root (UID 0), bajando el riesgo de que alguien escale privilegios hacia el nodo.
- **readOnlyRootFilesystem: true y allowPrivilegeEscalation: false:** Bloquea cambios en el sistema de archivos raíz en tiempo de ejecución e impide ganar permisos extra.
- **capabilities.drop: ["ALL"]:** Quita todas las *capabilities* de Linux que sobran para achicar la superficie de ataque.
- **resources.requests y resources.limits (cpu y memory):** Pone un tope al consumo de CPU y memoria para que un *Pod* no deje sin recursos al nodo.
- **secretKeyRef en DB_PASSWORD:** Saca la contraseña en texto plano del manifiesto y la lee directo desde el *Secret* db.
- **readinessProbe y livenessProbe (tcpSocket en puerto 8000):** Sirve para ir chequeando que el contenedor esté vivo y listo para recibir tráfico.
- **Volumen emptyDir en /tmp:** Le da una carpeta temporal donde sí pueda escribir, ya que el resto del sistema quedó en solo lectura.
- **Imagen por *digest* (sha256) en vez de :latest:** Nos asegura saber exactamente qué versión se está desplegando (ojo, el *digest* de ahora es solo de ejemplo y falta validarlo en el clúster).

