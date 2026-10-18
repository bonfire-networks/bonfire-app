#!/bin/sh
set -eu

flavour=${1:?Usage: prepare-flavour-theme.sh FLAVOUR [DESTINATION]}
destination=${2:-assets/css/current_flavour_theme.css}

mkdir -p "$(dirname "$destination")"
for source in "extensions/$flavour/themes/theme.css" "deps/$flavour/themes/theme.css"; do
    if [ -f "$source" ]; then
        cp "$source" "$destination" && echo "Copied flavour theme from $source to $destination" && exit 0
    else
        echo "No theme found for flavour $flavour at $source"
    fi
done

# Clear the previous flavour even when the selected flavour has no named themes.
: > "$destination"
