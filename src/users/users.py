import os
import sqlite3
from flask import Blueprint, request, jsonify
from src.auth.auth import verify_password
from src.auth.middleware import require_owner
from src.auth.tokens import issue_token

bp = Blueprint("users", __name__)
DB_PATH = os.environ.get("SECUREBANK_DB", "securebank.db")


@bp.route("/login", methods=["POST"])
def login():
    username = request.form["username"]
    password = request.form["password"]
    conn = sqlite3.connect(DB_PATH)
    query = "SELECT id, username, password_hash, role FROM users WHERE username = ?"
    row = conn.execute(query, (username,)).fetchone()
    conn.close()
    if row and verify_password(password, row[2]):
        return jsonify(
            {"id": row[0], "username": row[1], "access_token": issue_token(row[0], row[3])}
        )
    return jsonify({"error": "invalid credentials"}), 401


@bp.route("/users/<int:user_id>", methods=["GET"])
@require_owner("user_id")  # API1 BOLA: solo el dueño del recurso (o admin)
def get_user(user_id: int):
    conn = sqlite3.connect(DB_PATH)
    row = conn.execute(
        "SELECT id, username, email, balance FROM users WHERE id = ?", (user_id,)
    ).fetchone()
    conn.close()
    if row is None:
        return jsonify({"error": "not found"}), 404
    return jsonify({"id": row[0], "username": row[1], "email": row[2], "balance": row[3]})
