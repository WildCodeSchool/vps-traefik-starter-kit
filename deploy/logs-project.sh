#Import ENV vars
set -o allexport
source ./../data/.env
set +o allexport

GITHUB_REPOSITORY_NAME=${1}
DB_NAME=`echo "${GITHUB_REPOSITORY_NAME}" | sed 's/\-/\_/g'`

#Stop and down project container
cd ~/projects/${GITHUB_REPOSITORY_NAME}
GITHUB_REPOSITORY_NAME=${GITHUB_REPOSITORY_NAME} PROJECT_NAME=${2} DB_NAME=${DB_NAME} docker compose --env-file ../../traefik/data/.env logs -t -f