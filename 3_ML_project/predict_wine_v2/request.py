import requests

url = 'http://localhost:5000/results'
r = requests.post(url,json={'volatile acidity':0.7, 'citric acid':0.0, 'residual sugar':0.998, 'total sulfur dioxide':50, 'pH':3.5, 'sulphates':0.5, 'alcohol':11})

print(r.json())