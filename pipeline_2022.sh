#!/bin/bash

# Training on 2020
R CMD BATCH --no-environ --no-save 01_prepare_fbel.R
python 02_create_training_data.py
python 03_binomial_goal_clf_train.py
# Inference on 2022
R CMD BATCH --no-environ --no-save 04_prepare_fb2022.R
python 05_binomial_goal_clf_inference_fb_2022.py