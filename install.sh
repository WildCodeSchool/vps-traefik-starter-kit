helpFunction()
{
   echo "Usage: sh $0 EMAIL=some_email@example.com HOST=your_domain.dev"
   echo "\tEMAIL a valid email needed to generate letsencrypt certificate"
   echo "\tHOST indicate the main domain pointing to your VPS IP"
   echo "\tUSER_NAME indicate the user name for traefik dashboard (optional - default admin)"
   echo "\tUSER_PASS indicate the user password for traefik dashboard (optional - default password)"
   exit 1 # Exit script after printing help
}

for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"
   if [ ! -z "$VALUE" ]; then
    export "$KEY"="$VALUE"
   fi
done

if [ -z "$EMAIL" ] || [ -z "$HOST" ]
then
   echo "Some or all of mandatory parameters are missing or empty";
   helpFunction
fi

cp ./data/traefik.dist.yml ./data/traefik.yml
sed -i -e "s/replaceWithYourMail/$EMAIL/g" ./data/traefik.yml
if test -f ./data/traefik.yml; then
  rm ./data/traefik.yml-e
fi

CREDENTIALS=$(htpasswd -nbBC 10 ${USER_NAME:-admin} ${USER_PASS:-password} | sed 's/\//\\\//g')
cp ./data/configurations/dynamic.dist.yml ./data/configurations/dynamic.yml
sed -i -e "s/credentials/$CREDENTIALS/g" ./data/configurations/dynamic.yml
if test -f ./data/configurations/dynamic.yml-e; then
  rm ./data/configurations/dynamic.yml-e
fi


touch ./data/acme.json

docker network create proxy

docker compose down
HOST_DOMAIN=$HOST docker compose up -d

echo "Installation done."
echo "Visit Traefik dashboard here https://traefik.${HOST}."