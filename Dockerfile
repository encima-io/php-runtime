FROM php:8.2-fpm-alpine

LABEL maintainer="Einar-Johan Hansen"

COPY --from=mlocati/php-extension-installer:1.5.51 /usr/bin/install-php-extensions /usr/local/bin/

RUN apk update && apk add bash git zip unzip supervisor libpng libxml2 sqlite jpegoptim optipng pngquant gifsicle

RUN chmod +x /usr/local/bin/install-php-extensions && \
   install-php-extensions gd \
   pdo_pgsql pgsql lzf \
   zip bcmath zstd \
   intl ldap imagick pcntl exif \
   msgpack igbinary redis

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --from=composer/composer:2.4.4-bin /composer /usr/bin/composer

COPY php.ini $PHP_INI_DIR/conf.d/99-develop.ini

RUN set -eux; \
   if [ ! -d /.composer ]; then \
       mkdir /.composer; \
   fi; \
   chmod -R ugo+rw /.composer;  \
   if [ ! -d /var/log/supervisor/ ]; then  \
       mkdir /var/log/supervisor;  \
   fi;

WORKDIR /var/www/html

CMD ["php-fpm"]

