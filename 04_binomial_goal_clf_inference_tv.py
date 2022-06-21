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

# Input data
path_tv_data = '../datasets/tv/tv_2020_fed.csv'
dir_models = 'models/goal_rf_'
# Ouput data
path_predictions = 'data/ad_goal_rf_tv_2020_fed.csv'


# Load data
inference = pd.read_csv(path_tv_data)
inference = inference.replace(np.nan, '', regex=True)
inference = inference[['creative', 'google_asr_text']]
inference = inference[inference['google_asr_text'] != ""]

goals = ["DONATE", "CONTACT", "PURCHASE", "GOTV", "EVENT", "POLL", "GATHERINFO", "LEARNMORE", "PRIMARY_PERSUADE"]

for g in goals:

  # Load model
  clf = load(dir_models + g + '.joblib')
  
  # Apply clf
  predicted_prob = clf.predict_proba(inference['google_asr_text'])
  predicted = np.argmax(predicted_prob, axis=1)
  
  inference['goal_'+g+'_prediction'] = predicted
  inference['goal_'+g+'_predicted_prob'] = predicted_prob[:,1]
  
# Make a column with the largest probability
inference['goal_highest_prob'] = inference[[col for col in inference.columns if "predicted_prob" in col]].idxmax(1)
inference['goal_highest_prob'] = inference['goal_highest_prob'].str.replace('_predicted_prob', '')
inference['goal_highest_prob'] = inference['goal_highest_prob'].str.replace('goal_', '')

# Save without text column
inference = inference.drop(['google_asr_text'], 1)  
inference.to_csv(path_predictions, index = False)
