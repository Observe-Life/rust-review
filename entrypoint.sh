#!/bin/bash
# rust-review 待命看门狗：
# 容器启动后开始计时；每执行一次 review 会重置计时；闲置超过 IDLE_TIMEOUT 秒自动退出。
IDLE_TIMEOUT="${IDLE_TIMEOUT:-600}"
IDLE_FILE="/run/rust-review-idle"

touch "$IDLE_FILE"
echo "[rust-review] ready. idle timeout = ${IDLE_TIMEOUT}s"

while true; do
    sleep 10
    now=$(date +%s)
    last=$(stat -c %Y "$IDLE_FILE" 2>/dev/null || echo "$now")
    age=$(( now - last ))
    if [ "$age" -ge "$IDLE_TIMEOUT" ]; then
        echo "[rust-review] idle ${age}s >= ${IDLE_TIMEOUT}s, stopping."
        exit 0
    fi
done
