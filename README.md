# Lobsters in a minimal Docker container.

[![Build Status](https://travis-ci.org/jamesbrink/docker-lobsters.svg?branch=master)](https://travis-ci.org/jamesbrink/docker-lobsters) [![Docker Automated build](https://img.shields.io/docker/automated/jamesbrink/lobsters.svg)](https://hub.docker.com/r/jamesbrink/lobsters/) [![Docker Pulls](https://img.shields.io/docker/pulls/jamesbrink/lobsters.svg)](https://hub.docker.com/r/jamesbrink/lobsters/) [![Docker Stars](https://img.shields.io/docker/stars/jamesbrink/lobsters.svg)](https://hub.docker.com/r/jamesbrink/lobsters/) [![](https://images.microbadger.com/badges/image/jamesbrink/lobsters.svg)](https://microbadger.com/images/jamesbrink/lobsters "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/jamesbrink/lobsters.svg)](https://microbadger.com/images/jamesbrink/lobsters "Get your own version badge on microbadger.com")


## About

This repo contains a working example of how to use and deploy [Lobster][lobsters] within a Docker environment.  
I have decided to create this project to assist anyone else wanting to get started with Lobsters quickly using Docker.

This image is built off of the official Ruby Docker image ([ruby:2.3-alpine][ruby-alpine])

## Quick Start

Using this repository.  
This will serve up Lobsters at http://localhost/

```shell
git clone git@github.com:jamesbrink/docker-lobsters.git
cd docker-lobsters
git submodule update --init --recursive
docker-compose up
```

Using the automated docker hub build and official [MariaDB image][mariadb image].  
This will serve up Lobsters at http://localhost:3000/

```shell
docker run --name lobsters -v lobsters_data:/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=lobsters -d mariadb
docker run -p 3000:3000 --link lobsters:mariadb jamesbrink/lobsters
```


[lobsters]: https://github.com/lobsters/lobsters
[ruby-alpine]: https://hub.docker.com/_/ruby/
[mariadb image]: https://hub.docker.com/_/mariadb/
