# POL-REPO-001 · Política de Repositorios Seguros

Versión 1.0 · 2026-11-05 · Proyecto SecureBank API · Próxima revisión: 2027-02-05

## § 1 · Alcance

Vale para todos los repositorios de código de la organización, tanto los que están en producción como los que todavía no. Incluye el código, los pipelines, la configuración y los accesos de las personas.

## § 2 · Roles y responsabilidades

| Rol | Qué hace (se puede comprobar) |
|---|---|
| Developer | Trabaja en ramas `feature/*` y abre Pull Requests. No aprueba ni une sus propios cambios. |
| Reviewer | Revisa los PR de su equipo y confirma que no haya secretos ni código raro. |
| Code Owner | Dueño de una carpeta (definido en `CODEOWNERS`). Debe aprobar los cambios de su carpeta. |
| Lead de seguridad | Aprueba los cambios al pipeline y los hotfix. Aprueba las excepciones. |
| SRE | Cuida los ambientes y ayuda a revisar los cambios al pipeline. |
| Release Manager | Es el único que crea tags y releases en `main`. Usa una lista de revisión. |
| Secret Custodian | Son 2 personas nombradas. Cambian los secretos y guardan el registro de cada uso. |

## § 3 · Reglas obligatorias

| Regla | Riesgo que cubre |
|---|---|
| R.01 Los secretos van en un gestor de secretos, nunca en el código. Se revisa cada push. `.gitignore` bloquea `.env`, `.pem` y llaves. Si se filtra uno, se cambia de inmediato. | Secretos expuestos |
| R.02 Todo PR necesita 1 aprobación, o 2 si toca auth, transfers o workflows. Debe aprobar el Code Owner. Un push nuevo borra las aprobaciones anteriores. | Cambios maliciosos |
| R.03 `main` está protegida: sin push directo, sin force push y sin borrar la rama. Vale también para administradores. | Ramas borradas |
| R.04 MFA obligatorio y commits firmados (GPG o SSH). Los mensajes siguen Conventional Commits (`feat:`, `fix:`). | Commits falsos |
| R.05 Menor acceso posible. Los externos tienen acceso con fecha de término. Los accesos se revisan cada 3 meses y se quitan al salir la persona. | Colaboradores externos |
| R.06 Los PR desde forks no ven los secretos. Los cambios a `.github/workflows/` necesitan aprobación extra. Solo se usan acciones oficiales o con versión fija. | PR hostiles |
| R.07 `main` siempre debe poder desplegarse. Para unir un PR, el CI debe estar en verde y los comentarios resueltos. | Repositorio como activo |

## § 4 · Matriz "quién puede qué"

| Acción | Quién puede | Condiciones |
|---|---|---|
| Unir a `main` | Un Code Owner distinto del autor | 1 o 2 aprobaciones, CI verde. Sin auto-merge, ni siquiera para dependencias. PR de forks: solo después de revisarlos. Hotfix: aprobación del Lead de seguridad y revisión completa dentro de 24 horas. |
| Cambiar pipelines | Code Owners de `.github/workflows/` (Lead de seguridad y SRE) | 2 aprobaciones, una de seguridad. Los cambios quedan en el historial. Los devs proponen y seguridad aprueba. |
| Crear releases | Release Manager | Tag firmado, lista de revisión completa, ventana semanal y número del ticket. |
| Cambiar secretos | Secret Custodian (2 personas) | Se cambian cada 90 días. Cada acceso queda registrado. Secretos separados para dev y prod. |

## § 5 · Excepciones y revisión

1. Se pide la excepción en un issue con el motivo, el riesgo y la duración.
2. La aprueban el Lead de seguridad y un Code Owner.
3. Dura máximo 30 días y queda anotada en el issue.
4. En una emergencia con un secreto, primero se cambia el secreto y luego se avisa al Lead de seguridad.
5. La política se revisa cada 3 meses y después de cualquier incidente.
