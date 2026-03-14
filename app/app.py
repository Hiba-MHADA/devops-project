# app/app.py
from flask import Flask, jsonify, render_template, request
import os, socket, datetime
import numpy as np
from sklearn.linear_model import LinearRegression

app = Flask(__name__)

# ============================================
# MODELE ML : Prédiction de prix immobilier
# ============================================
# Données d'entraînement : [surface_m2, nb_pieces, age_ans]
X_train = np.array([
    [30, 1, 20], [50, 2, 15], [70, 3, 10], [90, 4, 5],
    [45, 2, 25], [60, 3, 8], [80, 4, 12], [100, 5, 3],
    [35, 1, 30], [55, 2, 18], [75, 3, 7], [110, 5, 1],
])
y_train = np.array([
    85000, 140000, 195000, 260000,
    120000, 175000, 230000, 310000,
    90000, 150000, 210000, 350000,
])
model = LinearRegression()
model.fit(X_train, y_train)

# ============================================
# ROUTE 1 : Interface interactive de prédiction
# ============================================
@app.route('/')
def home():
    return render_template('index.html',
        hostname=socket.gethostname(),
        version=os.getenv('APP_VERSION', '1.0.0'),
        environment=os.getenv('APP_ENV', 'production'),
        timestamp=str(datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    )

# ============================================
# ROUTE 2 : API de prédiction (POST JSON)
# ============================================
@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    surface = float(data.get('surface', 50))
    pieces  = float(data.get('pieces', 2))
    age     = float(data.get('age', 10))
    features = np.array([[surface, pieces, age]])
    prix = max(0, model.predict(features)[0])
    return jsonify({
        'prix_estime': round(float(prix), 2),
        'prix_formate': f'{prix:,.0f} €',
        'surface': surface,
        'pieces': pieces,
        'age': age
    })

# ============================================
# ROUTE 3 : Health check pour Kubernetes
# ============================================
@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

# ============================================
# ROUTE 4 : Informations JSON
# ============================================
@app.route('/info')
def info():
    return jsonify({
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'environment': os.getenv('APP_ENV', 'production'),
        'pod_ip': socket.gethostbyname(socket.gethostname()),
        'model': 'LinearRegression',
        'features': ['surface_m2', 'nb_pieces', 'age_ans']
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
