from flask import Flask, jsonify, request
import random
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

@app.route('/')
def home():
    return "🏦 Welcome to FinCore Bank API"

@app.route('/balance')
def balance():
    return jsonify({"account": "1234567890", "balance": 18750.35})

@app.route('/transfer', methods=['POST'])
def transfer():
    # Example body: {"from":"1234", "to":"5678", "amount":500}
    data = request.get_json()
    if not data or data.get("amount", 0) <= 0:
        return jsonify({"error": "Invalid transfer request"}), 400

    # Simulate a 20% chance of failure
    if random.randint(0, 10) > 7:
        return jsonify({"error": "Insufficient funds"}), 500

    return jsonify({
        "status": "success",
        "from": data.get("from"),
        "to": data.get("to"),
        "amount": data.get("amount")
    })

@app.route('/transactions')
def transactions():
    return jsonify({
        "transactions": [
            {"id": 1, "type": "debit", "amount": 500, "desc": "Electricity"},
            {"id": 2, "type": "credit", "amount": 2000, "desc": "Salary"}
        ]
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

