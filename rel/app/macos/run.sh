#!/bin/sh
set -euo pipefail

export MIX_ENV=dev

. `dirname $0`/build_app.sh

echo Running $app_dir
open -W --stdout `tty` --stderr `tty` $app_dir
