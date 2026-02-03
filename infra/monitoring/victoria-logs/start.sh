#!/bin/bash
# Victoria Logs - Central Log Aggregation Server
# Usage: ./start.sh [start|stop|status|restart]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VLOGS_BIN="$SCRIPT_DIR/victoria-logs-prod"
DATA_DIR="$SCRIPT_DIR/vlogs-data"
PID_FILE="$SCRIPT_DIR/vlogs.pid"
LOG_FILE="$SCRIPT_DIR/vlogs.log"
HTTP_PORT=9428

start() {
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "Victoria Logs is already running (PID: $(cat "$PID_FILE"))"
        return 1
    fi

    echo "Starting Victoria Logs on port $HTTP_PORT..."
    nohup "$VLOGS_BIN" \
        -storageDataPath="$DATA_DIR" \
        -httpListenAddr=":$HTTP_PORT" \
        > "$LOG_FILE" 2>&1 &

    echo $! > "$PID_FILE"
    sleep 1

    if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "Victoria Logs started successfully (PID: $(cat "$PID_FILE"))"
        echo "Endpoint: http://localhost:$HTTP_PORT"
        echo "Loki push: http://localhost:$HTTP_PORT/insert/loki/api/v1/push"
    else
        echo "Failed to start Victoria Logs"
        rm -f "$PID_FILE"
        return 1
    fi
}

stop() {
    if [ ! -f "$PID_FILE" ]; then
        echo "Victoria Logs is not running (no PID file)"
        return 0
    fi

    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "Stopping Victoria Logs (PID: $PID)..."
        kill "$PID"
        sleep 2
        if kill -0 "$PID" 2>/dev/null; then
            echo "Force killing..."
            kill -9 "$PID"
        fi
        echo "Victoria Logs stopped"
    else
        echo "Victoria Logs was not running"
    fi
    rm -f "$PID_FILE"
}

status() {
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "Victoria Logs is running (PID: $(cat "$PID_FILE"))"
        echo "Endpoint: http://localhost:$HTTP_PORT"
    else
        echo "Victoria Logs is not running"
        return 1
    fi
}

restart() {
    stop
    sleep 1
    start
}

case "${1:-start}" in
    start)   start ;;
    stop)    stop ;;
    status)  status ;;
    restart) restart ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac
