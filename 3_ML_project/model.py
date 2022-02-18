import pandas as pd
import numpy as np
from scipy import stats
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
from imblearn.over_sampling import SMOTE
from sklearn.ensemble import RandomForestClassifier
import pickle

# Data import
df = pd.read_csv('winequality-red.csv')

# Feature Engineering
df["good"] = 0
df.loc[df["quality"] > 6.5, "good"] = 1

log_feats = ["residual sugar", "free sulfur dioxide", "total sulfur dioxide", "alcohol"]

for feat in log_feats:
    df['{}_log'.format(feat)] = np.log1p(df[feat].values)

z_scores = stats.zscore(df)
abs_z_scores = np.abs(z_scores)
filtered_entries = (abs_z_scores < 3).all(axis=1)
df_out = df[filtered_entries]

df_imp = df_out.drop(['chlorides', 'free sulfur dioxide_log', 'free sulfur dioxide', 'density', 'fixed acidity'], axis=1)

# Separating X and y
X = df_imp.drop(["quality", "good"], axis=1)
y = df_imp.good

# Data spliting
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, stratify = df_imp.good, random_state=0)

# Oversampling
over_strategy = SMOTE(random_state=20)

X_combined, y_combined = over_strategy.fit_resample(X_train, y_train)

# Building the model - RandomForestClassifier
model = RandomForestClassifier(random_state=12, class_weight="balanced_subsample", criterion="entropy", 
                                       max_features=0.8, max_leaf_nodes=60, min_samples_split=5, n_estimators=70)

model.fit(X_combined, y_combined)

# Prediction

y_pred = model.predict(X_test)
print("Raport klasyfikacyjny: \n", classification_report(y_test, y_pred, zero_division=1))

# Saving the model

pickle.dump(model, open('wine_model.pkl', 'wb'))