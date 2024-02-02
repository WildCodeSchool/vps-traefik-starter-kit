#Stop all mailhog containers for better performance
if [ "$(docker container ls -q --filter name=mailhog)" ]; then
docker container stop $(docker container ls -q --filter name=mailhog)
fi

#Create projects directory if not exists
mkdir -p "../../projects/envs"

#Clone the repository if not exists
if [ ! -d "../../projects/${1}" ]; then
  cd "../../projects/"
  git clone https://github.com/WildCodeSchool/${1}
  cd -
fi

#Update main branch
cd "../../projects/${1}"
git checkout main
git pull origin main --rebase

#print Github action vars to project .env file
VARS=${3}
echo $VARS | jq 'to_entries[] | "\(.key)=\(.value)"' | sed 's/"//g' > ../envs/.env-${1}

#Build and start Docker container and their services
GITHUB_REPOSITORY_NAME=${1} PROJECT_NAME=${2} DB_NAME=`echo "${1}" | sed 's/\-/\_/g'` docker compose --env-file ../../traefik/data/.env up -d --build --remove-orphans --force-recreate

#Restart mailhog containers
if [ "$(docker container ls -qa --filter name=mailhog)" ]; then
docker container restart $(docker container ls -qa --filter name=mailhog)
fi