#!/usr/bin/env bash
# Sourced by GOW's root entrypoint before Steam starts.
set -e

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=/opt/wolf-gale/python \
    /usr/bin/python3 /opt/wolf-gale/configure-gale.py /home/retro \
    --uid "${PUID:-1000}" --gid "${PGID:-1000}"
