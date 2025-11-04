#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="/data"

mkdir -p "$DATA_DIR" "$DATA_DIR/mods" "$DATA_DIR/config"

if [ "${EULA:-}" = "TRUE" ]; then
  echo "eula=true" > "$DATA_DIR/eula.txt"
else
  echo "EULA not accepted. Set EULA=TRUE"
  exit 1
fi

[ -f "$DATA_DIR/server.properties" ] || cp -n /app/server.properties "$DATA_DIR/server.properties"
[ -f "$DATA_DIR/ops.json" ] || cp -n /app/ops.json "$DATA_DIR/ops.json"
[ -f "$DATA_DIR/whitelist.json" ] || cp -n /app/whitelist.json "$DATA_DIR/whitelist.json"

if [ -z "$(ls -A "$DATA_DIR/mods")" ] && [ -d /app/mods ]; then
  cp -rn /app/mods/* "$DATA_DIR/mods/" || true
fi

cd "$DATA_DIR"

exec java -Xms2G -Xmx4G -jar fabric-server-launch.jar nogui
