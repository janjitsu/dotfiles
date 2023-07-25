#!/bin/bash
#docker

alias docker-compose='docker compose $@'

function dockerip() { docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1; }

