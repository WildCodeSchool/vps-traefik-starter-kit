#Import ENV vars
set -o allexport
source ./data/.env
set +o allexport

#Stop and start Traefik, let's encrypt certificates should be regenerated
docker compose stop
HOST=$HOST docker compose up -d
