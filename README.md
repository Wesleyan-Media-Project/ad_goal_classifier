# Wesleyan Media Project - Ad Goal Classifier

Welcome! This repo is part of the Cross-platform Election Advertising Transparency initiatIVE (CREATIVE) project. CREATIVE is a joint infrastructure project of WMP and privacy-tech-lab at Wesleyan University. CREATIVE provides cross-platform integration and standardization of political ads collected from Google and Facebook.

This repo is part of the Final Data Classification section.

Some scripts in this repo require datasets from the [datasets repo](https://github.com/Wesleyan-Media-Project/datasets) (which contains datasets that aren't created in any of the repos and intended to be used in more than one repo) and others require scripts from the [fb_2020 repo](https://github.com/Wesleyan-Media-Project/fb_2020), the [data-post-production repo](https://github.com/Wesleyan-Media-Project/data-post-production), and the [google_2020 repo](https://github.com/Wesleyan-Media-Project/google_2020). Some csv files in those repos are too large to be uploaded to GitHub. You can download them through our Figshare page.

These additional repos are assumed to be cloned into the same folder as the ad_goal_classifier repo.

[A picture of the repo pipeline with this repo highlighted] https://mediaproject.wesleyan.edu/wp-content/uploads/2023/08/wmp_pipeline_051123_v2_circle.png

## Table of Contents

- [Introduction](#introduction)

- [Objective](#objective)

- [Data](#data)

- [Setup](#setup)

- [Details](#details)

- [To Do](#todo)

## Introduction

This repository contains a series of scripts that clean and prepare data, train a machine learning model, and apply the trained model to different data sets for inference. The ads it is run on are classified into the following goals: donate, contact, purchase, get-out-the-vote (GOTV), event, poll, gather info, learn more, persuade.

The model is trained on 2020 Facebook data labeled by the WMP and it can be applied to 2020 and 2022, Facebook, Google, and TV ads.

## Objective

Each of our repos belongs to one or more of the the following categories:

- Data Collection
- Data Storage & Processing
- Preliminary Data Classification
- Final Data Classification

This repo is part of the Final Data Classification section.

## Data

The output data for the scripts in this repo is in a csv format, with the path to each specific output being specified under output data when the code itself is looked at. For example, the output data for /05_binomial_goal_clf_inference_fb_118m.py is stored at 'data/ad_goal_rf_fb_128m.csv.gz'. The data for files that begin with 1-2 and those begining with 4+ is stored in the data folder, while that for files begining with 3 is stored in the models folder.

## Setup

This repo contains eight R files and eight Python files that are of interest. The scripts are numbered in the order in which they should be run. Scripts that directly depend on one another are ordered sequentially. Scripts with the same number are alternatives, usually they are the same scripts on different data, or with minor variations. The outputs of each script are saved, so it is possible to, for example, only run the inference script, since the model files are already present. There are also some additional scripts present, which will be discussed in the setup and details sections.

For an example pipeline, training on 2020 Facebook, and then doing inference on 2022 Facebook, see `pipeline_2022.sh`. This should take about 20 minutes to run on a laptop.

Some scripts require datasets from the datasets repo (which contains datasets that aren't created in any of the repos and intended to be used in more than one repo). That repo is assumed to be cloned into the same top-level folder as the ad_goal_classifier repo. Some parts of the data in the datasets repo include the TV data. Due to contractual reasons, users must apply directly to receive raw TV data. Visit http://mediaproject.wesleyan.edu/dataaccess/ and fill out the online request form to access the TV datasets.

In order to use this directory, you must

### 1. Install R and Packages

First, make sure you have R installed. In addition, while R can be run from the terminal, many people find it much easier to use r-studio along with R. <br>
https://rstudio-education.github.io/hopr/starting.html
<br>
Here is a link that walks you through downloading and using both programs. <br>
The scripts use R (4.0.1).
<br>
Next, make sure you have the following packages installed in R (the exact version we used of each package is listed [in the requirements_r.txt file)](https://github.com/Wesleyan-Media-Project/ad_goal_classifier/blob/main/requirements_r.txt) : <br>
data.table <br>
stringr <br>
stringi <br>
dplyr <br>
tidyr <br>

### 2. Install Python and Packages

Next, make sure you have [Python](https://www.python.org/) installed.
<br>
The scripts use Python (3.9.16).
<br>
In addition, make sure you have the following packages installed in Python (the exact version we used of each package is listed [in the requirements_r.txt file)](https://github.com/Wesleyan-Media-Project/ad_goal_classifier/blob/main/requirements_py.txt)) : <br>
pandas <br>
scikit-learn <br>
numpy <br>
joblib <br>
tqdm <br>

### 3. Download Files Needed

In order to use the scripts in this repo, you will need to download the repository into a top level folder. In addition, depending on which scripts you are running, additional repositories will also be necessary. Specifically which repositories are needed depends on which script you are executing.

04_prepare_118m.R, 05_binomial_goal_clf_inference_tv.py 06_prepare_tv_validation.R, 99_house_in_state_fb_2022.R, and 99_senators_in_state_fb_2022.R all require the [datasets repo](https://github.com/Wesleyan-Media-Project/datasets)

04_prepare_140m.R requires the [fb_2020 repo](https://github.com/Wesleyan-Media-Project/fb_2020). The specific file it requires `fb_2020_140m_adid_text_clean.csv.gz` will be hosted on Figshare.

04_prepare_fb2022.R requires the [data-post-production repo](https://github.com/Wesleyan-Media-Project/data-post-production).

04_prepare_google_2020.R requires the [google_2020 repo](https://github.com/Wesleyan-Media-Project/google_2020).

04_prepare_google_2022.R requires the [data-post-production repo](https://github.com/Wesleyan-Media-Project/data-post-production).

### 4. Run Files

Depending on what you are doing, you will run different files.

Remember that the outputs of each script are saved, so it is possible to, for example, only run the inference script, since the model files are already present.

01_prepare_fbel.R is preparing training data and 02_create_training_data.py and 03_binomial_goal_clf_train.py are both creating training data. File 02 contains an 80/20 train/test split. File 03 trains the data on the training set, and also records performance on the test set. Performance scores for each goal are saved in performance/rf/.

The files that begin with 04 are all alternatives of each other, with each one preparing a different data set so that it is in the same shape as the training data.

The files that begin with 05 are also all alternatives of each other, with each one running inference on a different data set.

For the files that begin with 04 and 05, inferencing which data set they are being run on can be done from looking at the end of their names. For example, /05_binomial_goal_clf_inference_google_2022.py is inference on the data-post-production/google_2022 dataset. In addition, this can be seen when looking at their input data, which will include a path to the data set they are referencing.

Scripts 06 and 07 test whether the model trained on only Facebook ads can also be applied to TV ads. It does that by applying the models to 2020 TV ads labeled by the WMP.

Scripts 11 and 12 are inference scripts for 2020 Facebook and Google candidate ads only.

Scripts 99 use Facebook's regional distribution to determine the proportion of an ad's spend that goes into the candidate's own state. This is intended to be used together with the goal classifier to determine, for example, what proportion of donate ads are aimed outside of the candidate's state.

## Details

### Training data

The training data is the FBEL dataset. Its codebook can be found [here](https://drive.google.com/drive/folders/1gx1hDxEON_ck_i49nhbFpGXFCRbCU5bM?usp=share_link).

## Todo

This said "We're currently missing 2022 Google entirely, as well as 2022 TV." I believe Google 2022 is now uploaded, and am not sure about 2022 TV. ASK
