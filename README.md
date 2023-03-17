<!-- TOC -->

* [Traefik starter kit for VPS](#traefik-starter-kit-for-vps)
    * [Prerequisites](#prerequisites)
    * [Step1 - Configure and start Traefik](#step1---configure-and-start-traefik)
    * [Step2 - Mount a Mysql database with Phpmyadmin](#step2---mount-a-mysql-database-with-phpmyadmin)
    * [Deploy your projects](#deploy-your-projects)

<!-- TOC -->

# Traefik starter kit for VPS

## Prerequisites

Must be installed on the VPS before anything else

- Docker
- Docker Compose
- Git
- htpasswd utility from apache2-utils

See [Prerequisites](PREREQUISITES.md) page for more information.

## Step1 - Configure and start Traefik

First, clone this repository in a `traefik` directory and `cd` in it.

```bash
git clone https://github.com/WildCodeSchool/vps-traefik-starter-kit.git traefik
cd traefik
```

The file `install.sh` is ready to configure and start Traefik automatically.
Create `.env` file from `.env.sample` ind `/data` directory, edit values and save.

```bash
cp ./data/.env.sample ./data/.env
nano ./data/.env
```

| Var                     | Description                                                                                                                                                                            |
|-------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| HOST                    | Your main domain pointing to the VPS. You can write __localhost__ when running Docker in local.                                                                                        |
| LETS_ENCRYPT_EMAIL      | Used to generate letsencrypt certificate. <br/> Write a valid email so you will receive renew reminders.                                                                               |
| USER_NAME               | User login to Traefik dashboard. Will also be used to create a user with all privileges when installing the database. <br/>Can access to database from external container on port 3306 |
| USER_PASSWORD           | User password to log in Traefik dashboard. Will be used for main user database too.                                                                                                    |
| DATABASE_SUBDOMAIN_NAME | Name given to the container and used to create docker volume `database-db`, container `database-db` and subdomain.                                                                     |
| MYSQL_ROOT_PASSWORD     | Root password needed when connect to mysql from internal service container. <br/>Connection with root is disabled from external.                                                       |

Once this is done, simply run the script.
```bash
bash install.sh
```

Traefik is then ready to process proxy requests.  
The Traefik dashboard is accessible at https://traefik.your_domain.dev with the credentials you provided (your_domain.dev replaced by your domain).

## Step2 - Mount a Mysql database with Phpmyadmin

If you have correctly filled in all the fields in the .env file from step 1, just run the following command.

```bash
docker compose --env-file ./data/.env -f ./database/docker-compose.yml up -d
```

When done, PhpMyadmin is reachable at something like https://pma.database.your_domain.dev where `database` depends on
the value of DATABASE_SUBDOMAIN_NAME and `your_domain.dev` on the value of HOST.
This database will be persisted thanks to `database-db` volume and reachable from any external container
with `database-db` container name.  
Example:

```dotenv
DATABASE_URL="mysql://user:password@database-db:3306/my_app?serverVersion=8&charset=utf8mb4"
```

## Deploy your projects

