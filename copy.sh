#!/bin/bash
set -euo pipefail
set -x

target_dir="$1"

mkdir -p "$target_dir/.themes/tanqua"
rsync -av --delete ./tanqua/ "$target_dir/.themes/tanqua/"
cp -vf ./tanqua.lua "$target_dir/.themes/tanqua.lua"
