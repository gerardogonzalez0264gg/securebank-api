# Reporte comparativo · securebank:v1 vs securebank:v2-secure

Sesión 10 · Seguridad de Contenedores y Docker

## 1. Salida de Trivy

### securebank:v1
```

Report Summary

┌──────────────────────────────────────────────────────────────────────────────┬────────────┬─────────────────┬─────────┐
│                                    Target                                    │    Type    │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ securebank:v1 (ubuntu 26.04)                                                 │   ubuntu   │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/package.json                                                             │  node-pkg  │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/bcrypt-5.0.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/blinker-1.9.0.dist-info/METADATA      │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/click-8.5.1.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/flask-3.1.3.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/gunicorn-27.0.1.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/iniconfig-2.3.1.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/itsdangerous-2.2.0.dist-info/METADATA │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/jinja2-3.1.6.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/markupsafe-3.0.4.dist-info/METADATA   │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/pluggy-1.7.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/pygments-2.21.0.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/pytest-9.2.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.14/dist-packages/werkzeug-3.1.9.dist-info/METADATA     │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/bin/pebble                                                               │  gobinary  │        0        │    -    │
└──────────────────────────────────────────────────────────────────────────────┴────────────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)

```

### securebank:v2-secure
```

Report Summary

┌──────────────────────────────────────────────────────────────────────────────┬────────────┬─────────────────┬─────────┐
│                                    Target                                    │    Type    │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ securebank:v2-secure (debian 13.7)                                           │   debian   │       50        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/bcrypt-5.0.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/blinker-1.9.0.dist-info/METADATA      │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/click-8.5.1.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/flask-3.1.3.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/gunicorn-27.0.1.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/iniconfig-2.3.1.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/itsdangerous-2.2.0.dist-info/METADATA │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/jinja2-3.1.6.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/markupsafe-3.0.4.dist-info/METADATA   │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/packaging-26.3.dist-info/METADATA     │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/pip-24.0.dist-info/METADATA           │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/pluggy-1.7.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/pygments-2.21.0.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/pytest-9.2.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/werkzeug-3.1.9.dist-info/METADATA     │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.11/site-packages/wheel-0.46.3.dist-info/METADATA       │ python-pkg │        0        │    -    │
└──────────────────────────────────────────────────────────────────────────────┴────────────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)


securebank:v2-secure (debian 13.7)
==================================
Total: 50 (HIGH: 50, CRITICAL: 0)

┌───────────────┬─────────────────┬──────────┬──────────────┬───────────────────────────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────────────┐
│    Library    │  Vulnerability  │ Severity │    Status    │         Installed Version         │          Fixed Version           │                            Title                             │
├───────────────┼─────────────────┼──────────┼──────────────┼───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ apt           │ CVE-2026-109518 │ HIGH     │ fixed        │ 3.0.3                             │ 3.0.4                            │ apt: apt: Remote code execution via hard link reuse during   │
│               │                 │          │              │                                   │                                  │ package download...                                          │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-109518                  │
├───────────────┼─────────────────┤          ├──────────────┼───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ bsdutils      │ CVE-2026-76642  │          │ affected     │ 1:2.41.5-0+deb13u1                │                                  │ util-linux: util-linux: failed external mount helper still   │
│               │                 │          │              │                                   │                                  │ runs privileged X-mount post-hooks                           │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-76642                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78408  │          │              │                                   │                                  │ util-linux: util-linux: nsenter --join-cgroup leaks root     │
│               │                 │          │              │                                   │                                  │ cgroup migration authority                                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78408                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78409  │          │              │                                   │                                  │ util-linux: util-linux: X-mount.subdir detached-tree         │
│               │                 │          │              │                                   │                                  │ resolution can escape via intermediate symlinks              │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78409                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78410  │          │              │                                   │                                  │ util-linux: util-linux: restricted bind mounts do not pin    │
│               │                 │          │              │                                   │                                  │ the source, allowing X-mount.owner/group/mode...             │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78410                   │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libacl1       │ CVE-2026-54369  │          │              │ 2.3.2-2+b1                        │                                  │ acl: Symlink traversal privilege escalation via libacl       │
│               │                 │          │              │                                   │                                  │ functions                                                    │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-54369                   │
├───────────────┼─────────────────┤          ├──────────────┼───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libapt-pkg7.0 │ CVE-2026-109518 │          │ fixed        │ 3.0.3                             │ 3.0.4                            │ apt: apt: Remote code execution via hard link reuse during   │
│               │                 │          │              │                                   │                                  │ package download...                                          │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-109518                  │
├───────────────┼─────────────────┤          ├──────────────┼───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libblkid1     │ CVE-2026-76642  │          │ affected     │ 2.41.5-0+deb13u1                  │                                  │ util-linux: util-linux: failed external mount helper still   │
│               │                 │          │              │                                   │                                  │ runs privileged X-mount post-hooks                           │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-76642                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78408  │          │              │                                   │                                  │ util-linux: util-linux: nsenter --join-cgroup leaks root     │
│               │                 │          │              │                                   │                                  │ cgroup migration authority                                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78408                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78409  │          │              │                                   │                                  │ util-linux: util-linux: X-mount.subdir detached-tree         │
│               │                 │          │              │                                   │                                  │ resolution can escape via intermediate symlinks              │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78409                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78410  │          │              │                                   │                                  │ util-linux: util-linux: restricted bind mounts do not pin    │
│               │                 │          │              │                                   │                                  │ the source, allowing X-mount.owner/group/mode...             │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78410                   │
├───────────────┼─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ liblastlog2-2 │ CVE-2026-76642  │          │              │                                   │                                  │ util-linux: util-linux: failed external mount helper still   │
│               │                 │          │              │                                   │                                  │ runs privileged X-mount post-hooks                           │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-76642                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78408  │          │              │                                   │                                  │ util-linux: util-linux: nsenter --join-cgroup leaks root     │
│               │                 │          │              │                                   │                                  │ cgroup migration authority                                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78408                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78409  │          │              │                                   │                                  │ util-linux: util-linux: X-mount.subdir detached-tree         │
│               │                 │          │              │                                   │                                  │ resolution can escape via intermediate symlinks              │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78409                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78410  │          │              │                                   │                                  │ util-linux: util-linux: restricted bind mounts do not pin    │
│               │                 │          │              │                                   │                                  │ the source, allowing X-mount.owner/group/mode...             │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78410                   │
├───────────────┼─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libmount1     │ CVE-2026-76642  │          │              │                                   │                                  │ util-linux: util-linux: failed external mount helper still   │
│               │                 │          │              │                                   │                                  │ runs privileged X-mount post-hooks                           │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-76642                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78408  │          │              │                                   │                                  │ util-linux: util-linux: nsenter --join-cgroup leaks root     │
│               │                 │          │              │                                   │                                  │ cgroup migration authority                                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78408                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78409  │          │              │                                   │                                  │ util-linux: util-linux: X-mount.subdir detached-tree         │
│               │                 │          │              │                                   │                                  │ resolution can escape via intermediate symlinks              │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78409                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78410  │          │              │                                   │                                  │ util-linux: util-linux: restricted bind mounts do not pin    │
│               │                 │          │              │                                   │                                  │ the source, allowing X-mount.owner/group/mode...             │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78410                   │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libncursesw6  │ CVE-2025-69720  │          │              │ 6.5+20250216-2                    │                                  │ ncurses: ncurses: Buffer overflow vulnerability may lead to  │
│               │                 │          │              │                                   │                                  │ arbitrary code execution.                                    │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2025-69720                   │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libsmartcols1 │ CVE-2026-76642  │          │              │ 2.41.5-0+deb13u1                  │                                  │ util-linux: util-linux: failed external mount helper still   │
│               │                 │          │              │                                   │                                  │ runs privileged X-mount post-hooks                           │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-76642                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78408  │          │              │                                   │                                  │ util-linux: util-linux: nsenter --join-cgroup leaks root     │
│               │                 │          │              │                                   │                                  │ cgroup migration authority                                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78408                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78409  │          │              │                                   │                                  │ util-linux: util-linux: X-mount.subdir detached-tree         │
│               │                 │          │              │                                   │                                  │ resolution can escape via intermediate symlinks              │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78409                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78410  │          │              │                                   │                                  │ util-linux: util-linux: restricted bind mounts do not pin    │
│               │                 │          │              │                                   │                                  │ the source, allowing X-mount.owner/group/mode...             │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78410                   │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libsqlite3-0  │ CVE-2026-119373 │          │              │ 3.46.1-7+deb13u2                  │                                  │ sqlite: sqlite: Denial of service via heap-based buffer      │
│               │                 │          │              │                                   │                                  │ overflow in FTS5                                             │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-119373                  │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-119374 │          │              │                                   │                                  │ sqlite: sqlite: Arbitrary code execution via corrupted FTS5  │
│               │                 │          │              │                                   │                                  │ index                                                        │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-119374                  │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-119379 │          │              │                                   │                                  │ sqlite: sqlite: Arbitrary code execution via crafted session │
│               │                 │          │              │                                   │                                  │ changesets                                                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-119379                  │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libsystemd0   │ CVE-2026-16742  │          │              │ 257.13-1~deb13u1                  │                                  │ systemd: systemd-homed: Local privilege escalation via       │
│               │                 │          │              │                                   │                                  │ missing home-record signature verification                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-16742                   │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libtinfo6     │ CVE-2025-69720  │          │              │ 6.5+20250216-2                    │                                  │ ncurses: ncurses: Buffer overflow vulnerability may lead to  │
│               │                 │          │              │                                   │                                  │ arbitrary code execution.                                    │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2025-69720                   │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libudev1      │ CVE-2026-16742  │          │              │ 257.13-1~deb13u1                  │                                  │ systemd: systemd-homed: Local privilege escalation via       │
│               │                 │          │              │                                   │                                  │ missing home-record signature verification                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-16742                   │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ libuuid1      │ CVE-2026-76642  │          │              │ 2.41.5-0+deb13u1                  │                                  │ util-linux: util-linux: failed external mount helper still   │
│               │                 │          │              │                                   │                                  │ runs privileged X-mount post-hooks                           │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-76642                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78408  │          │              │                                   │                                  │ util-linux: util-linux: nsenter --join-cgroup leaks root     │
│               │                 │          │              │                                   │                                  │ cgroup migration authority                                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78408                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78409  │          │              │                                   │                                  │ util-linux: util-linux: X-mount.subdir detached-tree         │
│               │                 │          │              │                                   │                                  │ resolution can escape via intermediate symlinks              │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78409                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78410  │          │              │                                   │                                  │ util-linux: util-linux: restricted bind mounts do not pin    │
│               │                 │          │              │                                   │                                  │ the source, allowing X-mount.owner/group/mode...             │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78410                   │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ login         │ CVE-2026-76642  │          │              │ 1:4.16.0-2+really2.41.5-0+deb13u1 │                                  │ util-linux: util-linux: failed external mount helper still   │
│               │                 │          │              │                                   │                                  │ runs privileged X-mount post-hooks                           │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-76642                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78408  │          │              │                                   │                                  │ util-linux: util-linux: nsenter --join-cgroup leaks root     │
│               │                 │          │              │                                   │                                  │ cgroup migration authority                                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78408                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78409  │          │              │                                   │                                  │ util-linux: util-linux: X-mount.subdir detached-tree         │
│               │                 │          │              │                                   │                                  │ resolution can escape via intermediate symlinks              │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78409                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78410  │          │              │                                   │                                  │ util-linux: util-linux: restricted bind mounts do not pin    │
│               │                 │          │              │                                   │                                  │ the source, allowing X-mount.owner/group/mode...             │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78410                   │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ mount         │ CVE-2026-76642  │          │              │ 2.41.5-0+deb13u1                  │                                  │ util-linux: util-linux: failed external mount helper still   │
│               │                 │          │              │                                   │                                  │ runs privileged X-mount post-hooks                           │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-76642                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78408  │          │              │                                   │                                  │ util-linux: util-linux: nsenter --join-cgroup leaks root     │
│               │                 │          │              │                                   │                                  │ cgroup migration authority                                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78408                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78409  │          │              │                                   │                                  │ util-linux: util-linux: X-mount.subdir detached-tree         │
│               │                 │          │              │                                   │                                  │ resolution can escape via intermediate symlinks              │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78409                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78410  │          │              │                                   │                                  │ util-linux: util-linux: restricted bind mounts do not pin    │
│               │                 │          │              │                                   │                                  │ the source, allowing X-mount.owner/group/mode...             │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78410                   │
├───────────────┼─────────────────┤          │              ├───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ ncurses-base  │ CVE-2025-69720  │          │              │ 6.5+20250216-2                    │                                  │ ncurses: ncurses: Buffer overflow vulnerability may lead to  │
│               │                 │          │              │                                   │                                  │ arbitrary code execution.                                    │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2025-69720                   │
├───────────────┤                 │          │              │                                   ├──────────────────────────────────┤                                                              │
│ ncurses-bin   │                 │          │              │                                   │                                  │                                                              │
│               │                 │          │              │                                   │                                  │                                                              │
│               │                 │          │              │                                   │                                  │                                                              │
├───────────────┼─────────────────┤          ├──────────────┼───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ perl-base     │ CVE-2026-9538   │          │ fix_deferred │ 5.40.1-6+deb13u1                  │                                  │ perl-Archive-Tar: perl-Archive-Tar: Denial of Service via    │
│               │                 │          │              │                                   │                                  │ crafted tar header with large entry...                       │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-9538                    │
├───────────────┼─────────────────┤          ├──────────────┼───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ util-linux    │ CVE-2026-76642  │          │ affected     │ 2.41.5-0+deb13u1                  │                                  │ util-linux: util-linux: failed external mount helper still   │
│               │                 │          │              │                                   │                                  │ runs privileged X-mount post-hooks                           │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-76642                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78408  │          │              │                                   │                                  │ util-linux: util-linux: nsenter --join-cgroup leaks root     │
│               │                 │          │              │                                   │                                  │ cgroup migration authority                                   │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78408                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78409  │          │              │                                   │                                  │ util-linux: util-linux: X-mount.subdir detached-tree         │
│               │                 │          │              │                                   │                                  │ resolution can escape via intermediate symlinks              │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78409                   │
│               ├─────────────────┤          │              │                                   ├──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│               │ CVE-2026-78410  │          │              │                                   │                                  │ util-linux: util-linux: restricted bind mounts do not pin    │
│               │                 │          │              │                                   │                                  │ the source, allowing X-mount.owner/group/mode...             │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-78410                   │
├───────────────┼─────────────────┤          ├──────────────┼───────────────────────────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────────────┤
│ zlib1g        │ CVE-2026-85091  │          │ fixed        │ 1:1.3.dfsg+really1.3.1-1+b1       │ 1:1.3.dfsg+really1.3.1-1+deb13u1 │ zlib: zlib: Heap buffer overflow in gz_vacate() allows       │
│               │                 │          │              │                                   │                                  │ arbitrary code execution                                     │
│               │                 │          │              │                                   │                                  │ https://avd.aquasec.com/nvd/cve-2026-85091                   │
└───────────────┴─────────────────┴──────────┴──────────────┴───────────────────────────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────────────┘
```

Un primer escaneo de v2 con el tag original `python:3.11.9-slim-bookworm` dio 173 hallazgos HIGH/CRITICAL (11 CRITICAL), incluidos 3 de `setuptools`. Por eso se actualizó el tag y se quitó `setuptools`.

## 2. Tabla comparativa

| Métrica | securebank:v1 | securebank:v2-secure | Mejora |
|---|---|---|---|
| Vulnerabilidades (HIGH + CRITICAL) | 0 | 50 (0 CRITICAL) | sin mejora hoy (ver nota) |
| Tamaño de la imagen | 381 MB | 219 MB | ↓ 43 % |
| Paquetes instalados | 135 | 88 | ↓ 35 % |
| Usuario de ejecución | root | appuser (uid 10001) | mínimo privilegio |
| Puertos expuestos | 22 | 8000 | acorde al servicio |

**Nota:** v1 usa `ubuntu:latest`, que ese día traía Ubuntu 26.04 recién parcheado, por eso salió en 0. Es un resultado puntual y no reproducible, porque `latest` cambia sin aviso. v2 bajó de 173 a 50 hallazgos frente a su primer escaneo. De esas 50, solo 3 tienen parche disponible (`--ignore-unfixed`); las otras 47 no tienen corrección publicada.

**Por qué cambia cada métrica:**
- Tamaño y paquetes: la base slim y `--no-install-recommends` instalan menos cosas.
- Usuario: v2 usa `USER appuser`, así que un compromiso no da root.
- Puertos: la API solo habla HTTP, no necesita SSH (22).

## 3. Cambios aplicados al Dockerfile

| Cambio | Por qué |
|---|---|
| `ubuntu:latest` → `python:3.11.17-slim-trixie` | Base mínima con tag fijo, reproducible. |
| `USER appuser` (uid 10001) | Mínimo privilegio. |
| `COPY . .` → `COPY src ./src` + `.dockerignore` | No copia `.env`, `.git` ni tests. |
| `EXPOSE 22` → `EXPOSE 8000` | SSH no hace falta en una API HTTP. |
| `--no-install-recommends`, `--no-cache-dir` | Menos paquetes y menos peso. |
| `pip uninstall -y setuptools` | No se usa y traía 3 CVEs HIGH. |
| `tini` + `gunicorn` | Manejo de señales y servidor apto para producción. |

## 4. Evidencia

Comandos usados: `docker build`, `docker images securebank`, `docker run --rm <imagen> whoami`, `docker inspect`, `trivy image --severity HIGH,CRITICAL <imagen>`.

## 5. Conclusión y riesgos residuales

v2-secure aplica las buenas prácticas de la sesión: corre sin root, expone solo su puerto, tiene tag fijo y es más liviana. Fijar un tag no basta: hay que actualizarlo.

Riesgos que quedan:
- 50 vulnerabilidades HIGH de Debian: 47 sin parche publicado y 3 con parche.
- El escaneo de v1 es una foto de ese día, no una garantía.
- No se usa `--read-only` ni `--cap-drop=ALL`.
- La imagen no está firmada.
- Los secretos van por variable de entorno, sin gestor de secretos.
- Falta un job de Trivy en el CI.
