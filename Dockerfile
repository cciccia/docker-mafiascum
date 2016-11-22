FROM php:7.0.13-apache

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y imagemagick
RUN a2enmod rewrite
RUN docker-php-ext-install mysqli

ADD src/ /var/www/html/
ADD extras/config.php /var/www/html/forum/

RUN mkdir -p /var/www/html/forum/cache \
  && chmod 770 /var/www/html/forum/cache \
  && chown www-data:www-data /var/www/html/forum/cache
