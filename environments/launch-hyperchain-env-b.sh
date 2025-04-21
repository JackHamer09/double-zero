#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Set uo chain B
docker compose -f $SCRIPT_DIR/compose-hyperchain-b.yaml --env-file=$SCRIPT_DIR/compose-hyperchain-b.env build
docker compose -f $SCRIPT_DIR/compose-hyperchain-b.yaml --env-file=$SCRIPT_DIR/compose-hyperchain-b.env up