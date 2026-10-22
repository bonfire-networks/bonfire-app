#!/usr/bin/env bash
set -euo pipefail

# PostgreSQL Configuration Tuner 
# Based on PGTune algorithm (https://pgtune.leopard.in.ua)
# Detects system resources and calculates optimal settings
# Outputs ENV vars that can be sourced before running envsubst

# Constants
readonly KB=1024
readonly MB=$((1024 * KB))
readonly GB=$((1024 * MB))
readonly TB=$((1024 * GB))

# Database types
readonly DB_TYPE_WEB="web"
readonly DB_TYPE_OLTP="oltp"
readonly DB_TYPE_DW="dw"
readonly DB_TYPE_DESKTOP="desktop"
readonly DB_TYPE_MIXED="mixed"

# Storage types
readonly STORAGE_SSD="ssd"
readonly STORAGE_HDD="hdd"
readonly STORAGE_SAN="san"

# Auto-detect or use environment variables
# NOTE: default profile is `mixed` (not `oltp`): Bonfire is OLTP plus a tail of analytics-shaped
# queries (many-join boundarised feeds/threads), which is exactly PGTune's mixed workload. It also
# right-sizes max_connections (100 vs oltp's 300 — Bonfire's Ecto pool is the pooler, ~25-50 conns;
# an oversized value wastes RAM headroom and shrinks the computed work_mem, which caused measured
# multi-TB temp-file spills in prod).
PG_DB_TYPE="${PG_DB_TYPE:-${DB_TYPE:-mixed}}"
PG_STORAGE_TYPE="${PG_STORAGE_TYPE:-${DISK_STORAGE_TYPE:-ssd}}"
PG_DB_VERSION="${PG_DB_VERSION:-17}"

# System resources detection
detect_total_memory_kb() {
    if [[ -n "${AVAILABLE_RAM_GB:-}" ]]; then
        echo $((AVAILABLE_RAM_GB * GB / KB))
    elif [[ -n "${AVAILABLE_RAM_MB:-}" ]]; then
        echo $((AVAILABLE_RAM_MB * MB / KB))
    elif [[ -r /sys/fs/cgroup/memory.max && "$(cat /sys/fs/cgroup/memory.max)" != "max" ]]; then
        # cgroup v2: an explicit container memory limit is the deliberate budget signal
        echo $(($(cat /sys/fs/cgroup/memory.max) / KB))
    elif [[ -r /sys/fs/cgroup/memory/memory.limit_in_bytes ]] &&
         [[ "$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)" -lt $((1 << 60)) ]]; then
        # cgroup v1 (its "no limit" sentinel is a huge number rather than "max")
        echo $(($(cat /sys/fs/cgroup/memory/memory.limit_in_bytes) / KB))
    elif [[ -f /proc/meminfo ]]; then
        # Calculate based on total available memory: claiming a fraction as co-hosted services need the rest. Sized for our standard stack (app + postgres + search + proxy). Override with PG_RAM_PERCENT or AVAILABLE_RAM_MB.
        awk -v pct="${PG_RAM_PERCENT:-40}" '/MemTotal/ {print int($2 * pct / 100)}' /proc/meminfo
    elif command -v sysctl &> /dev/null; then
        # macOS/BSD
        local mem_bytes
        mem_bytes=$(sysctl -n hw.memsize 2>/dev/null || sysctl -n hw.physmem 2>/dev/null)
        echo $((mem_bytes * ${PG_RAM_PERCENT:-40} / 100 / KB))
    else
        # Fallback: assume 4GB
        echo $((4 * GB / KB))
    fi
}

detect_cpu_count() {
    if [[ -n "${NUM_CPU:-}" ]]; then
        echo "$NUM_CPU"
    elif command -v nproc &> /dev/null; then
        nproc
    elif [[ -f /proc/cpuinfo ]]; then
        grep -c ^processor /proc/cpuinfo
    elif command -v sysctl &> /dev/null; then
        sysctl -n hw.ncpu 2>/dev/null || echo "2"
    else
        echo "2"
    fi
}

# Get system resources
TOTAL_MEMORY_KB=$(detect_total_memory_kb)
CPU_COUNT=$(detect_cpu_count)

# Helper functions
to_mb() {
    echo $(($1 / KB))
}

to_gb() {
    echo $(($1 / MB))
}


# Print detected/configured values to stderr so they don't interfere with the export output
{
    echo "=========================================="
    echo "PostgreSQL Configuration Detection"
    echo "=========================================="
    echo "System Resources:"
    echo "  Total Memory: $(to_mb $TOTAL_MEMORY_KB) MB ($(to_gb $TOTAL_MEMORY_KB) GB)"
    echo "  CPU Cores: ${CPU_COUNT}"
    echo ""
    echo "Configuration:"
    echo "  Database Type: ${PG_DB_TYPE}"
    echo "  Storage Type: ${PG_STORAGE_TYPE}"
    echo "  PostgreSQL Version: ${PG_DB_VERSION}"
    echo "=========================================="
    echo ""
} >&2


# Calculate max_connections
calc_max_connections() {
    if [[ -n "${PG_MAX_CONNECTIONS:-}" ]]; then
        echo "$PG_MAX_CONNECTIONS"
        return
    fi

    case "$PG_DB_TYPE" in
        "$DB_TYPE_WEB") echo 200 ;;
        "$DB_TYPE_OLTP") echo 300 ;;
        "$DB_TYPE_DW") echo 40 ;;
        "$DB_TYPE_DESKTOP") echo 20 ;;
        "$DB_TYPE_MIXED") echo 100 ;;
        *) echo 100 ;;
    esac
}

# Calculate shared_buffers
calc_shared_buffers() {
    if [[ -n "${PG_SHARED_BUFFERS_MB:-}" ]]; then
        echo $((PG_SHARED_BUFFERS_MB * MB / KB))
        return
    fi

    local shared_buffers_kb
    case "$PG_DB_TYPE" in
        "$DB_TYPE_WEB"|"$DB_TYPE_OLTP"|"$DB_TYPE_DW"|"$DB_TYPE_MIXED")
            shared_buffers_kb=$((TOTAL_MEMORY_KB / 4))
            ;;
        "$DB_TYPE_DESKTOP")
            shared_buffers_kb=$((TOTAL_MEMORY_KB / 16))
            ;;
        *)
            shared_buffers_kb=$((TOTAL_MEMORY_KB / 4))
            ;;
    esac

    echo "$shared_buffers_kb"
}

# Calculate effective_cache_size
calc_effective_cache_size() {
    if [[ -n "${PG_EFFECTIVE_CACHE_SIZE_MB:-}" ]]; then
        echo $((PG_EFFECTIVE_CACHE_SIZE_MB * MB / KB))
        return
    fi

    case "$PG_DB_TYPE" in
        "$DB_TYPE_WEB"|"$DB_TYPE_OLTP"|"$DB_TYPE_DW"|"$DB_TYPE_MIXED")
            echo $((TOTAL_MEMORY_KB * 3 / 4))
            ;;
        "$DB_TYPE_DESKTOP")
            echo $((TOTAL_MEMORY_KB / 4))
            ;;
        *)
            echo $((TOTAL_MEMORY_KB * 3 / 4))
            ;;
    esac
}

# Calculate maintenance_work_mem
calc_maintenance_work_mem() {
    if [[ -n "${PG_MAINTENANCE_WORK_MEM_MB:-}" ]]; then
        echo $((PG_MAINTENANCE_WORK_MEM_MB * MB / KB))
        return
    fi

    local maint_mem_kb
    case "$PG_DB_TYPE" in
        "$DB_TYPE_DW")
            maint_mem_kb=$((TOTAL_MEMORY_KB / 8))
            ;;
        *)
            maint_mem_kb=$((TOTAL_MEMORY_KB / 16))
            ;;
    esac

    # Cap at 2GB
    local max_maint_mem=$((2 * GB / KB))
    if [[ $maint_mem_kb -gt $max_maint_mem ]]; then
        maint_mem_kb=$max_maint_mem
    fi

    echo "$maint_mem_kb"
}

# Calculate checkpoint settings
calc_checkpoint_settings() {
    local min_wal_kb max_wal_kb
    
    if [[ -n "${PG_MIN_WAL_SIZE_MB:-}" ]]; then
        min_wal_kb=$((PG_MIN_WAL_SIZE_MB * MB / KB))
    else
        case "$PG_DB_TYPE" in
            "$DB_TYPE_WEB"|"$DB_TYPE_MIXED") min_wal_kb=$((1024 * MB / KB)) ;;
            "$DB_TYPE_OLTP") min_wal_kb=$((2048 * MB / KB)) ;;
            "$DB_TYPE_DW") min_wal_kb=$((4096 * MB / KB)) ;;
            "$DB_TYPE_DESKTOP") min_wal_kb=$((100 * MB / KB)) ;;
            *) min_wal_kb=$((1024 * MB / KB)) ;;
        esac
    fi

    if [[ -n "${PG_MAX_WAL_SIZE_MB:-}" ]]; then
        max_wal_kb=$((PG_MAX_WAL_SIZE_MB * MB / KB))
    else
        case "$PG_DB_TYPE" in
            "$DB_TYPE_WEB"|"$DB_TYPE_MIXED") max_wal_kb=$((4096 * MB / KB)) ;;
            "$DB_TYPE_OLTP") max_wal_kb=$((8192 * MB / KB)) ;;
            "$DB_TYPE_DW") max_wal_kb=$((16384 * MB / KB)) ;;
            "$DB_TYPE_DESKTOP") max_wal_kb=$((2048 * MB / KB)) ;;
            *) max_wal_kb=$((4096 * MB / KB)) ;;
        esac
    fi

    echo "$min_wal_kb $max_wal_kb"
}

# Calculate wal_buffers
calc_wal_buffers() {
    if [[ -n "${PG_WAL_BUFFERS_MB:-}" ]]; then
        echo $((PG_WAL_BUFFERS_MB * MB / KB))
        return
    fi

    local shared_buffers_kb=$1
    local wal_buffers_kb=$((shared_buffers_kb * 3 / 100))
    
    local max_wal_buffer=$((16 * MB / KB))
    if [[ $wal_buffers_kb -gt $max_wal_buffer ]]; then
        wal_buffers_kb=$max_wal_buffer
    fi

    # Round up to 16MB if close
    local near_max=$((14 * MB / KB))
    if [[ $wal_buffers_kb -gt $near_max && $wal_buffers_kb -lt $max_wal_buffer ]]; then
        wal_buffers_kb=$max_wal_buffer
    fi

    # Minimum 32KB
    if [[ $wal_buffers_kb -lt 32 ]]; then
        wal_buffers_kb=32
    fi

    echo "$wal_buffers_kb"
}

# Calculate default_statistics_target
calc_default_statistics_target() {
    if [[ -n "${PG_DEFAULT_STATISTICS_TARGET:-}" ]]; then
        echo "$PG_DEFAULT_STATISTICS_TARGET"
        return
    fi

    case "$PG_DB_TYPE" in
        "$DB_TYPE_DW") echo 500 ;;
        *) echo 100 ;;
    esac
}

# Calculate random_page_cost
calc_random_page_cost() {
    if [[ -n "${PG_RANDOM_PAGE_COST:-}" ]]; then
        echo "$PG_RANDOM_PAGE_COST"
        return
    fi

    case "$PG_STORAGE_TYPE" in
        "$STORAGE_HDD") echo "4" ;;
        "$STORAGE_SSD"|"$STORAGE_SAN") echo "1.1" ;;
        *) echo "1.1" ;;
    esac
}

# Calculate effective_io_concurrency
calc_effective_io_concurrency() {
    if [[ -n "${PG_EFFECTIVE_IO_CONCURRENCY:-}" ]]; then
        echo "$PG_EFFECTIVE_IO_CONCURRENCY"
        return
    fi

    case "$PG_STORAGE_TYPE" in
        "$STORAGE_HDD") echo 2 ;;
        "$STORAGE_SSD") echo 200 ;;
        "$STORAGE_SAN") echo 300 ;;
        *) echo 200 ;;
    esac
}

# Calculate parallel workers settings
# Echoes 4 space-separated values: max_worker_processes max_parallel_workers_per_gather max_parallel_workers max_parallel_maintenance_workers
# (single source of truth — generate_env_vars reads these instead of duplicating the logic)
calc_parallel_settings() {
    local max_worker_processes max_parallel_workers_per_gather max_parallel_workers max_parallel_maintenance_workers

    if [[ $CPU_COUNT -ge 4 ]]; then
        local workers_per_gather=$((CPU_COUNT / 2))
        # Cap at 4 for non-DW workloads
        if [[ "$PG_DB_TYPE" != "$DB_TYPE_DW" && $workers_per_gather -gt 4 ]]; then
            workers_per_gather=4
        fi

        local parallel_maint_workers=$((CPU_COUNT / 2))
        if [[ $parallel_maint_workers -gt 4 ]]; then
            parallel_maint_workers=4
        fi

        max_worker_processes=${PG_MAX_WORKER_PROCESSES:-$CPU_COUNT}
        max_parallel_workers_per_gather=${PG_MAX_PARALLEL_WORKERS_PER_GATHER:-$workers_per_gather}
        max_parallel_workers=${PG_MAX_PARALLEL_WORKERS:-$CPU_COUNT}
        max_parallel_maintenance_workers=${PG_MAX_PARALLEL_MAINTENANCE_WORKERS:-$parallel_maint_workers}
    else
        max_worker_processes=${PG_MAX_WORKER_PROCESSES:-8}
        max_parallel_workers_per_gather=${PG_MAX_PARALLEL_WORKERS_PER_GATHER:-2}
        max_parallel_workers=${PG_MAX_PARALLEL_WORKERS:-8}
        max_parallel_maintenance_workers=${PG_MAX_PARALLEL_MAINTENANCE_WORKERS:-2}
    fi

    echo "$max_worker_processes $max_parallel_workers_per_gather $max_parallel_workers $max_parallel_maintenance_workers"
}

# Calculate work_mem
calc_work_mem() {
    if [[ -n "${PG_WORK_MEM_KB:-}" ]]; then
        echo "$PG_WORK_MEM_KB"
        return
    fi

    local shared_buffers_kb=$1
    local max_connections=$2
    # the actual computed worker count, passed in by generate_env_vars so the divisor stays
    # consistent with the exported max_worker_processes (was previously assumed to be 8)
    local max_worker_processes=${3:-${PG_MAX_WORKER_PROCESSES:-8}}

    local work_mem_kb=$(( (TOTAL_MEMORY_KB - shared_buffers_kb) / ((max_connections + max_worker_processes) * 3) ))

    case "$PG_DB_TYPE" in
        "$DB_TYPE_DW"|"$DB_TYPE_MIXED"|"$DB_TYPE_DESKTOP")
            work_mem_kb=$((work_mem_kb / 2))
            ;;
    esac

    # Floor for web/oltp/mixed app workloads: below ~16MB, many-join queries (sorts + hashes)
    # constantly spill to disk-based algorithms writing temp files (measured multi-TB on a busy
    # instance at 16.6MB with an oversized max_connections divisor). Other profiles keep 64KB.
    local min_work_mem=64
    case "$PG_DB_TYPE" in
        "$DB_TYPE_WEB"|"$DB_TYPE_OLTP"|"$DB_TYPE_MIXED")
            min_work_mem=$((16 * MB / KB))
            ;;
    esac
    if [[ $work_mem_kb -lt $min_work_mem ]]; then
        work_mem_kb=$min_work_mem
    fi

    echo "$work_mem_kb"
}

# Calculate huge_pages
calc_huge_pages() {
    if [[ -n "${PG_HUGE_PAGES:-}" ]]; then
        echo "$PG_HUGE_PAGES"
        return
    fi

    # Enable for systems with >= 32GB RAM
    if [[ $TOTAL_MEMORY_KB -ge $((32 * GB / KB)) ]]; then
        echo "try"
    else
        echo "off"
    fi
}

# Calculate checkpoint_completion_target
calc_checkpoint_completion_target() {
    echo "${PG_CHECKPOINT_COMPLETION_TARGET:-0.9}"
}

# Calculate autovacuum_max_workers (~1/3 of cores, min 3 which is also the PG default)
calc_autovacuum_max_workers() {
    if [[ -n "${PG_AUTOVACUUM_MAX_WORKERS:-}" ]]; then
        echo "$PG_AUTOVACUUM_MAX_WORKERS"
        return
    fi

    local workers=$((CPU_COUNT / 3))
    if [[ $workers -lt 3 ]]; then
        workers=3
    fi
    echo "$workers"
}

# WAL compression: lz4 is cheaper than the pglz default but needs PG >= 15
calc_wal_compression() {
    if [[ -n "${PG_WAL_COMPRESSION:-}" ]]; then
        echo "$PG_WAL_COMPRESSION"
        return
    fi

    if [[ "${PG_DB_VERSION%%.*}" -ge 15 ]]; then
        echo "lz4"
    else
        echo "off"
    fi
}

# TOAST compression for large values (post content etc.): lz4 needs PG >= 14
calc_toast_compression() {
    if [[ -n "${PG_TOAST_COMPRESSION:-}" ]]; then
        echo "$PG_TOAST_COMPRESSION"
        return
    fi

    if [[ "${PG_DB_VERSION%%.*}" -ge 14 ]]; then
        echo "lz4"
    else
        echo "pglz"
    fi
}

# Main generation function - output as ENV vars
generate_env_vars() {
    local max_connections shared_buffers_kb effective_cache_kb maint_work_mem_kb
    local min_wal_kb max_wal_kb wal_buffers_kb work_mem_kb
    local default_stats_target random_page_cost effective_io_concurrency
    local huge_pages checkpoint_target

    max_connections=$(calc_max_connections)
    shared_buffers_kb=$(calc_shared_buffers)
    effective_cache_kb=$(calc_effective_cache_size)
    maint_work_mem_kb=$(calc_maintenance_work_mem)
    read -r min_wal_kb max_wal_kb <<< "$(calc_checkpoint_settings)"
    wal_buffers_kb=$(calc_wal_buffers "$shared_buffers_kb")
    default_stats_target=$(calc_default_statistics_target)
    random_page_cost=$(calc_random_page_cost)
    effective_io_concurrency=$(calc_effective_io_concurrency)
    huge_pages=$(calc_huge_pages)
    checkpoint_target=$(calc_checkpoint_completion_target)

    # Parallel settings (single source: calc_parallel_settings), needed BEFORE work_mem
    # since the worker count is part of its divisor
    local max_worker_processes max_parallel_workers_per_gather max_parallel_workers max_parallel_maintenance_workers
    read -r max_worker_processes max_parallel_workers_per_gather max_parallel_workers max_parallel_maintenance_workers <<< "$(calc_parallel_settings)"

    work_mem_kb=$(calc_work_mem "$shared_buffers_kb" "$max_connections" "$max_worker_processes")

    local autovacuum_max_workers wal_compression toast_compression
    autovacuum_max_workers=$(calc_autovacuum_max_workers)
    wal_compression=$(calc_wal_compression)
    toast_compression=$(calc_toast_compression)

    # Output ENV vars (only if not already set)
    cat << EOF
# PostgreSQL configuration calculated for: $PG_DB_TYPE workload, ${CPU_COUNT} CPUs, $(to_mb $TOTAL_MEMORY_KB)MB RAM, $PG_STORAGE_TYPE storage
export PG_MAX_CONNECTIONS=\${PG_MAX_CONNECTIONS:-$max_connections}
export PG_SHARED_BUFFERS_MB=\${PG_SHARED_BUFFERS_MB:-$(to_mb "$shared_buffers_kb")}
export PG_EFFECTIVE_CACHE_SIZE_MB=\${PG_EFFECTIVE_CACHE_SIZE_MB:-$(to_mb "$effective_cache_kb")}
export PG_MAINTENANCE_WORK_MEM_MB=\${PG_MAINTENANCE_WORK_MEM_MB:-$(to_mb "$maint_work_mem_kb")}
export PG_WORK_MEM_KB=\${PG_WORK_MEM_KB:-$work_mem_kb}
export PG_HUGE_PAGES=\${PG_HUGE_PAGES:-$huge_pages}
export PG_WAL_BUFFERS_MB=\${PG_WAL_BUFFERS_MB:-$(to_mb "$wal_buffers_kb")}
export PG_MIN_WAL_SIZE_MB=\${PG_MIN_WAL_SIZE_MB:-$(to_mb "$min_wal_kb")}
export PG_MAX_WAL_SIZE_MB=\${PG_MAX_WAL_SIZE_MB:-$(to_mb "$max_wal_kb")}
export PG_CHECKPOINT_COMPLETION_TARGET=\${PG_CHECKPOINT_COMPLETION_TARGET:-$checkpoint_target}
export PG_DEFAULT_STATISTICS_TARGET=\${PG_DEFAULT_STATISTICS_TARGET:-$default_stats_target}
export PG_RANDOM_PAGE_COST=\${PG_RANDOM_PAGE_COST:-$random_page_cost}
export PG_EFFECTIVE_IO_CONCURRENCY=\${PG_EFFECTIVE_IO_CONCURRENCY:-$effective_io_concurrency}
export PG_MAX_WORKER_PROCESSES=\${PG_MAX_WORKER_PROCESSES:-$max_worker_processes}
export PG_MAX_PARALLEL_WORKERS_PER_GATHER=\${PG_MAX_PARALLEL_WORKERS_PER_GATHER:-$max_parallel_workers_per_gather}
export PG_MAX_PARALLEL_WORKERS=\${PG_MAX_PARALLEL_WORKERS:-$max_parallel_workers}
export PG_MAX_PARALLEL_MAINTENANCE_WORKERS=\${PG_MAX_PARALLEL_MAINTENANCE_WORKERS:-$max_parallel_maintenance_workers}
# JIT: a per-execution LLVM compile tax on complex-but-fast app queries; off unless doing long analytics scans
export PG_JIT=\${PG_JIT:-off}
# observability: query stats extension (restart-required to change), I/O timing, full query texts in pg_stat_activity
export PG_PRELOAD_LIBS=\${PG_PRELOAD_LIBS:-pg_stat_statements}
export PG_TRACK_IO_TIMING=\${PG_TRACK_IO_TIMING:-on}
export PG_TRACK_ACTIVITY_QUERY_SIZE=\${PG_TRACK_ACTIVITY_QUERY_SIZE:-16384}
# autovacuum tuned for soft-delete/append app workloads (default 20% thresholds never trigger on big tables);
# per-table thresholds for the hottest tables also ship as an app migration
export PG_AUTOVACUUM_VACUUM_SCALE_FACTOR=\${PG_AUTOVACUUM_VACUUM_SCALE_FACTOR:-0.05}
export PG_AUTOVACUUM_VACUUM_INSERT_SCALE_FACTOR=\${PG_AUTOVACUUM_VACUUM_INSERT_SCALE_FACTOR:-0.05}
export PG_AUTOVACUUM_ANALYZE_SCALE_FACTOR=\${PG_AUTOVACUUM_ANALYZE_SCALE_FACTOR:-0.02}
export PG_AUTOVACUUM_VACUUM_COST_LIMIT=\${PG_AUTOVACUUM_VACUUM_COST_LIMIT:-1000}
export PG_AUTOVACUUM_MAX_WORKERS=\${PG_AUTOVACUUM_MAX_WORKERS:-$autovacuum_max_workers}
export PG_LOG_AUTOVACUUM_MIN_DURATION=\${PG_LOG_AUTOVACUUM_MIN_DURATION:-0}
# cheaper compression codecs (version-gated: wal lz4 needs PG15+, toast lz4 PG14+)
export PG_WAL_COMPRESSION=\${PG_WAL_COMPRESSION:-$wal_compression}
export PG_TOAST_COMPRESSION=\${PG_TOAST_COMPRESSION:-$toast_compression}
# diagnostics logging: slow statements (server-side; the app logs its own from 100ms), lock waits, temp-file spills
export PG_LOG_MIN_DURATION_STATEMENT=\${PG_LOG_MIN_DURATION_STATEMENT:-2000}
export PG_LOG_LOCK_WAITS=\${PG_LOG_LOCK_WAITS:-on}
export PG_LOG_TEMP_FILES=\${PG_LOG_TEMP_FILES:-0}
EOF
}

# Run generation
generate_env_vars
