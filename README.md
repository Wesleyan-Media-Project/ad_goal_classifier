# ad_goal_classifier

## Pipeline
01_prepare_fbel.R -- clean up the data \
02_create_training_data.py -- 80/20 train test split \
03_binomial_goal_clf_train.py -- train a random forest model for every goal type and assess performance \
04_binomial_goal_clf_inference_fb_118m.py -- load the saved classifier and apply it to the Facebook inference set \
04_binomial_goal_clf_inference_tv.py -- load the saved classifier and apply it to the TV inference set \

11_prepare_inference_set.R -- clean up the candidate-only Google and Facebook inference data \
12 binomial_goal_clf_inference_google_candidates.py -- load the saved classifier and apply it to the candidate-only Google inference set \
12 binomial_goal_clf_inference_fb_candidates.py -- load the saved classifier and apply it to the candidate-only Google inference set \

Full (not just candidates) Google set is still missing. Also, data prerequisites haven't been cleaned up for 11 and 12 yet.
