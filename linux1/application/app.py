from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route("/get", methods=["GET"])
def handle_get():
    return jsonify({"method": "GET", "message": "Hello from GET endpoint"}), 200


@app.route("/post", methods=["POST"])
def handle_post():
    data = request.get_json(silent=True) or {}
    return jsonify({"method": "POST", "message": "Hello from POST endpoint", "received": data}), 200


@app.route("/put", methods=["PUT"])
def handle_put():
    data = request.get_json(silent=True) or {}
    return jsonify({"method": "PUT", "message": "Hello from PUT endpoint", "received": data}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
