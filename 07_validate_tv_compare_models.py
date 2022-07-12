import sklearn.model_selection as ms
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestClassifier
from sklearn.calibration import CalibratedClassifierCV
from sklearn import metrics
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
import pandas as pd
import numpy as np
from joblib import dump, load

#----
# All fields

# Input data
path_tv_data = 'data/tv_validation_data.csv.gz'
dir_models = 'models/goal_rf_'

# Load data
inference = pd.read_csv(path_tv_data)
inference = inference.replace(np.nan, '', regex=True)

goals = ["DONATE", "CONTACT", "PRIMARY_PERSUADE"]

for g in goals:

  # Load model
  clf = load(dir_models + g + '.joblib')
  
  # Apply clf
  predicted_prob = clf.predict_proba(inference['google_asr_text'])
  predicted = np.argmax(predicted_prob, axis=1)
  
  inference['goal_'+g+'_prediction'] = predicted
  inference['goal_'+g+'_predicted_prob'] = predicted_prob[:,1]
  
print(metrics.classification_report(inference['PERSUADE'], inference['goal_PRIMARY_PERSUADE_prediction']))
print(metrics.classification_report(inference['DONATE'], inference['goal_DONATE_prediction']))
print(metrics.classification_report(inference['LEGISLATOR'], inference['goal_CONTACT_prediction']))

#----
# Acb only

# Input data
path_tv_data = 'data/tv_validation_data.csv.gz'
dir_models = 'models/acb_only/goal_rf_'

# Load data
inference = pd.read_csv(path_tv_data)
inference = inference.replace(np.nan, '', regex=True)

goals = ["DONATE", "CONTACT", "PRIMARY_PERSUADE"]

for g in goals:

  # Load model
  clf = load(dir_models + g + '.joblib')
  
  # Apply clf
  predicted_prob = clf.predict_proba(inference['google_asr_text'])
  predicted = np.argmax(predicted_prob, axis=1)
  
  inference['goal_'+g+'_prediction'] = predicted
  inference['goal_'+g+'_predicted_prob'] = predicted_prob[:,1]
  
print(metrics.classification_report(inference['PERSUADE'], inference['goal_PRIMARY_PERSUADE_prediction']))
print(metrics.classification_report(inference['DONATE'], inference['goal_DONATE_prediction']))
print(metrics.classification_report(inference['LEGISLATOR'], inference['goal_CONTACT_prediction']))
