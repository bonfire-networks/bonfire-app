#!/usr/bin/env bash
# Counts the class patterns tracked by docs/topics/CSS_TOKENS_SIMPLIFICATION_PLAN.md,
# so each cleanup phase can show before/after numbers. Usage: just css-audit
# Pass a pattern name (e.g. `just css-audit noop-opacity`) to list matches with file:line.

cd "$(dirname "$0")" || exit 1

DIRS=(extensions/*/lib extensions/ember/priv/templates)
INCLUDES=(--include=*.sface --include=*.heex --include=*.ex --include=*.exs)

# name|description|extended regex
PATTERNS=(
  "noop-opacity|TW3 *-opacity-N utilities (generate nothing in TW4)|(text|bg|border|ring|divide|placeholder)-opacity-[0-9]+"
  "stream-vars|--stream-* variables referenced from templates|--stream-[a-z-]+"
  "divider-secondary|border-secondary used as a divider|(border|divide)(-[trblxy])?-secondary([^-/a-z]|$)"
  "divider-opacity|border-base-content/N|(border|divide)(-[trblxy])?-base-content/[0-9]+"
  "muted-opacity|text-base-content/N|text-base-content/[0-9]+"
  "fill-opacity|bg-base-content/N|bg-base-content/[0-9]+"
  "font-size-arbitrary|text-[Npx], text-[Nrem]|text-\\[[0-9.]+(px|rem|em)\\]"
  "type-removed|size/weight/spacing classes that no longer exist (silently do nothing)|(^|[ \"':!])text-(body|heading|display|nav|lead|result|feature|caption|meta|[4-9]xl)([^-a-z0-9]|$)|font-(semibold|light|extrabold|thin|extralight|black)([^-a-z]|$)|(^|[ \"':!-])(p|px|py|pt|pb|pl|pr|m|mx|my|mt|mb|ml|mr|gap|gap-x|gap-y|space-x|space-y|w|h|size)-(half|content|row|base|avatar|panel)([^-a-z0-9]|$)"
  "tracking-arbitrary|tracking-[...]|tracking-\\[[^]]+\\]"
  "z-raw|z-10..50|(^|[ \"':])z-(10|20|30|40|50)([^0-9]|$)"
  "z-arbitrary|z-[...]|z-\\[[0-9]+\\]"
  "radius-unthemed|rounded / -sm..-3xl (not box/field/selector/full)|rounded(-[trblse]{1,2})?(-(sm|md|lg|xl|2xl|3xl))?(\\s|\"|$)"
  "radius-themed|rounded-box/field/selector|rounded(-[trblse]{1,2})?-(box|field|selector)"
  "length-arbitrary-px|arbitrary px lengths (w-[18px] …)|(^|[ \":!])-?(w|h|size|min-w|min-h|max-w|max-h|m[trblxy]?|p[trblxy]?|gap(-[xy])?|top|left|right|bottom|inset(-[xy])?|space-[xy])-\\[[0-9.]+px\\]"
)

count() {
  grep -rEo "${INCLUDES[@]}" -- "$1" "${DIRS[@]}" 2>/dev/null | wc -l | tr -d ' '
}

# var(--x) used in templates but declared nowhere: in our CSS, the compiled bundle,
# a template ([--x:…] or style="--x:…") or a quoted name in JS. An undefined var
# silently drops the declaration, e.g. a max-width that stops applying.
undefined_vars() {
  local used defined
  # var(--x) and Tailwind's shorthand utility-(--x) / utility-(type:--x)
  used=$(grep -rhoE "${INCLUDES[@]}" -- 'var\(--[a-zA-Z0-9_-]+|-\(([a-z-]+:)?--[a-zA-Z0-9_-]+\)' "${DIRS[@]}" 2>/dev/null | grep -oE -- '--[a-zA-Z0-9_-]+' | sort -u)
  defined=$( {
    grep -rhoE --include=*.css -- '--[a-zA-Z0-9_-]+\s*:' extensions/*/assets/css extensions/*/themes priv/static/assets/*.css 2>/dev/null
    grep -rhoE "${INCLUDES[@]}" -- '\[--[a-zA-Z0-9_-]+:|--[a-zA-Z0-9_-]+:' "${DIRS[@]}" 2>/dev/null
    grep -rhoE --include=*.js --include=*.ts --exclude-dir=node_modules -- '["'"'"'`]--[a-zA-Z0-9_-]+["'"'"'`]' extensions/*/assets/js extensions/*/lib 2>/dev/null
  } | grep -oE -- '--[a-zA-Z0-9_-]+' | sort -u)
  # names ending in "-" are interpolated (var(--color-#{name})), not checkable
  comm -23 <(echo "$used") <(echo "$defined") | grep -v -- '-$'
}

if [ "$1" = "undefined-vars" ]; then
  for v in $(undefined_vars); do grep -rnE "${INCLUDES[@]}" -- "[(:]$v[^a-zA-Z0-9_-]" "${DIRS[@]}"; done
  exit 0
fi

if [ -n "$1" ]; then
  for p in "${PATTERNS[@]}"; do
    IFS='|' read -r name _ regex <<<"$p"
    [ "$name" = "$1" ] && exec grep -rnE "${INCLUDES[@]}" -- "$regex" "${DIRS[@]}"
  done
  echo "Unknown pattern '$1'" >&2
  exit 1
fi

printf "%-22s %6s  %s\n" "pattern" "count" "description"
for p in "${PATTERNS[@]}"; do
  IFS='|' read -r name desc regex <<<"$p"
  printf "%-22s %6s  %s\n" "$name" "$(count "$regex")" "$desc"
done
printf "%-22s %6s  %s\n" "undefined-vars" "$(undefined_vars | grep -c .)" "var(--x) in templates that nothing defines"
