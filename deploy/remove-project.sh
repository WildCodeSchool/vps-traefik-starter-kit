#Import ENV vars
set -o allexport
source ./../data/.env
set +o allexport

GITHUB_REPOSITORY_NAME=${1}
DB_NAME=`echo "${GITHUB_REPOSITORY_NAME}" | sed 's/\-/\_/g'`
DB_TEST_NAME=${DB_NAME}_test

#Stop and down project container
cd ~/projects/${GITHUB_REPOSITORY_NAME}
GITHUB_REPOSITORY_NAME=${GITHUB_REPOSITORY_NAME} PROJECT_NAME=${2} DB_NAME=${DB_NAME} docker compose --env-file ../../traefik/data/.env down

#Remove project directory & .env file
cd ../
sudo rm -rf ./${GITHUB_REPOSITORY_NAME}
sudo rm ./envs/.env-${GITHUB_REPOSITORY_NAME}

#Drop project databases
docker exec -i ${DATABASE_SUBDOMAIN_NAME}-db mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<< "DROP DATABASE ${DB_NAME}; DROP DATABASE ${DB_TEST_NAME};"
