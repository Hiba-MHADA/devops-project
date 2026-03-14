# app/tests/test_app.py
import pytest, sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_status_200(client):
    response = client.get('/')
    assert response.status_code == 200

def test_health_returns_200(client):
    response = client.get('/health')
    assert response.status_code == 200

def test_health_returns_healthy(client):
    response = client.get('/health')
    assert response.get_json()['status'] == 'healthy'

def test_predict_returns_200(client):
    response = client.post('/predict',
        json={'surface': 75, 'pieces': 3, 'age': 10},
        content_type='application/json'
    )
    assert response.status_code == 200

def test_predict_returns_price(client):
    response = client.post('/predict',
        json={'surface': 75, 'pieces': 3, 'age': 10},
        content_type='application/json'
    )
    data = response.get_json()
    assert 'prix_estime' in data
    assert data['prix_estime'] > 0

def test_info_contains_model(client):
    response = client.get('/info')
    data = response.get_json()
    assert 'model' in data
    assert data['model'] == 'LinearRegression'
