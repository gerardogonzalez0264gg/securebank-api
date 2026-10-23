import ast
import operator
from flask import Blueprint, request, jsonify
bp = Blueprint("calc", __name__)

_OPS = {
    ast.Add: operator.add,
     ast.Sub: operator.sub,
      ast.Mult: operator.mul,
    ast.Div: operator.truediv,}
def _safe_eval(node):
    if isinstance(node,ast.Expression):
        return _safe_eval(node.body)
    if isinstance(node,ast.Constant) and isinstance(node.value, (int, float)):
        return node.value
     if isinstance(node,ast.BinOp) and type(node.op) in _OPS:
        return _OPS[type(node.op)](_safe_eval(node.left), _safe_eval(node.right))
    raise ValueError("expresion no permitida")
@bp.route("/rate", methods=["POST"])
def calculate_rate():
    expression = request.form["expression"]
    try:
        result = _safe_eval(ast.parse(expression, mode="eval"))
    except (ValueError, SyntaxError, ZeroDivisionError):
        return jsonify({"error": "invalid expression"}), 400
    return jsonify({"result": result})
