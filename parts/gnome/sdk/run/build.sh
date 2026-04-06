#!/bin/bash
set -euo pipefail
source /home/ivo-xavier/Documentos/GitHub/year-progress/parts/gnome/sdk/run/environment.sh
set -x
make -j"4" GPU_WRAPPER=gpu-2404-wrapper
make -j"4" install GPU_WRAPPER=gpu-2404-wrapper DESTDIR="/home/ivo-xavier/Documentos/GitHub/year-progress/parts/gnome/sdk/install"
