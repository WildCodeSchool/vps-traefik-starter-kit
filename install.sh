set -o allexport
source ./data/.env
set +o allexport

cp ./data/traefik.dist.yml ./data/traefik.yml
sed -i -e "s/replaceWithYourMail/$LETS_ENCRYPT_EMAIL/g" ./data/traefik.yml
if test -f ./data/traefik.yml; then
  rm ./data/traefik.yml-e
fi

CREDENTIALS=$(htpasswd -nbBC 10 ${USER_NAME:-user} ${USER_PASSWORD:-password} | sed 's/\//\\\//g')
cp ./data/configurations/dynamic.dist.yml ./data/configurations/dynamic.yml
sed -i -e "s/credentials/$CREDENTIALS/g" ./data/configurations/dynamic.yml
if test -f ./data/configurations/dynamic.yml-e; then
  rm ./data/configurations/dynamic.yml-e
fi

touch ./data/acme.json

docker network create proxy

docker compose down
HOST=$HOST docker compose up -d

echo "Installation done."
echo "Visit Traefik dashboard here https://traefik.${HOST}."