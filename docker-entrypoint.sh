#!/bin/sh
redis-server &
cd /app && export C_FORCE_ROOT=1 && celery --app=reNgine worker --loglevel=info --statedb=/app/worker.db &
if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z db 5432; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

python manage.py migrate
# Load default engine types
python manage.py loaddata fixtures/default_scan_engines.yaml --app scanEngine.EngineType

exec "$@"
