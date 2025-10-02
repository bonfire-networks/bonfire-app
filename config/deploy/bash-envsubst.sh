#!/usr/bin/env bash
# Pure bash implementation of envsubst for environments where it's not available
# This provides a fallback when the native envsubst command (from gettext package) is missing

# Function: envsubst
# Reads from stdin and replaces ${VAR_NAME} patterns with environment variable values
# Usage: envsubst < template_file > output_file
envsubst() {
  local line
  while IFS= read -r line; do
    # Replace all ${VAR} patterns in the line
    # This regex finds ${...} patterns and replaces them with the variable value
    while [[ "$line" =~ \$\{([^}]+)\} ]]; do
      local var_name="${BASH_REMATCH[1]}"
      local var_value="${!var_name:-}"
      # Replace the first occurrence
      line="${line/\$\{${var_name}\}/${var_value}}"
    done
    echo "$line"
  done
}
