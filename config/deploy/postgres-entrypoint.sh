#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Normalize SCRIPT_DIR to avoid double slashes when it's root
[[ "$SCRIPT_DIR" == "/" ]] && SCRIPT_DIR=""

# Configuration via environment variables
POSTGRES_CONF_PATH="${POSTGRES_CONF_PATH:-/var/lib/postgresql/data/postgresql.auto.conf}"
POSTGRES_START_CMD="${POSTGRES_START_CMD:-docker-entrypoint.sh postgres}"

# Check if envsubst is available, if not, load our bash implementation
if ! command -v envsubst &> /dev/null; then
  echo "PostgreSQL: envsubst not found, using pure bash fallback..."
  source "${SCRIPT_DIR}/bash-envsubst.sh"
fi

echo "PostgreSQL: Generating optimized configuration..."

# Generate and evaluate the ENV vars (only sets values that aren't already set)
eval "$(bash "${SCRIPT_DIR}/postgres-tune.sh")"

echo "PostgreSQL: Configuration values:"
echo "  Profile: ${PG_DB_TYPE:-oltp}"
echo "  Max Connections: ${PG_MAX_CONNECTIONS}"
echo "  Shared Buffers: ${PG_SHARED_BUFFERS_MB}MB"
echo "  Effective Cache: ${PG_EFFECTIVE_CACHE_SIZE_MB}MB"
echo "  Work Mem: ${PG_WORK_MEM_KB}kB"
echo "  Max Workers: ${PG_MAX_WORKER_PROCESSES}"

# Filter out comments and blank lines for cleaner output
config=$(envsubst < "${SCRIPT_DIR}/postgres.conf.tmpl" | grep -v '^\s*#' | grep -v '^\s*$')

# Get the directory for the config file
CONF_DIR="$(dirname "${POSTGRES_CONF_PATH}")"

echo "=========================================="
echo "$config"
echo "=========================================="

# Check if we can write to the config location
if mkdir -p "${CONF_DIR}" 2>/dev/null; then
  # Write the processed config
  echo "$config" > "${POSTGRES_CONF_PATH}"
  echo "PostgreSQL: Configuration generated at ${POSTGRES_CONF_PATH}"
  
  # Check if we should start postgres
  if [[ -n "${POSTGRES_START_CMD}" && "${POSTGRES_START_CMD}" != "none" ]]; then
    # Start PostgreSQL - postgresql.auto.conf is automatically loaded from data dir
    exec ${POSTGRES_START_CMD}
  else
    echo "PostgreSQL: Skipping startup (POSTGRES_START_CMD is '${POSTGRES_START_CMD}')"
    exit 0
  fi
else
  echo "WARNING: Cannot write to ${CONF_DIR}"
  echo "To use this config, save it to a file and start postgres with: postgres -c config_file=/path/to/postgresql.conf"
  exit 1
fi
