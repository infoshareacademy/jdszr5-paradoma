import numpy as np
from flask import Flask, request, jsonify, render_template
import pickle
import math

app = Flask(__name__)
model = pickle.load(open('wine_model.pkl', 'rb'))

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/predict', methods=['GET', 'POST'])
def predict():

    feat_0 = request.form["volatile acidity"]
    feat_1 = request.form["citric acid"]
    feat_2 = request.form["residual sugar"]
    feat_3 = request.form["total sulfur dioxide"]
    feat_4 = request.form["pH"]
    feat_5 = request.form["sulphates"]
    feat_6 = request.form["alcohol"]

    int_features = [feat_0, feat_1, feat_2, feat_3, feat_4, feat_5, feat_6, math.log(float(feat_2)), math.log(float(feat_3)), math.log(float(feat_6))]
    final_features = [np.array(int_features)]
    prediction = model.predict(final_features)

    output = prediction[0]
    if output == 0:
        text = "This is bad wine. We do not recommend"
    else:
        text = "This is good wine. We recommend it"

    return render_template('index.html', prediction_text='{}'.format(text))

@app.route('/results',methods=['POST'])
def results():

    data = request.get_json(force=True)
    prediction = model.predict([np.array(list(data.values()))])

    output = prediction[0]
    return jsonify(output)

if __name__ == "__main__":
    app.run(debug=True)