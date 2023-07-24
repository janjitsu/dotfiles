#!/bin/bash

### Bash aliases to use php through docker
# @author https://viktorprogger.name/posts/how-to-use-php-without-installing.html#php

alias php='docker run --rm -it -u `id -u`:`id -g` --volume `pwd`:/app -w /app ghcr.io/mileschou/xdebug:8.1 php  $@'
alias composer='docker run --rm -it --tty -u 1000:1000 -e COMPOSER_HOME=/composer-data/.composer -e COMPOSER_CACHE_DIR=/composer-data/.composer/cache -e SSH_AUTH_SOCK=/ssh-auth.sock --volume `pwd`:/app --volume /home/`whoami`/.composer:/composer-data/.composer --volume /run/user/1000/keyring/ssh:/ssh-auth.sock --volume /etc/passwd:/etc/passwd:ro --volume /etc/group:/etc/group:ro composer:2 $@'

