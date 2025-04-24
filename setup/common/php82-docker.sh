#!/bin/bash

# based on this post
# @see https://viktorprogger.name/posts/how-to-use-php-without-installing.html#php

IMAGE_NAME="myphp:8.2"
TARGET_PATH="$HOME/.local/bin"
PHP_PATH="$TARGET_PATH/php82"
COMPOSER_PATH="$TARGET_PATH/composer82"

COMPOSER_FILES_PATH="$HOME/.local/share/php82-docker/composer"
COMPOSER_CACHE_DIR="$COMPOSER_FILES_PATH/cache/files"


# Build image if not exists or --build flag passed
if [[ "$1" == "--build" || "$(docker images -q $IMAGE_NAME 2>/dev/null)" == "" ]]; then
    if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" != "" ]]; then
        echo "🗑️  Removing older image: $IMAGE_NAME..."
        docker ps -a -q --filter "ancestor=$IMAGE_NAME" | xargs --no-run-if-empty docker rm -f  # Remove containers using the image
        docker images -q $IMAGE_NAME | xargs --no-run-if-empty docker rmi -f  # Remove the image
    fi

    echo "📦 Building PHP 8.2 Docker image: $IMAGE_NAME..."
    docker build -t $IMAGE_NAME - <<'EOF'
FROM php:8.2-cli

# Install system deps and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    libcurl4-openssl-dev \
    libxml2-dev libonig-dev \
    default-mysql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install \
    curl \
    zip \
    dom \
    fileinfo \
    mbstring \
    pdo_mysql \
    xml

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
EOF
echo "✅ Build complete."
fi


echo "🗃️ Creating composer cache folder in $COMPOSER_CACHE_DIR"

mkdir -p "$COMPOSER_CACHE_DIR";
chown -R $(id -u):$(id -g) "$COMPOSER_CACHE_DIR"

echo "💾 Creating executable in $PHP_PATH"
mkdir -p $TARGET_PATH

cat <<EOF > "$PHP_PATH"
#!/bin/bash

docker run -it --rm \
  --user "$(id -u):$(id -g)" \
  -e COMPOSER_HOME=/composer-data/.composer \
  -e COMPOSER_CACHE_DIR=/composer-data/.composer/cache \
  -e SSH_AUTH_SOCK=/ssh-auth.sock \
  -v "\$(pwd)":/app \
  -v "$COMPOSER_FILES_PATH":/composer-data/.composer \
  -v /run/user/$(id -u)/keyring/ssh:/ssh-auth.sock \
  -v /etc/passwd:/etc/passwd:ro \
  -v /etc/group:/etc/group:ro \
  -w /app \
  $IMAGE_NAME php "\${@:1}"
EOF
chmod +x "$PHP_PATH"
[ -f "$PHP_PATH" ] && echo "✅ Done"


echo "💾 Creating executable in $COMPOSER_PATH"

cat <<EOF > "$COMPOSER_PATH"
#!/bin/bash

docker run -it --rm \
  --user "$(id -u):$(id -g)" \
  -e COMPOSER_HOME=/composer-data/.composer \
  -e COMPOSER_CACHE_DIR=/composer-data/.composer/cache \
  -e SSH_AUTH_SOCK=/ssh-auth.sock \
  -v "\$(pwd)":/app \
  -v "$COMPOSER_FILES_PATH":/composer-data/.composer \
  -v /run/user/$(id -u)/keyring/ssh:/ssh-auth.sock \
  -v /etc/passwd:/etc/passwd:ro \
  -v /etc/group:/etc/group:ro \
  -w /app \
  $IMAGE_NAME composer "\${@:1}"
EOF
chmod +x "$COMPOSER_PATH"
[ -f "$COMPOSER_PATH" ] && echo "✅ Done"

# troubleshooting - run interactivelly as root
#docker run -it --rm \
#    --user "root:$(id -g)" \
#    -e COMPOSER_HOME=/composer-data/.composer \
#    -e COMPOSER_CACHE_DIR=/composer-data/.composer/cache \
#    -e SSH_AUTH_SOCK=/ssh-auth.sock \
#    -v "$(pwd)":/app \
#    -v "$HOME/.php82/composer":/composer-data/.composer \
#    -v /run/user/$(id -u)/keyring/ssh:/ssh-auth.sock \
#    -v /etc/passwd:/etc/passwd:ro \
#    -v /etc/group:/etc/group:ro \
#    -w /app \
#    $IMAGE_NAME /bin/bash
