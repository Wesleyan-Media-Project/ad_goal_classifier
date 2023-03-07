# Ad Goal Classifier
Binomial ad goal classifiers, classifying ads into the following goals: Donate, contact, purchase, get-out-the-vote (GOTV), event, poll, gather info, learn more, persuade. Trained on 2020 Facebook data labeled by the WMP. Can be applied to 2020 and 2022, Facebook, Google, and TV ads.

## Usage
The scripts are numbered in the order in which they should be run. Scripts that directly depend on one another are ordered sequentially. Scripts with the same number are alternatives, usually they are the same scripts on different data, or with minor variations. The outputs of each script are saved, so it is possible to, for example, only run the inference script, since the model files are already present.

For an example pipeline, training on 2020 Facebook, and then doing inference on 2022 Facebook, see `pipeline_2022.sh`. This should take about 20 minutes to run on a laptop.

Some scripts require datasets from the datasets repo (which contains datasets that aren't created in any of the repos and intended to be used in more than one repo). That repo is assumed to be cloned into the same top-level folder as the ad_goal_classifier repo.

## Requirements
The scripts use both R (4.0.1) and Python (3.10.5). The packages we used are described in `requirements_r.txt` and `requirements_py.txt`.

## Details
### Training data
The training data is the FBEL dataset. Its codebook can be found [here](
https://drive.google.com/drive/folders/1gx1hDxEON_ck_i49nhbFpGXFCRbCU5bM?usp=share_link).

### Performance
File 02 contains an 80/20 train/test split. File 03 trains the data on the training set, and also records performance on the test set. Performance scores for each goal are saved in `performance/rf/`.

### Other scripts
Scripts 06 and 07 test whether the model trained on only Facebook ads can also be applied to TV ads. It does that by applying the models to 2020 TV ads labeled by the WMP.

Scripts 11 and 12 are inference scripts for 2020 Facebook and Google candidate ads only.

Scripts 99 use Facebook's regional distribution to determine the proportion of an ad's spend that goes into the candidate's own state. This is intended to be used together with the goal classifier to determine, for example, what proportion of donate ads are aimed outside of the candidate's state.

## Todo
There are currently inference scripts for 2020 Facebook, 2022 Facebook, and 2020 TV. For Google, there is only an inference script for 2020 candidate ads. So we're missing 2022 Google entirely, as well as 2022 TV.