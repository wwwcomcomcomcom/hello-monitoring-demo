#!/usr/bin/env sh
# Render prometheus.yml from template with environment variables or CLI args, then docker compose up
set -eu

SCRAPE_TARGET=${SCRAPE_TARGET:-host.docker.internal:8080}

# CLI arg override (optional)
# Usage: ./render-and-up.sh target
if [ $# -ge 1 ]; then SCRAPE_TARGET=$1; fi

echo "Rendering prometheus.yml with SCRAPE_TARGET=${SCRAPE_TARGET}" >&2

TEMPLATE="prometheus.yml.tmpl"
OUT="prometheus.yml"

# Simple variable substitution without envsubst: replace ${VAR} tokens
render() {
  sed -i "s#\${SCRAPE_TARGET}#${SCRAPE_TARGET}#g" "$OUT"
}

render

echo "prometheus.yml rendered. Starting docker compose..." >&2
docker compose up --build -d

echo "Done. Use 'docker compose ps' to see status." >&2
