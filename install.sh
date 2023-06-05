#Import ENV vars
set -o allexport
source ./data/.env
set +o allexport

#Set EMAIL for Let's Encrypt
cp ./data/traefik.dist.yml ./data/traefik.yml
sed -i -e "s/replaceWithYourMail/$LETS_ENCRYPT_EMAIL/g" ./data/traefik.yml
if test -f ./data/traefik.yml-e; then
  rm ./data/traefik.yml-e
fi
touch ./data/acme.json
chmod 600 ./data/acme.json

#Set credentials for Traefik dashboard
CREDENTIALS=$(htpasswd -nbBC 10 ${USER_NAME:-user} ${USER_PASSWORD:-password} | sed 's/\//\\\//g')
cp ./data/configurations/dynamic.dist.yml ./data/configurations/dynamic.yml
sed -i -e "s/credentials/$CREDENTIALS/g" ./data/configurations/dynamic.yml
if test -f ./data/configurations/dynamic.yml-e; then
  rm ./data/configurations/dynamic.yml-e
fi

#Create main network. Used by future Docker containers to generate subdomains automatically
docker network create proxy

#Build and start Traefik
docker compose down
HOST=$HOST docker compose up -d

echo "Installation done."
echo "Visit Traefik dashboard here https://traefik.${HOST}."