#! /bin/bash
set -e
# Remove pid file if exists
PID_FILE=${RAILS_PID_FILE:-"tmp/pids/server.pid"}
if [ -f "$PID_FILE" ]; then
    echo "removing pid file $PID_FILE"
    rm -f "$PID_FILE"
fi

# Wait for postgres to be available for connections
$RAILS_ROOT/bin/wait-for-it.sh -h ${DB_HOST:-default_db} -p ${DB_PORT:-5432}

# Check gems, productions ones should be set
bundle check

echo "Running '$@'"
# All looks great, can execute commands
exec "$@"
