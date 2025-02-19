#!/bin/bash
set -x

docker compose down
docker compose up app test_transcribe | tee ./dlogs.txt
# python3 ./load_model.py

# docker build .
