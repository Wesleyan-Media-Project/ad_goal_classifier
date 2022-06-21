# ad_goal_classifier

## Pipeline
01 prepare_fbel.R -- clean up the data
02 create_training_data.py -- 80/20 train test split
03 binomial_goal_clf_train.py -- train a random forest model for every goal type and assess performance
04 prepare_inference_set.R -- clean up the Google and Facebook inference data
05 binomial_goal_clf_inference_google.py -- load the saved classifier and apply it to the Google inference set
06 binomial_goal_clf_inference_fb_118m.py -- load the saved classifier and apply it to the Facebook inference set
07 binomial_goal_clf_inference_tv.py -- load the saved classifier and apply it to the TV inference set