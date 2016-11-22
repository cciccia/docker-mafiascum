FROM php:7.0.13-apache

RUN a2enmod rewrite

ADD src/ /var/www/html/
ADD extras/config.php /var/www/html/forum/
