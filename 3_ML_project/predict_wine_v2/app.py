import numpy as np
from flask import Flask, request, jsonify, render_template
import pickle
import math
from tkinter import Y
import pandas as pd
import numpy as np
from scipy import stats
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
import warnings
warnings.filterwarnings('ignore')
import pickle
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import ipywidgets as widgets
from IPython.display import display
from IPython.display import Image
from ipywidgets import Box, Layout
import seaborn as sns

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

    int_features = [feat_0, feat_1, feat_2, feat_3, feat_4, feat_5, feat_6, math.log(float(feat_2)+1), math.log(float(feat_3)+1), math.log(float(feat_6)+1)]
    final_features = [np.array(int_features)]
    prediction = model.predict(final_features)

    output = prediction[0]
    if output == 0:
        text = "This is a bad wine. We do not recommend it"
    else:
        text = "This is a good wine. We recommend it"

    file = "winequality-red.csv"
    filepath = os.path.join(os.path.abspath(""), file)
    df = pd.read_csv(filepath)
    columns= ["alcohol", "sulphates", "volatile acidity", "total sulfur dioxide", "citric acid", "pH", "residual sugar"]
    items = [float(x) for x in request.form.values()]
    cf = df[df['quality']>=7]
    
    dict_list = []
    for column, item in zip(columns, items):
        dict_facts={}
        print('\033[1m'+"{}".format(column)+'\033[0m\n')
        column_Q1 = cf[column].quantile(0.25)
        column_Q3 = cf[column].quantile(0.75)
        
        sns.boxplot(x= cf[column])
        plt.annotate( "Your\n Wine",(item,0),weight='bold', textcoords='data',xytext=(item-((cf[column].max()-cf[column].min())/10), 0), arrowprops=dict(facecolor='red', shrink=0.05),va='center', ha='right')
        plt.savefig('static/images/plot{column}.png'.format(column=column))
        plt.close()

        intro = 'Most of good wines have their {} between {} and {}\n'.format(column,column_Q1, column_Q3)
    
        if item < column_Q1:
            duo = 'Your wine has a {} of {}, it is less than most of good wines have\n\n'.format(column, item)
        elif item >= column_Q1 and item <= column_Q3:
            duo = 'Your wine has a {} of {}, it is exactly within the range of good wines\n\n'.format(column, item)
        elif item > column_Q3:
            duo = 'Your wine has a {} of {}, it is more than most of good wines have\n\n'.format(column, item)
        dict_facts= {"plot":'static/images/plot{column}.png'.format(column=column), "intro": intro, "duo": duo}
        dict_list.append(dict_facts)    

    return render_template('facts2.html', prediction_text='{}'.format(text),dict_list = dict_list)

@app.route('/results',methods=['POST'])
def results():

    data = request.get_json(force=True)
    prediction = model.predict([np.array(list(data.values()))])

    output = prediction[0]
    return jsonify(output)

if __name__ == "__main__":
    app.run(debug=True)