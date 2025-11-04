#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

DATA_DIR="/data"

# создаём папки на постоянном диске
mkdir -p "$DATA_DIR" "$DATA_DIR/mods" "$DATA_DIR/config" "$DATA_DIR/libraries"

# принимаем EULA (её значение ты ставишь в переменной окружения на Render)
if [ "${EULA:-}" = "TRUE" ] || [ "${EULA:-}" = "true" ]; then
  echo "eula=true" > "$DATA_DIR/eula.txt"
else
  echo "EULA not accepted. Set EULA=TRUE"
  exit 1
fi

# если первый запуск — копируем серверные файлы Fabric из образа в /data
if [ ! -f "$DATA_DIR/fabric-server-launch.jar" ]; then
  echo "[INIT] Copying Fabric server files to /data..."
  cp -n /app/fabric-server-launch.jar "$DATA_DIR/" || true
  cp -n /app/server.jar "$DATA_DIR/" || true
  cp -rn /app/libraries "$DATA_DIR/" || true
fi

# базовые конфиги если отсутствуют
[ -f "$DATA_DIR/server.properties" ] || cp -n /app/server.properties "$DATA_DIR/server.properties"
[ -f "$DATA_DIR/ops.json" ] || cp -n /app/ops.json "$DATA_DIR/ops.json"
[ -f "$DATA_DIR/whitelist.json" ] || cp -n /app/whitelist.json "$DATA_DIR/whitelist.json"

# моды и конфиги: аккуратно копируем только если в /data пусто
if [ -z "$(ls -A "$DATA_DIR/mods")" ] && [ -d /app/mods ]; then
  cp -rn /app/mods/. "$DATA_DIR/mods/" || true
fi
if [ -z "$(ls -A "$DATA_DIR/config")" ] && [ -d /app/config ]; then
  cp -rn /app/config/. "$DATA_DIR/config/" || true
fi

cd "$DATA_DIR"

XMS="${JVM_XMS:-2G}"
XMX="${JVM_XMX:-4G}"

echo "[START] Launching Fabric server..."
exec java -Xms$XMS -Xmx$XMX -jar fabric-server-launch.jar nogui
