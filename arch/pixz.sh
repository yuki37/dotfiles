#!/bin/bash

set -eu
DESCRIPTION='compression software with progress bar'

if (( $# > 0 )) && [ "$1" = 'description' ];then
  echo "$DESCRIPTION"
  exit 0
fi

sudo pacman -S --noconfirm pixz pv

