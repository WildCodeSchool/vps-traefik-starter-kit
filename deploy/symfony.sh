if [ ! -d "../../projects/ " ]; then
  mkdir "../projects"
fi
if [ ! -d "../../projects/${1} " ]; then
  cd "../../projects/"
  git clone https://github.com/WildCodeSchool/${1}
  cd -
fi

cd "../../projects/${1}"
git pull origin main
ENV_FILE=./.env.local
if test -f "$ENV_FILE"; then
    docker compose up -d --build --remove-orphans --force-recreate
else
    echo "file $ENV_FILE not found!"
fi
