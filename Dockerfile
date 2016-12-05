FROM php:5.6.28-apache

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y imagemagick libpng-dev
RUN a2enmod rewrite
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install gd

ADD src/ /var/www/html/
ADD extras/config.php /var/www/html/forum/

RUN mkdir -p /var/www/html/forum/cache \
  && chmod 770 /var/www/html/forum/cache \
  && chown www-data:www-data /var/www/html/forum/cache
