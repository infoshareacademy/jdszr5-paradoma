import requests

url = 'http://localhost:5000/results'
r = requests.post(url,json={'alcohol':11, 'sulphates':0.5, 'volatile acidity':0.7, 'total sulfur dioxide':50, 'citric acid':0.0, 'pH':3.5, 'density':0.998})

print(r.json())