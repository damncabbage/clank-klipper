#!/usr/bin/env bash

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" && pwd)

set -e
set -u
set -x

ln -rs extras/led_effect/src/led_effect.py repo/klippy/extras/
