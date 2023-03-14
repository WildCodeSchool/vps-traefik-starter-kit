<!-- TOC -->
* [Prerequisites](#prerequisites)
  * [Install Docker](#install-docker)
  * [Install Docker Compose manually](#install-docker-compose-manually)
  * [Update chmod](#update-chmod)
  * [Install Git](#install-git)
  * [Check that everything is ok](#check-that-everything-is-ok)
<!-- TOC -->

# Prerequisites

## Install Docker

```bash
sudo apt install docker.io
```

## Install Docker Compose manually

https://docs.docker.com/compose/install/linux/#install-the-plugin-manually

```bash
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
```

## Update chmod

```bash
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
sudo chmod 666 /var/run/docker.sock
```

## Install Git

```bash
sudo apt install git
```

## Check that everything is ok

```bash
docker -v
# Docker version 20.10.12, build 20.10.12-0ubuntu4

docker compose version
# Docker Compose version v2.16.0

git --version
# git version 2.34.1
```