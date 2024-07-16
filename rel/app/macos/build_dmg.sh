#!/bin/sh
set -euo pipefail

export MIX_ENV=prod

. `dirname $0`/build_app.sh
. $ELIXIRKIT_MIX_PATH/elixirkit_swift/Scripts/build_macos_dmg.sh
