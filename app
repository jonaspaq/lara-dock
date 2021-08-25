#!/usr/bin/env bash

# Show docker version
function dockerversion {
    docker --version
}

# Initialize the app
function init {
    docker build -f ./.docker/Dockerfile -t php-preset .
    docker run -d -p 9000:9000 --name php-preset --rm -v ${PWD}:'/app' php-preset
    docker exec php-preset composer create-project laravel/laravel src
    
    docker container rm -f php-preset
    docker image rm -f php-preset

    echo -e "\n\033[0;34m Please set your environment variables in /src/.env."
}

function enter {
    THECONTAINER=$1

    echo Entering $THECONTAINER container.
    docker-compose exec $THECONTAINER sh
}

function copy_env {
    THEENVFILE=./src/.env
    if ! test -f "$THEENVFILE"
    then 
        echo ❕ Please setup an .env file first!
        return
    fi

    cp ./src/.env .env
}

# Run docker container for the app
function up {
    copy_env

    docker-compose up -d
}

# Stop docker container for the app
function down {
    docker-compose down
}

# Restart the docker container for the app
function restart {
    copy_env

    # We are not using docker-compose restart because sometimes some methods are not 
    # enforced when only doing docker-compose restart
    docker-compose down
    docker-compose up -d
}

function reset_myql {
    rm -rf ./.docker/.mysql

    restart

    echo -e "\n\033[0;34m Please redo your migrations."
    echo -e "\n\033[0;34m If you encounter an error when opening phpmyadmin please wait a few minutes and then refresh."
}

params=$1

case $params in 
    dv)
        dockerversion $1
        ;;
    init)
        init
        ;;
    enter)
        enter $2
        ;;
    up)
        up
        ;;
    down)
        down
        ;;
    restart)
        restart
        ;;
    reset:mysql)
        reset_myql
        ;;
esac
