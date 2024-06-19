# CREATIVE --- Ad Goal Classifier

Welcome! This repo contains scripts for training a machine learning model for political ad goal classification (e.g., donate, contact, or get-out-the-vote).

This repo is part of the [Cross-platform Election Advertising Transparency Initiative (CREATIVE)](https://www.creativewmp.com/). CREATIVE is an academic research project that has the goal of providing the public with analysis tools for more transparency of political ads across online platforms. In particular, CREATIVE provides cross-platform integration and standardization of political ads collected from Google and Facebook. CREATIVE is a joint project of the [Wesleyan Media Project (WMP)](https://mediaproject.wesleyan.edu/) and the [privacy-tech-lab](https://privacytechlab.org/) at [Wesleyan University](https://www.wesleyan.edu).

To analyze the different dimensions of political ad transparency we have developed an analysis pipeline. The scripts in this repo are part of the Data Classification step in our pipeline.

![A picture of the repo pipeline with this repo highlighted](Creative_Pipelines.png)

Some scripts in this repo require datasets from the [datasets repo](https://github.com/Wesleyan-Media-Project/datasets) (which contains datasets that are not created in any of the CREATIVE repos and intended to be used in more than one CREATIVE repo) and others require scripts from the [fb_2020 repo](https://github.com/Wesleyan-Media-Project/fb_2020), the [data-post-production repo](https://github.com/Wesleyan-Media-Project/data-post-production), and the [google_2020 repo](https://github.com/Wesleyan-Media-Project/google_2020). Some csv files in those repos are too large to be uploaded to GitHub. You can download them through our Figshare page.

These additional repos are assumed to be cloned into the same folder as the ad_goal_classifier repo.

## Table of Contents

- [1. Overview](#1-overview)
- [2. Setup](#2-setup)
- [3. Results Storage](#3-results-storage)
- [4. Training Data](#4-training-data)
- [5. Thank You](#5-thank-you)

## 1. Overview

The ads that the model is run on are categorized into the following goals: donate, contact, purchase, get-out-the-vote (GOTV), event, poll, gather info, learn more, and persuade.

The model is trained on 2020 Facebook data labeled by the WMP, and it can be applied to 2020 and 2022, Facebook, Google, and TV ads.

## 2. Setup

This repo contains eight R scripts and eight Python scripts that are of interest. The scripts are numbered in the order in which they should be run. Scripts that directly depend on one another are ordered sequentially. Scripts with the same number are alternatives, usually they are the same scripts to be run on different data or with minor variations. The outputs of each script are saved, so it is possible to, for example, only run the inference script, since the model files are already present. There are also some additional scripts present, which will be discussed in the setup section.

For an example pipeline, training on 2020 Facebook, and then doing inference on 2022 Facebook data, see `pipeline_2022.sh`. This task should take about 20 minutes to run on a laptop.

Some scripts require datasets from the [datasets repo](https://github.com/Wesleyan-Media-Project/datasets) (which contains datasets that are not created in any of the repos and intended to be used in more than one repo). That repo is assumed to be cloned into the same top-level folder as the ad_goal_classifier repo. Some parts of the data in the datasets repo include TV data. Due to contractual reasons, users must apply directly to receive raw TV data. Visit <http://mediaproject.wesleyan.edu/dataaccess/> and fill out the online request form for accessing TV data.

### 2.1 Install R and Packages

To run the scripts in this repo install R and the scripts required packages:

1. First, make sure you have R installed. While R can be run from the terminal, many people find it easier to use RStudio along with R. Here is a [tutorial for setting up R and RStudio](https://rstudio-education.github.io/hopr/starting.html). We tested our scripts with R v4.0.1.

2. Next, make sure you have the following packages installed in R (the exact version we used of each package is listed in the [requirements_r.txt file](https://github.com/Wesleyan-Media-Project/ad_goal_classifier/blob/main/requirements_r.txt)). You can the packages install by calling:

   ```R
   install.packages('data.table')
   install.packages("stringr")
   install.packages("stringi")
   install.packages("dplyr")
   install.packages("tidyr")
   ```

3. In order to successfully run each R script you must first set your working directory. You can do so by adding the line `setwd("your/working/directory")` to the top of the R scripts, replacing `"your/working/directory"` with whatever directory you are running from. Additionally, make sure that the locations to which you are retrieving input files and/or sending output files are accurate.

### 2.2 Install Python and Packages

1. First, make sure you have [Python](https://www.python.org/) installed. The scripts use Python (3.9.16).

2. In addition, make sure you have the following packages installed in Python (the exact version we used of each package is listed in the [requirements_r.txt file](https://github.com/Wesleyan-Media-Project/ad_goal_classifier/blob/main/requirements_py.txt)). You can install by running the following in your command-line:

   ```bash
   pip install pandas
   pip install scikit-learn
   pip install numpy
   pip install joblib
   pip install tqdm
   ```

### 2.3 Download Files Needed

In order to use the scripts in this repo, you will need to clone download the repo into a top level folder. If you have Git installed, you can do so by running the following command from your terminal:

```bash
git clone https://github.com/Wesleyan-Media-Project/ad_goal_classifier.git
```

Otherwise, you can download the repo as a ZIP file from GitHub.

In addition, depending on which scripts you are running, additional repos will be necessary.

- 04_prepare_118m.R, 05_binomial_goal_clf_inference_tv.py 06_prepare_tv_validation.R, 99_house_in_state_fb_2022.R, and 99_senators_in_state_fb_2022.R all require the [datasets repo](https://github.com/Wesleyan-Media-Project/datasets).

  You can clone this repo using the following command:

  ```bash
  git clone https://github.com/Wesleyan-Media-Project/datasets.git
  ```

- 04_prepare_140m.R requires the [fb_2020 repo](https://github.com/Wesleyan-Media-Project/fb_2020). The specific file it requires `fb_2020_140m_adid_text_clean.csv.gz` will be hosted on Figshare.

- 04_prepare_fb2022.Rand 04_prepare_google_2022.R require the [data-post-production repo](https://github.com/Wesleyan-Media-Project/data-post-production).

  You can clone this repo using the following command:

  ```bash
  git clone https://github.com/Wesleyan-Media-Project/data-post-production.git
  ```

- 04_prepare_google_2020.R requires the [google_2020 repo](https://github.com/Wesleyan-Media-Project/google_2020).

  You can clone this repo using the following command:

  ```bash
  git clone https://github.com/Wesleyan-Media-Project/google_2020.git
  ```

### 3.4 Run Scripts

Depending on what you want to do, you will be running different scripts.

In order to execute a Python script you can run the following command from your terminal from within the directory of the script replacing `file.py` with the file name of the script you want to run:

```bash
python3 file.py
```

In order to execute an R script you can run the following command from your terminal from within the directory of the script replacing `file.R` with the file name of the script you want to run:

```bash
Rscript file.R
```

Note that the output of each script is saved, so it is possible to, for example, only run the inference script, since the model files are already present.

`01_prepare_fbel.R` is preparing training data and `02_create_training_data.py` and `03_binomial_goal_clf_train.py` are both creating training data. Script 02 contains an 80/20 train/test split. Script 03 trains the data on the training set, and also records performance on the test set. Performance scores for each goal are saved in `performance/rf/`.

The scripts that begin with 04 are all alternatives of each other, with each one preparing a different dataset so that it is in the same shape as the training data.

The scripts that begin with 05 are also all alternatives of each other, with each one running inference on a different dataset.

For the scripts that begin with 04 and 05, inferencing which dataset they are being run on can be done from looking at the end of their names. For example, `05_binomial_goal_clf_inference_google_2022.py` is inference on the `data-post-production/google_2022 dataset`. In addition, this information can be seen when looking at the scripts' input data, which will include a path to the dataset they are referencing.

Scripts beginning with 06 and 07 test whether the model trained on only Facebook ads can also be applied to TV ads. It does so by applying the models to 2020 TV ads labeled by WMP.

Scripts beginning with 11 and 12 are inference scripts for 2020 Facebook and Google electoral candidate ads only.

Scripts beginning with 99 use Facebook's regional distribution to determine the proportion of an ad's monetary spend that goes into an electoral candidate's own state. This information is intended to be used together with the goal classifier to determine, for example, what proportion of donate ads are aimed outside of the candidate's state.

## 3. Results Storage

The output data for the scripts in this repo is in `csv` format, with the path to each specific output being specified under output data when the code itself is looked at. For example, the output data for `05_binomial_goal_clf_inference_fb_118m.py` is stored at `data/ad_goal_rf_fb_128m.csv.gz`. The data for all scripts are stored in the data folder, while the trained models that are created with the `03_binomial_goal_clf_train.py` are in the models folder.

## 4. Training data

The training data is the FBEL dataset. Here is the [codebook](https://drive.google.com/drive/folders/1gx1hDxEON_ck_i49nhbFpGXFCRbCU5bM?usp=share_link) of the dataset.

## 5. Thank You

<p align="center"><strong>We would like to thank our supporters!</strong></p><br>

<p align="center">This material is based upon work supported by the National Science Foundation under Grant Numbers 2235006, 2235007, and 2235008.</p>

<p align="center" style="display: flex; justify-content: center; align-items: center;">
  <a href="https://www.nsf.gov/awardsearch/showAward?AWD_ID=2235006">
    <img class="img-fluid" src="nsf.png" height="150px" alt="National Science Foundation Logo">
  </a>
</p>

<p align="center">The Cross-Platform Election Advertising Transparency Initiative (CREATIVE) is a joint infrastructure project of the Wesleyan Media Project and privacy-tech-lab at Wesleyan University in Connecticut.

<p align="center" style="display: flex; justify-content: center; align-items: center;">
  <a href="https://www.creativewmp.com/">
    <img class="img-fluid" src="CREATIVE_logo.png"  width="220px" alt="CREATIVE Logo">
  </a>
</p>

<p align="center" style="display: flex; justify-content: center; align-items: center;">
  <a href="https://mediaproject.wesleyan.edu/">
    <img src="wmp-logo.png" width="218px" height="100px" alt="Wesleyan Media Project logo">
  </a>
</p>

<p align="center" style="display: flex; justify-content: center; align-items: center;">
  <a href="https://privacytechlab.org/" style="margin-right: 20px;">
    <img src="./plt_logo.png" width="200px" alt="privacy-tech-lab logo">
  </a>
</p>
