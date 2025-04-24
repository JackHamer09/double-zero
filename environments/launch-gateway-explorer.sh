#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Set uo chain B
docker compose -f $SCRIPT_DIR/compose-gateway-explorer.yaml --env-file=$SCRIPT_DIR/compose-gateway-explorer.env build
docker compose -f $SCRIPT_DIR/compose-gateway-explorer.yaml --env-file=$SCRIPT_DIR/compose-gateway-explorer.env up