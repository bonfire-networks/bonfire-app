#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Normalize SCRIPT_DIR to avoid double slashes when it's root
[[ "$SCRIPT_DIR" == "/" ]] && SCRIPT_DIR=""

# Configuration via environment variables
# The tuned config is a standalone config_file OUTSIDE the data dir, so it never shares postgresql.auto.conf with `ALTER SYSTEM`. Bonfire's InstanceTuning clears its own ALTER SYSTEM writes on every app boot (`ALTER SYSTEM RESET`), which wiped the tuner's values when both lived in auto.conf. Now RESET falls back to this file, and admin ALTER SYSTEM values survive restarts. Outside the data dir also keeps a fresh volume empty for initdb.
# POSTGRES_CONF_PATH="${POSTGRES_CONF_PATH:-/var/lib/postgresql/data/postgresql.auto.conf}"
POSTGRES_CONF_PATH="${POSTGRES_CONF_PATH:-/etc/postgresql/bonfire.conf}"
# NOT `-c name=value` per setting: command-line values outrank postgresql.auto.conf and would silently disable InstanceTuning
POSTGRES_START_CMD="${POSTGRES_START_CMD:-docker-entrypoint.sh postgres -c config_file=${POSTGRES_CONF_PATH}}"
PGDATA="${PGDATA:-/var/lib/postgresql/data}"

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

  # One-time cleanup for volumes created when this script wrote the tuned config INTO postgresql.auto.conf: those stale lines override the config_file above (and shared_buffers, max_connections etc. are not InstanceTuning knobs, so nothing else would ever clear them). Runs once per volume (marker file), so later admin ALTER SYSTEM values persist.
  AUTO_CONF="${PGDATA}/postgresql.auto.conf"
  TUNE_MARKER="${PGDATA}/.bonfire_tune_v2"
  if [[ -f "${PGDATA}/PG_VERSION" && -f "${AUTO_CONF}" && ! -f "${TUNE_MARKER}" ]]; then
    echo "PostgreSQL: removing keys the tuner now sets from ${AUTO_CONF} (one-time migration)"
    tmp_conf="$(mktemp)"
    # first input = the generated config (collect its keys), second = auto.conf (drop those keys, keep the rest)
    awk 'NR==FNR { k=$0; sub(/[[:space:]]*=.*/, "", k); keys[k]=1; next }
         { k=$0; sub(/[[:space:]]*=.*/, "", k); if (!(k in keys)) print }' \
      <(echo "$config") "${AUTO_CONF}" > "${tmp_conf}"
    # write in place (not mv) so the file keeps its postgres ownership
    cat "${tmp_conf}" > "${AUTO_CONF}"
    rm -f "${tmp_conf}"
    touch "${TUNE_MARKER}"
  elif [[ ! -f "${PGDATA}/PG_VERSION" && ! -f "${TUNE_MARKER}" ]]; then
    # Fresh volume: nothing to clean, but the marker can't be written yet (initdb needs an empty data dir). Write it once initdb is done, or the next boot would wrongly run the cleanup and drop admin ALTER SYSTEM values. The loop survives the exec below as an orphan and gives up after 10 minutes.
    ( for _ in $(seq 1 600); do
        if [[ -f "${PGDATA}/PG_VERSION" ]]; then touch "${TUNE_MARKER}"; break; fi
        sleep 1
      done ) >/dev/null 2>&1 &
  fi

  # Check if we should start postgres
  if [[ -n "${POSTGRES_START_CMD}" && "${POSTGRES_START_CMD}" != "none" ]]; then
    # Start PostgreSQL with the tuned config_file. postgresql.auto.conf (ALTER SYSTEM) is still loaded from the data dir and layered on top
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
