#!/usr/bin/env bash

if [ $# -lt 1 ]; then
  echo "Error: At least one argument is required."
  exit 1
fi

MICRO_ARCH=$(python3 -c "import archspec.cpu; print(str(archspec.cpu.host()))");
REPO_PATH="$1/$MICRO_ARCH"

if [ -d "$REPO_PATH" ]; then
  echo "$REPO_PATH exists"
else
  echo "$REPO_PATH does not exist"s
  mkdir -p $REPO_PATH
  ./bootstrap_prefix.sh $REPO_PATH noninteractive
fi
