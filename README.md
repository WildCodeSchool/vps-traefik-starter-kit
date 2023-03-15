# Traefik starter kit for VPS

## Prerequisites

Must be installed on the VPS before anything else

- Docker
- Docker Compose
- Git
- htpasswd utility from apache2-utils

See [Prerequisites](PREREQUISITES.md) page for more information.

## Configure and start Traefik

First, clone this repository in a `traefik` directory and `cd` in it.

```bash
git clone https://github.com/WildCodeSchool/vps-traefik-starter-kit.git traefik
cd traefik
```

The file `install.sh` is ready to configure and start Traefik automatically.
Simply run the following by replacing with your values.

```bash
bash install.sh \
EMAIL=your_valid_email@example.com \
HOST=your_domain.dev \
USER_NAME=admin \
USER_PASS=password
```

| Var       | Mandatory | Default  | Description                                                                                             |
|-----------|:---------:|----------|:--------------------------------------------------------------------------------------------------------|
| EMAIL     |    yes    |          | Used to generate letsencrypt certificate. <br/> Write a valid email so you will receive renew reminders |
| HOST      |    yes    |          | Your main domain pointing to the VPS. You can note __localhost__ when running Docker in local.          |
| USER_NAME |    no     | admin    | User login to Traefik dashboard                                                                         |
| USER_PASS |    no     | password | User password to log in Traefik dashboard                                                               |

Once this is done, Traefik is ready to process proxy requests.  
The Traefik dashboard is accessible at https://traefik.your_domain.dev with the credentials you provided (
your_domain.dev replaced by your domain).

## Mount a Mysql database with Phpmyadmin

Move to database directory
```bash
cd database
```

Configure and start database container.
```bash
PROJECT_NAME=database \
HOST=your_domain.dev \
MYSQL_USER=user \
MYSQL_PASSWORD=password \
MYSQL_ROOT_PASSWORD=rootpassword \
docker compose up -d
```

| Var                 | Mandatory |   Default    | Description                                                                                                                                |
|---------------------|:---------:|:------------:|--------------------------------------------------------------------------------------------------------------------------------------------|
| PROJECT_NAME        |    No     |   database   | Name given to the container and used to create docker volume `database-db`, container `database-db` and subdomain.                         |
| HOST                |    Yes    |              | Your main domain pointing to the VPS. You can note __localhost__ when running Docker in local.                                             |
| MYSQL_USER          |    No     |     user     | Main user created when docker build the image and granted with all privileges. Can access to database from external container on port 3306 |
| MYSQL_PASSWORD      |    No     |   password   | Main user password                                                                                                                         |
| MYSQL_ROOT_PASSWORD |    No     | rootpassword | Root password needed when connect to mysql from internal service container. <br/>Connection with root is disabled from external.           |

When done, PhpMyadmin is reachable at something like https://pma.database.your_domain.dev where `database` depends on
the value of PROJECT_NAME and `your_domain.dev` on the value of HOST.
This database will be persisted thanks to `database-db` volume and reachable from any external container
with `database-db` container name.  
Example:
```dotenv
DATABASE_URL="mysql://user:password@database-db:3306/my_app?serverVersion=8&charset=utf8mb4"
```

## Deploy your projects