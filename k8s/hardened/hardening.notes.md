# notas del hardening de securebank api

**1. Analisis de manifiestos vulnerables (m1 – m5)**

-**M1 (`frontend-deployment.yaml` — Crítico):** porque `privileged: true` y uso de imagen con tag `:latest` sin trazabilidad ni *digest*

-**M2 (`api-deployment.yaml` — Crítico):** esto porque `runAsUser: 0`, ausencia de `runAsNonRoot` y ausencia de `capabilities.drop`

-**M3 (`db-secret.yaml` — Alto):** Se detectan secretos embebidos en variables de entorno (`env`) del *Deployment* y *Secrets* sin cifrado en reposo

-**M4 (`worker-deployment.yaml` — Alto):**  Se detecta ausencia de `resources.limits` y ausencia de `readOnlyRootFilesystem`

-**M5 (`serviceaccount.yaml` — Crítico):** Se detecta `RoleBinding` a `cluster-admin` y *token* automontado en *Pods* que no lo necesitan

**2. controles aplicados  en `deployment.hardened.yaml`**

-**`runAsNonRoot: true` y `runAsUser: 10001`:** No permite que el proceso principal del contenedor corra como `root` (`UID 0`) y reduce el riesgo de escalada al nodo
-**`readOnlyRootFilesystem: true` y `allowPrivilegeEscalation: false`:** Impide modificar el sistema de archivos raíz en ejecución y bloquea la obtención de privilegios adicionales
-**`capabilities: drop: ["ALL"]`:** Elimina todas las *capabilities* Linux innecesarias para reducir la superficie de ataque del contenedor
-**`resources.requests` y `resources.limits` (`cpu` y `memory`):** Acota el consumo de recursos del *Pod* para evitar agotamiento de recursos en el nodo
-**`secretKeyRef` en `DB_PASSWORD`:** Para no mostrar credenciales en texto dentro del manifiesto al leerlas desde el *Secret*
-**Imagen por *digest* (`sha256`) en lugar de `:latest`:** Esto da mejor trazabilidad y inmutabilidad sobre la version de la imagen desplegada
