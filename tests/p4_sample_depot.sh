#!/bin/bash

# https://portal.perforce.com/s/article/2439

P4_SAMPLE_DEPOT_URL="https://ftp.perforce.com/perforce/tools/sampledepot.tar.gz"

BASE_DIR="$HOME/p4checkout_test"
PORT=1492
P4_PORT=localhost:$PORT

P4_WS_ROOT="$BASE_DIR/workspaces"

pid=$(pgrep -f "p4d.*$PORT")

if [ -n "$pid" ]; then
  # If a matching process is found, terminate it
  echo "Killing p4d process with PID $pid"
  kill "$pid"
fi

cd ~
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"
mkdir -p "$P4_WS_ROOT"
cd "$BASE_DIR"

wget --quiet --show-progress "$P4_SAMPLE_DEPOT_URL"
if [ $? -eq 0 ]; then
    echo "Download successful"
else
    echo "Download failed"
    exit 1
fi

gunzip sampledepot.tar.gz
tar xvf sampledepot.tar 

P4_ROOT="$BASE_DIR/PerforceSample"

p4d -r "$P4_ROOT" -jr "$P4_ROOT/checkpoint"
cd "$P4_ROOT"
p4d -r . -xu
cd ..

p4d -r "$P4_ROOT" -p $PORT &

sleep 10

WS_NAME="bruno_jam"
WS_DIR="$P4_WS_ROOT/bruno_ws"

p4 -p "$P4_PORT" client -o "$WS_NAME" | sed "/^Root:/c\Root: $WS_DIR" | p4 -p "$P4_PORT" client -i
p4 -p "$P4_PORT" clients | grep bruno

p4 -p "$P4_PORT" -c "$WS_NAME" sync

ps | grep p4d