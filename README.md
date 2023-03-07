# Ad Goal Classifier
Binomial ad goal classifiers, classifying ads into the following goals: Donate, contact, purchase, get-out-the-vote (GOTV), event, poll, gather info, learn more, persuade. Trained on 2020 Facebook data labeled by the WMP. Can be applied to 2020 and 2022, Facebook Google, and TV ads.

## Usage
The scripts are numbered in the order in which they should be run. Scripts that directly depend on one another are ordered sequentially. Scripts with the same number are alternatives, usually they are the same scripts on different data, or with minor variations.

For an example pipeline, training on 2020 Facebook, and then doing inference on 2022 Facebook, see `pipeline.sh`.

## Requirements
The scripts use both R (4.0.1) and Python (3.10.5). The packages we used are described in `requirements_r.txt` and `requirements_py.txt`.

## Details
### Training data
The training data is the FBEL dataset. Its codebook can be found [here](
https://drive.google.com/drive/folders/1gx1hDxEON_ck_i49nhbFpGXFCRbCU5bM?usp=share_link).

### Performance
File 02 contains an 80/20 train/test split. File 03 trains the data on the training set, and also records performance on the test set. Performance scores for each goal are saved in `performance/rf/`.

## Old
01_prepare_fbel.R -- clean up the data  
02_create_training_data.py -- 80/20 train test split  
03_binomial_goal_clf_train.py -- train a random forest model for every goal type and assess performance  
04_binomial_goal_clf_inference_fb_118m.py -- load the saved classifier and apply it to the Facebook inference set  
04_binomial_goal_clf_inference_tv.py -- load the saved classifier and apply it to the TV inference set \

11_prepare_inference_set.R -- clean up the candidate-only Google and Facebook inference data  
12 binomial_goal_clf_inference_google_candidates.py -- load the saved classifier and apply it to the candidate-only Google inference set  
12 binomial_goal_clf_inference_fb_candidates.py -- load the saved classifier and apply it to the candidate-only Facebook inference set \

Full (not just candidates) Google set is still missing. Also, data prerequisites haven't been cleaned up for 11 and 12 yet.