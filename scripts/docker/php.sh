#!/bin/bash
# create docker image for php 8.2 with extensions
# add an executable with the /usr/bin/php82 that will run the container
cat <<DOCKERFILE | docker build -t php82:latest --progress=plain -
FROM php:8.2-cli

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN apt-get update

RUN apt-get install -y \
libmcrypt-dev \
libmagickwand-dev \
libicu-dev \
zip unzip git \
--no-install-recommends && \
pecl install mcrypt xdebug imagick && \
docker-php-ext-enable mcrypt xdebug imagick && \
docker-php-ext-configure intl && \
docker-php-ext-install intl
DOCKERFILE
