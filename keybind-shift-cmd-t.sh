#!/bin/bash

/root/miniconda3/bin/conda env create -f ./environment.yml | tee create.log

/root/miniconda3/envs/whisperx/bin/python3 ./load_model.py

# docker build .
