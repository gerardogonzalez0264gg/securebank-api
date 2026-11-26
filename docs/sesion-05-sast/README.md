# Sesión 5 · SAST · Reporte antes y después

Proyecto SecureBank API (caso hipotético). Herramienta: **Semgrep**. Evidencia: `sast-before.sarif.zip` y `sast-after.sarif.zip` (dentro de cada zip, el archivo se llama `sast.sarif`).

## ① Resumen antes / después

| Reporte | Resultados Semgrep | Defectos distintos | Estado |
|---|---|---|---|
| [sast-before.sarif.zip](sast-before.sarif.zip) | 10 | 5 (los plantados por el curso) | ✕ FAIL |
| [sast-after.sarif.zip](sast-after.sarif.zip) | 0 | 0 | ✓ PASS |

Hay 10 resultados para 5 defectos porque varias reglas de Semgrep marcan la misma línea (por ejemplo, `subprocess-injection`, `dangerous-subprocess-use` y `subprocess-shell-true` en `export.py`).

## ② Clasificación por categoría OWASP

| # | Archivo | Defecto | Reglas Semgrep que lo detectaron | OWASP Top 10 (2021) | CWE | Severidad |
|---|---|---|---|---|---|---|
| 1 | `src/users/users.py` | SQL Injection | `tainted-sql-string` | A03 Injection | CWE-89 | Critical |
| 2 | `src/transfers/export.py` | Command Injection | `subprocess-injection`, `dangerous-subprocess-use`, `subprocess-shell-true` | A03 Injection | CWE-78 | Critical |
| 3 | `src/transfers/calc.py` | `eval()` sobre input del usuario | `eval-injection`, `user-eval` | A03 Injection | CWE-95 | Critical |
| 4 | `src/accounts/view.py` | XSS (HTML armado a mano) | `raw-html-format` (x2) | A03 Injection | CWE-79 | High |
| 5 | `src/auth/auth.py` | Contraseñas con MD5 | `insecure-hash-algorithm-md5`, `md5-used-as-password` | A02 Cryptographic Failures | CWE-327 / CWE-916 | High |

## ③ Diff del código corregido

Tomado del historial de git (versión original del archivo → versión actual).

**1. SQL Injection** · `src/users/users.py`
```diff
- query = "SELECT id, username, password_hash FROM users WHERE username='" + username + "'"
- row = conn.execute(query).fetchone()
+ query = "SELECT id, username, password_hash, role FROM users WHERE username = ?"
+ row = conn.execute(query, (username,)).fetchone()
```

**2. Command Injection** · `src/transfers/export.py`
```diff
- filename = request.args["f"]
- output = subprocess.check_output("cat reports/" + filename, shell=True)
+ REPORTS = {"daily": "reports/daily.txt", "monthly": "reports/monthly.txt"}
+ name = request.args.get("f", "")
+ if name not in REPORTS:
+     abort(400)
+ result = subprocess.run(["cat", REPORTS[name]], shell=False, capture_output=True, check=True)
```

**3. eval()** · `src/transfers/calc.py`
```diff
- result = eval(expression)
+ result = _safe_eval(ast.parse(expression, mode="eval"))   # solo números y + - * /
```

**4. XSS** · `src/accounts/view.py`
```diff
- return render_template_string(f"<h1>Hola {name}</h1>")
+ return render_template("welcome.html", name=name)          # Jinja escapa {{ name }}
```

**5. MD5** · `src/auth/auth.py`
```diff
- return hashlib.md5(password.encode()).hexdigest()
+ return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
```

Cada corrección tiene un test en [tests/unit/test_transfers_auth_views.py](../../tests/unit/test_transfers_auth_views.py) (expresiones peligrosas → 400, lista blanca de export, `<script>` escapado, bcrypt, etc.).

## ④ URL del run del pipeline en verde

`TODO(equipo)`: pegar aquí el enlace al run de GitHub Actions donde el job `SAST (Semgrep)` termina en verde, por ejemplo `https://github.com/<org>/securebank-api/actions/runs/<id>`.

## Configuración del job en el CI y por qué difiere de la diapositiva

La clase propone `semgrep --config=p/owasp-top-ten --error` (el job falla con hallazgos). En [ci.yml](../../.github/workflows/ci.yml) el job `sast`:

- usa `--config p/default`, un conjunto más amplio que incluye reglas OWASP;
- **no** usa `--error`, porque desde la Sesión 9 la decisión de bloquear la toma el **Security Gate (OPA)**, que lee el SARIF y bloquea cualquier Critical o High en código propio (`max_critical := 0`, `max_first_party_high := 0`). Así el criterio de bloqueo está en un solo lugar, versionado y con tests;
- depende de `secret-scan` y no de `unit-tests`: la Sesión 7 pide que el escaneo de secretos vaya primero.

Si se quiere replicar exactamente la configuración de la diapositiva, el paso alternativo queda comentado en el workflow.
