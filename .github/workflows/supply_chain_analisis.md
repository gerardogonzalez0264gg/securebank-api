# Análisis: Como se ve si cambia `securebank:v1` en el registry??

**Escenario:** Si por alguna razon un atacante mete mano en el registry y reemplaza la imagen `securebank:v1` por otra modificada

## Cómo se frena antes de que llegue a producción

1. **Falla la verificación de firma (`cosign verify`):** La imagen no tiene una firma válida vinculada a la identidad OIDC oficial del *pipeline*, ni aparece registrada en el *transparency log*. Cuando corre `cosign verify` en el *pipeline*, tira error (`exit code 1`) y corta el flujo rapido antes de desplegar nada.
2. **No cuadra el *digest* (`sha256`):** Los *tags* como `:v1` se pueden sobrescribir fácil, pero el *digest* `sha256` es como la huella digital exacta del archivo. Si alguien cambia la imagen, `:v1` va a apuntar a otro *digest* distinto al que espera, dejando claro que el artefacto no es el mismo que se firmó en el *build*.
3. **El *admission controller* bloquea el despliegue:** En Kubernetes, una política de admisión (como Kyverno o el `policy-controller` de Sigstore) revisa la imagen justo antes de levantar el *Pod*. Si ve que no tiene firma valida o que no viene de una fuente autorizada, el clúster no le permite y el *Pod* ya no alcanza a arrancar.

**Conclusión (defensa en capas):** Juntar la validación de firma, el control por *digest* inmutable y un *admission controller* cubre las vulnerabilidades en varios frentes: confirma quién construyó la imagen, avisa si alguien la altero en el camino y frena cualquier despliegue sospechoso directo en el cluster.
