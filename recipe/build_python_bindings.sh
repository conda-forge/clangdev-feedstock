#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

mkdir -p "${SP_DIR}"
cp -r clang/bindings/python/clang "${SP_DIR}"
