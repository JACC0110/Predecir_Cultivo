import numpy as np
import h5py
from flask import Flask, request, jsonify, render_template
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

#Cargar modelo H5
with h5py.File("modelo_cultivos.h5", "r") as f:
    pesos = np.array(f["pesos"])
    estructura = np.array(f["estructura"])
    labels = [l.decode() if isinstance(l, bytes) else l for l in f["labels"]]
    features = [i.decode() if isinstance(i, bytes) else i for i in f["features"]]
    rendimientos = np.array(f["rendimientos"])

n_input = int(estructura[0])
n_hidden = int(estructura[1])
n_output = int(estructura[2])

W1 = pesos[:n_input * n_hidden].reshape((n_input, n_hidden))
b1 = pesos[n_input * n_hidden : n_input * n_hidden + n_hidden]

start = n_input * n_hidden + n_hidden
W2 = pesos[start : start + (n_hidden * n_output)].reshape((n_hidden, n_output))
b2 = pesos[start + (n_hidden * n_output):]


#Funcion del modelo
def softmax(x):
    e = np.exp(x - np.max(x))
    return e / e.sum()

def predict_crop(temp, ph, rain):
    X = np.array([temp, ph, rain])
    hidden = np.tanh(X @ W1 + b1)
    output = softmax(hidden @ W2 + b2)
    idx = np.argmax(output)

    return labels[idx], float(rendimientos[idx]), float(output[idx])

#Pagina web
@app.route("/")
def home():
    return render_template("index.html")

#Endpoint de prediccion
@app.route("/predict", methods=["POST"])
def predict():
    data = request.json
    cultivo, rendimiento, prob = predict_crop(
        float(data["temperature"]),
        float(data["ph"]),
        float(data["rainfall"])
    )
    return jsonify({
        "cultivo": cultivo,
        "rendimiento": rendimiento,
        "probabilidad": prob
    })


if __name__ == "__main__":
    app.run(debug=True)
