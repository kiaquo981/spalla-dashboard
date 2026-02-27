#!/bin/bash
set -a
source .env
set +a
python3 14-APP-server.py 8888
