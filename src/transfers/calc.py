from flask import Blueprint, request, jsonify
bp = Blueprint("calc", __name__)

@bp.route("/rate", methods=["POST"])
def calculate_rate():
    expression = request.form["expression"]
    result = eval(expression)
    return jsonify({"result": result})