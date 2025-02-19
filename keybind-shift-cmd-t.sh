#!/bin/bash
set -x

docker compose up --build | tee ./dlogs.txt
# python3 ./load_model.py

# docker build .
