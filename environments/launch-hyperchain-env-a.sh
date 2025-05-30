#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Set uo chain A
docker compose -f $SCRIPT_DIR/compose-hyperchain-a.yaml --env-file=$SCRIPT_DIR/compose-hyperchain-a.env build
docker compose -f $SCRIPT_DIR/compose-hyperchain-a.yaml --env-file=$SCRIPT_DIR/compose-hyperchain-a.env up