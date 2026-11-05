# Ciclo DevSecOps de SecureBank

Este dibujo muestra las 8 etapas del ciclo y el control de seguridad que se usa en cada una.

```mermaid
flowchart LR
  A[1 Plan<br/>Modelo de amenazas] --> B[2 Code<br/>Revisar el código]
  B --> C[3 Build<br/>Revisar librerías]
  C --> D[4 Test<br/>Pruebas de ataque]
  D --> E[5 Release<br/>Firmar el paquete]
  E --> F[6 Deploy<br/>Revisar la configuración]
  F --> G[7 Operate<br/>Proteger y cuidar secretos]
  G --> H[8 Monitor<br/>Vigilar y avisar]
  H -. Feedback continuo .-> A
```

| Etapa | Control de seguridad | Herramienta | Responsable |
|---|---|---|---|
| 1. Plan | Modelo de amenazas (STRIDE) y requisitos de seguridad | Threat Dragon | Arquitecto / Dueño del producto |
| 2. Code | Revisión automática del código y búsqueda de secretos | Semgrep, gitleaks | Desarrollador |
| 3. Build | Revisión de librerías e imágenes | Trivy | Desarrollador / DevOps |
| 4. Test | Pruebas de ataque en un ambiente de prueba | OWASP ZAP | QA / Seguridad |
| 5. Release | Firma del paquete y lista de componentes | Sigstore (Cosign), Syft | DevOps |
| 6. Deploy | Revisión de la infraestructura y del contenedor | Checkov | DevOps / Cloud |
| 7. Operate | Manejo de secretos, firewall web y parches | Vault, ModSecurity | Operaciones / SRE |
| 8. Monitor | Registros, alertas y respuesta a incidentes | Grafana, Wazuh | Seguridad (SOC) / SRE |
