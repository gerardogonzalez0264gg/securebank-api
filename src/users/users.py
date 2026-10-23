import sqlite3
from flask import Blueprint, request, jsonify
from src.auth.auth import verify_password

bp = Blueprint("users", __name__)
DB_PATH = "securebank.db"

@bp.route("/login", methods=["POST"])
def login():
    username = request.form["username"]
    password = request.form["password"]
    conn = sqlite3.connect(DB_PATH)
    row = conn.execute(
        "SELECT id, username, password_hash FROM users WHERE username=?",
        (username,),
    ).fetchone()
    conn.close()
    if row and verify_password(password, row[2]):
        return jsonify({"id": row[0], "username": row[1]})
    return jsonify({"error": "invalid credentials"}), 401
