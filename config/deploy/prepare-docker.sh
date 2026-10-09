#!/usr/bin/env bash
# Prepares a directory to run a prebuilt Bonfire Docker image with `docker compose`: downloads the compose file and the config files it mounts, and creates the env file with generated secrets. It runs no Docker commands.
# Usage: [FLAVOUR=community] [WITH_PROXY=no] bash prepare-docker.sh [directory]
# WITH_PROXY=no leaves out the Caddy reverse proxy, eg. if you use your own.
# Run it again before an upgrade to update the downloaded files. It never changes an existing env file, because new secrets would break sessions, encrypted data, and database access. It keeps your copies of the Sonic, Caddy and Postgres configs, so you can edit them, and when their template changed it shows the changes and asks whether to keep or replace your copy.
set -euo pipefail

dir="${1:-.}"
src="${BONFIRE_BASE_URL:-https://raw.githubusercontent.com/bonfire-networks/bonfire-app/${BONFIRE_REF:-main}}"
env_file="$dir/config/prod/.env"
# on a re-run, the env file already has the flavour
FLAVOUR="${FLAVOUR:-$(sed -n 's/^FLAVOUR=//p' "$env_file" 2>/dev/null || true)}"
FLAVOUR="${FLAVOUR:-community}"
db_version="${DB_DOCKER_VERSION:-17-3.5}"

case "$(uname -m)" in
  x86_64 | amd64) arch=amd64 db_image="postgis/postgis:$db_version-alpine" ;;
  aarch64 | arm64) arch=aarch64 db_image="ghcr.io/baosystems/postgis:$db_version" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

download() {
  curl -fsSL "$src/$1" -o "$dir/${2:-$1}"
}

rand() {
  openssl rand -base64 "$1" | tr -d '\n/+=' | head -c "$1"
}

set_var() {
  if grep -q "^$1=" "$env_file"; then
    sed "s|^$1=.*|$1=$2|" "$env_file" > "$env_file.tmp" && mv "$env_file.tmp" "$env_file"
  else
    echo "$1=$2" >> "$env_file"
  fi
}

# Copy a template to config/deploy/ if missing. Never overwrite the copy without asking: when the template changed since the last check, show the changes and ask whether to keep or replace the copy. `.FILE.base` holds the template version of the last check. Same logic as `just _deploy-config`.
deploy_config() {
  local copy="config/deploy/$1" base="config/deploy/.$1.base" template answer
  template=$(mktemp)
  curl -fsSL "$src/config/templates/$1" -o "$template"
  cd "$dir"
  if [ ! -f "$copy" ]; then
    cp "$template" "$copy"
    cp "$template" "$base"
  elif cmp -s "$template" "$copy"; then
    cp "$template" "$base"
  elif [ ! -f "$base" ] || ! cmp -s "$template" "$base"; then
    if [ -f "$base" ]; then
      echo "The template for $copy changed since it was last checked:"
      diff -u "$base" "$template" || true
    else
      echo "$copy differs from the latest template (- your copy, + template):"
      diff -u "$copy" "$template" || true
    fi
    if { exec 3</dev/tty; } 2>/dev/null && read -r -u 3 -p "Keep your copy [k] or replace it with the template, saving yours as $copy.bak [r]? " answer; then
      exec 3<&-
      if [ "$answer" = r ]; then
        cp "$copy" "$copy.bak"
        cp "$template" "$copy"
        echo "Replaced $copy, yours is in $copy.bak"
      else
        echo "Kept $copy"
      fi
      cp "$template" "$base"
    else
      echo "WARNING: kept $copy unchanged. Run this again in a terminal to choose."
    fi
  fi
  cd - >/dev/null
  rm -f "$template"
}

mkdir -p "$dir/config/deploy" "$dir/config/prod" "$dir/data/uploads"

for f in docker-compose.release.yml config/deploy/postgres-entrypoint.sh config/deploy/postgres-tune.sh config/deploy/bash-envsubst.sh; do
  download "$f"
done

for f in sonic.cfg Caddyfile2 Caddyfile2-https postgres.conf.tmpl; do
  deploy_config "$f"
done

if [ -e "$env_file" ]; then
  echo "$env_file already exists, so it was left unchanged."
  next="1. docker compose pull
2. docker compose up -d"
else
  next="1. Edit config/prod/.env: set at least HOSTNAME and the MAIL_* keys.
2. docker compose pull
3. docker compose up -d"
  curl -fsSL "$src/config/templates/public.env" "$src/config/templates/not_secret.env" > "$env_file"

  set_var FLAVOUR "$FLAVOUR"
  set_var APP_DOCKER_IMAGE "bonfirenetworks/bonfire:latest-$FLAVOUR-$arch"
  set_var DB_DOCKER_IMAGE "$db_image"
  # same choice as the justfile makes
  if grep -q "^PUBLIC_PORT=443$" "$env_file"; then
    set_var PROXY_CADDYFILE_PATH ./config/deploy/Caddyfile2-https
  else
    set_var PROXY_CADDYFILE_PATH ./config/deploy/Caddyfile2
  fi
  # the same project name as `just rel-run` uses, so both share the volumes
  set_var COMPOSE_PROJECT_NAME bonfire_release
  set_var COMPOSE_FILE docker-compose.release.yml
  if [ "${WITH_PROXY:-yes}" = no ]; then
    set_var COMPOSE_PROFILES sonic
  else
    set_var COMPOSE_PROFILES proxy,sonic
  fi

  set_var SECRET_KEY_BASE "$(rand 128)"
  set_var SIGNING_SALT "$(rand 128)"
  set_var ENCRYPTION_SALT "$(rand 128)"
  set_var RELEASE_COOKIE "$(rand 42)"
  set_var POSTGRES_PASSWORD "$(rand 42)"
  set_var SONIC_PASSWORD "$(rand 42)"

  chmod 600 "$env_file"
  echo "Created $env_file with generated secrets."
fi

# `docker compose` reads `.env` in the current directory
ln -sfn config/prod/.env "$dir/.env"

printf "\nNext steps, in %s:\n%s\n" "$dir" "$next"
