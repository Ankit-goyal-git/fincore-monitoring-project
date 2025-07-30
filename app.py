from flask import Flask
import random
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

@app.route('/')
def home():
    return " Welcome to Mini E-Commerce!"

@app.route('/products')
def products():
    return {"items": ["Shoes", "Bags", "Watches"]}

@app.route('/buy')
def buy():
    if random.randint(0, 10) > 7:
        return " Error placing order", 500
    return "🛒 Order Placed!"

@app.route('/cart')
def cart():
    return {"items": 3, "total": "$120"}

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)


