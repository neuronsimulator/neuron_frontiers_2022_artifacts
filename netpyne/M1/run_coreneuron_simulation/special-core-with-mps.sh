#!/bin/bash
#enable mps
nvidia-cuda-mps-control -d > /dev/null 2>&1
dplace special-core "$@"
