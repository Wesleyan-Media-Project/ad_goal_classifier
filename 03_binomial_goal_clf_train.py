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

results_dir = 'performance'

train = pd.read_csv('data/train.csv', names = ['ad_id', 'text', 'DONATE', 'CONTACT', 'PURCHASE', 'GOTV', 'EVENT', 'POLL', 'GATHERINFO', 'LEARNMORE', "PRIMARY_PERSUADE"])
test = pd.read_csv('data/test.csv', names = ['ad_id', 'text', 'DONATE', 'CONTACT', 'PURCHASE', 'GOTV', 'EVENT', 'POLL', 'GATHERINFO', 'LEARNMORE', "PRIMARY_PERSUADE"])

model_name = 'rf'

goals = ["DONATE", "CONTACT", "PURCHASE", "GOTV", "EVENT", "POLL", "GATHERINFO", "LEARNMORE", "PRIMARY_PERSUADE"]

for g in goals:
  
  clf_rf = Pipeline([('vect', CountVectorizer()),
                    ('tfidf', TfidfTransformer()),
                    ('cal', CalibratedClassifierCV(RandomForestClassifier(n_estimators=500, random_state=123), cv=2, method="sigmoid"),)
])

  clf_rf.fit(train['text'], train[g])
  predicted = clf_rf.predict(test['text'])
  
  #print(metrics.classification_report(test[g], predicted))
  
  df_perf = pd.DataFrame(metrics.precision_recall_fscore_support(test[g], predicted))
  df_perf.index = ['Precision', 'Recall', 'F-Score', 'Support']
  df_perf.to_csv(results_dir + "/" + model_name + "/" + g + '.csv')
  
  # Save model to disk
  dump(clf_rf, 'models/goal_rf_' + g + '.joblib')

