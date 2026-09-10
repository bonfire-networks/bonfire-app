#!/bin/sh
set -eu

script=$(cd "$(dirname "$0")/../.." && pwd)/prepare-flavour-theme.sh
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
cd "$fixture"

mkdir -p extensions/example/themes deps/example/themes
printf 'local theme\n' > extensions/example/themes/theme.css
printf 'dependency theme\n' > deps/example/themes/theme.css

sh "$script" example
cmp extensions/example/themes/theme.css assets/css/current_flavour_theme.css

rm extensions/example/themes/theme.css
sh "$script" example deps/bonfire_ui_common/assets/css/current_flavour_theme.css
cmp deps/example/themes/theme.css deps/bonfire_ui_common/assets/css/current_flavour_theme.css

sh "$script" no-theme deps/bonfire_ui_common/assets/css/current_flavour_theme.css
test ! -s deps/bonfire_ui_common/assets/css/current_flavour_theme.css

sh "$script" no-theme
test ! -s assets/css/current_flavour_theme.css
printf 'Theme preparation: local source, dependency source, Docker destination, and stale-file clearing passed.\n'
