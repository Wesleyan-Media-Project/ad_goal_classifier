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
from tqdm import tqdm

# Input data
path_google_2020 = 'data/google_2020_prepared.csv.gz'
dir_models = 'models/goal_rf_'
# Ouput data
path_predictions_gz = 'data/ad_goal_rf_google_2020.csv.gz'

# Load data
inference = pd.read_csv(path_google_2020)

goals = ["DONATE", "CONTACT", "PURCHASE", "GOTV", "EVENT", "POLL", "GATHERINFO", "LEARNMORE", "PRIMARY_PERSUADE"]

for g in tqdm(goals):

  # Load model
  clf = load(dir_models + g + '.joblib')
  
  # Apply clf
  predicted_prob = clf.predict_proba(inference['text'])
  predicted = np.argmax(predicted_prob, axis=1)
  
  inference['goal_'+g+'_prediction'] = predicted
  inference['goal_'+g+'_predicted_prob'] = predicted_prob[:,1]
  
# Make a column with the largest probability
inference['goal_highest_prob'] = inference[[col for col in inference.columns if "predicted_prob" in col]].idxmax(1)
inference['goal_highest_prob'] = inference['goal_highest_prob'].str.replace('_predicted_prob', '')
inference['goal_highest_prob'] = inference['goal_highest_prob'].str.replace('goal_', '')

# Save without text column
inference = inference.drop(['text'], 1)  
inference.to_csv(path_predictions_gz, index = False)
