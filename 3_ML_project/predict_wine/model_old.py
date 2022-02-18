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

df = pd.read_csv('winequality-red.csv')
df["good"] = 0
df.loc[df["quality"] > 6.5, "good"] = 1

df_fe = df.copy()
log_feats = ["residual sugar", "free sulfur dioxide", "total sulfur dioxide", "alcohol"]

for feat in log_feats:
    df_fe['{}_log'.format(feat)] = np.log1p(df_fe[feat].values)

z_scores = stats.zscore(df_fe)

abs_z_scores = np.abs(z_scores)
filtered_entries = (abs_z_scores < 3).all(axis=1)
df_out_fe = df_fe[filtered_entries]

y = df_out_fe.good
X = df_out_fe[["alcohol", "sulphates", "volatile acidity", "total sulfur dioxide", "citric acid", "pH", "density"]]


X_train_fe, X_test_fe, y_train_fe, y_test_fe = train_test_split(X, y, test_size=0.3, stratify = df_out_fe.good, random_state=0)

scaler = StandardScaler()
# scaler.fit(X_train_fe)

X_train_fe_std = scaler.fit_transform(X_train_fe)
X_test_fe_std = scaler.fit_transform(X_test_fe)

model_RF_fe = RandomForestClassifier(random_state=12, class_weight="balanced", criterion="gini", max_features=0.9, 
                                       n_estimators=100, min_samples_split=45, min_samples_leaf=1, 
                                       max_leaf_nodes=25)

model_RF_fe.fit(X_train_fe_std, y_train_fe)
y_pred_RF_fe = model_RF_fe.predict(X_test_fe_std)
print("Raport klasyfikacyjny: \n", classification_report(y_test_fe, y_pred_RF_fe, zero_division=1))

Pkl_Filename = "Pickle_RF_Model.pkl"  
with open(Pkl_Filename, 'wb') as file:  
    pickle.dump(model_RF_fe, file)

with open(Pkl_Filename, 'rb') as file:  
    Pickled_RF_Model = pickle.load(file)

# score = Pickled_RF_Model.score(X_test_fe_std, y_test_fe)  
# print("Test score: {0:.2f} %".format(100 * score))  
Ypredict = Pickled_RF_Model.predict(X_test_fe_std)  
print(Pickled_RF_Model.predict([[11, 0.5, 0.7, 50.0, 0.0, 3.5, 0.99]]))

# if Ypredict == 0:
#     print('Bad wine')
# else:
#     print('Good wine')