"""Siembra la BD de laboratorio con Alice (id=100) y Bob (id=101).

Las contraseñas llegan por variables de entorno (R.01: nada hardcodeado).
Uso:  SEED_ALICE_PW=... SEED_BOB_PW=... python lab/dast/seed.py [ruta.db]
"""
import os
import sqlite3
import sys

from src.auth.auth import hash_password

SCHEMA = """
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user',
    email TEXT,
    balance REAL NOT NULL DEFAULT 0
)
"""


def seed(db_path: str, alice_pw: str, bob_pw: str) -> None:
    conn = sqlite3.connect(db_path)
    conn.execute(SCHEMA)
    rows = [
        (100, "alice", hash_password(alice_pw), "user", "alice@securebank.test", 1500.0),
        (101, "bob", hash_password(bob_pw), "user", "bob@securebank.test", 98000.0),
    ]
    conn.executemany(
        "INSERT OR REPLACE INTO users (id, username, password_hash, role, email, balance)"
        " VALUES (?, ?, ?, ?, ?, ?)",
        rows,
    )
    conn.commit()
    conn.close()


if __name__ == "__main__":
    seed(
        sys.argv[1] if len(sys.argv) > 1 else "securebank.db",
        os.environ["SEED_ALICE_PW"],
        os.environ["SEED_BOB_PW"],
    )
    print("BD de laboratorio lista: alice=100, bob=101")
