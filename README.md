<!-- TOC -->

* [Traefik starter kit for VPS](#traefik-starter-kit-for-vps)
    * [Prerequisites](#prerequisites)
    * [Step1 - Configure and start Traefik](#step1---configure-and-start-traefik)
    * [Step2 - Mount a Mysql database with Phpmyadmin](#step2---mount-a-mysql-database-with-phpmyadmin)
    * [Deploy your projects](#deploy-your-projects)
        * [For Simple-MVC & Symfony starter kits.](#for-simple-mvc--symfony-starter-kits)
        * [Let's Encrypt SSL certificates explanations](#lets-encrypt-ssl-certificates-explanations)
    * [Troubleshooting & useful commands](#troubleshooting--useful-commands)

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
Create `.env` file from `.env.sample` in `/data` directory, edit values and save.

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
| APP_SECRET              | Secret key needed to produce JWT tokens (**only for the JS template**).                                                                                                                |

Once this is done, simply run the script.

```bash
bash install.sh
```

Traefik is then ready to process proxy requests.  
The Traefik dashboard is accessible at [https://traefik.your_domain.dev](https://traefik.your_domain.dev) with the
credentials you provided (your_domain.dev replaced by your domain).

## Step2 - Mount a Mysql database with Phpmyadmin

If you have correctly filled in all the fields in the .env file from step 1, just run the following command.

```bash
docker compose --env-file ./data/.env -f ./database/docker-compose.yml up -d
```

When done, PhpMyadmin is reachable at something
like [https://pma.database.your_domain.dev](https://pma.database.your_domain.dev) where `database` depends on
the value of DATABASE_SUBDOMAIN_NAME and `your_domain.dev` on the value of HOST.
This database will be persisted thanks to `database-db` volume and reachable from any external container
with `database-db` container name.  
Example:

```dotenv
DATABASE_URL="mysql://user:password@database-db:3306/my_app?serverVersion=8&charset=utf8mb4"
```

## Deploy your projects

Warning: ensure your GitHub repository is public, or the deployment process will fail.

### For Simple-MVC & Symfony starter kits.

The `php-project.sh` file in the `deploy` directory can be used by Github action to trigger deployment, updates and
build of Docker containers automatically.
You just have to add on each git repository three following secret variables and an environment variable as shown below.

| Name         |   Type   | Path from git repository    | Description                                                                                                                                                                                                                                                                                                                                      |
|--------------|:--------:|-----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SSH_HOST     |  secret  | /settings/secrets/actions   | Your VPS IP address                                                                                                                                                                                                                                                                                                                              |
| SSH_USER     |  secret  | /settings/secrets/actions   | Your ssh user name                                                                                                                                                                                                                                                                                                                               |
| SSH_PASSWORD |  secret  | /settings/secrets/actions   | Your ssh user password                                                                                                                                                                                                                                                                                                                           |
| PROJECT_NAME | variable | /settings/variables/actions | The name you want to give to the project. This name will be used to generate the Docker container as well as the subdomain and associated services (e.g. https://project-name.your-domain.wilders.dev, https://mailhog.project-name.your-domain.wilders.dev, etc.). ⚠️ Be careful not to use underscores in the project name but rather hyphens. |
| APP_ENV      | variable | /settings/variables/actions | [optional]  Deployment environment (dev, test, prod)                                                                                                                                                                                                                                                                                             |

No prior configuration is required. Deployments are based on the Dockerfile and docker-compose.yml files integrated in
each project.  
The projects are automatically cloned in the `~/projects` directory in the root of the user folder. The names of the git
repositories used to generate the associated databases. That's all!

Github CLI can be very useful to generate very quickly the secret variables from an `.env` file.
See [https://cli.github.com/manual/gh_secret_set](https://cli.github.com/manual/gh_secret_set) for further
information.  

### For JS template projects
Same configuration as above. `js-project.sh` will be triggered by the Github action workflow.

## Let's Encrypt SSL certificates explanations

SSl certificates are generated by [Let's Encrypt](https://letsencrypt.org/) automatically each time a project is
deployed for the first time and store on the server in the `/traefik/data/acme.json` file. Certificates have
a [lifetime of 90 days](https://letsencrypt.org/2015/11/09/why-90-days.htm). You will receive renewal notifications by
e-mail according to this period and for each domain name.
To regenerate one or more certificates, simply restart Traefik. Run the command below from the `/traefik` folder:

```bash
bash restart.sh
```

## Troubleshooting & useful commands

In the event of a problem, you can consult the real-time logs of each project's Docker images.

```bash
cd ~/traefik/deploy && bash logs-project.sh <name-of-the-project-directory>
#example
#cd ~/traefik/deploy && bash logs-project.sh 2023-03-remote-fr-project-1
```

If needed, restart Docker

```bash
sudo service docker restart
```

Clean stopped containers, dangling images and dangling build cache

```bash
docker system prune -a
```
