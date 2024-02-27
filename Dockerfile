# FROM composer:latest as builder
# #FROM php:8.3.3-alpine3.19
# RUN apk add --no-cache mysql-client msmtp perl wget procps shadow libzip libpng libjpeg-turbo libwebp freetype icu icu-data-full

# RUN apk add --no-cache --virtual build-essentials \
#     icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev \
#     libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev && \
#     docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
#     docker-php-ext-install gd && \
#     docker-php-ext-install mysqli && \
#     docker-php-ext-install pdo_mysql && \
#     docker-php-ext-install intl && \
#     docker-php-ext-install opcache && \
#     docker-php-ext-install exif && \
#     docker-php-ext-install zip && \
#     apk del build-essentials && rm -rf /usr/src/php*

# WORKDIR /opt
# RUN rm -rf /opt/webshop
# # RUN wget https://getcomposer.org/download/latest-stable/composer.phar -O composer
# RUN wget https://github.com/modulairy/aimeos/archive/refs/tags/2024.02.zip && unzip 2024.02.zip 
# RUN mkdir webshop && mv aimeos-2024.02/* webshop/ 
# RUN rm -r aimeos-2024.02 && rm 2024.02.zip

# WORKDIR /opt/webshop

# RUN composer install

# # RUN rm -rf /opt/webshop && php composer create-project aimeos/aimeos webshop

# # WORKDIR /opt/webshop

# # ENTRYPOINT [ "sleep","100000000" ]

# # ENTRYPOINT [ "php","artisan","serve" ]

# FROM php:8.3.3-apache-bookworm
# # FROM php:8.3.3-fpm-alpine3.18

# RUN apt-get update -y

# # RUN apt install mysql-client

# # RUN apt-get install -y mysql-client 
# # msmtp perl wget procps shadow libzip libpng libjpeg-turbo libwebp freetype icu icu-data-full
# RUN apt-get install -y libfreetype-dev 

# RUN apt-get install -y libjpeg62-turbo-dev
# RUN apt-get install -y libpng-dev 
# RUN apt-get install -y libwebp-dev
# RUN apt-get install -y msmtp
# RUN apt-get install -y libicu-dev icu-devtools
# RUN apt-get install -y libzip-dev
# # shadow libzip  perl wget
# RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp

# RUN docker-php-ext-install gd
# RUN docker-php-ext-install mysqli
# RUN docker-php-ext-install pdo_mysql 
# RUN docker-php-ext-install intl
# RUN docker-php-ext-install opcache
# RUN docker-php-ext-install exif
# RUN docker-php-ext-install zip

# #  RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# COPY --from=builder /opt/webshop /var/www/html

# RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf
# RUN sed -i '/DocumentRoot \/var\/www\/html\/public/ a\    Options +Indexes' /etc/apache2/sites-available/000-default.conf
# RUN chown -R www-data:www-data /var/www/html

# RUN curl -ks 'https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem' -o '/usr/local/share/ca-certificates/DigiCertGlobalRootCA.crt'
# RUN /usr/sbin/update-ca-certificates

# EXPOSE 80


# ENV APP_NAME=Aimeos
# ENV APP_ENV=local



# RUN chown www-data:www-data -R /var/www && chmod 775 -R /var/www

# RUN chown www-data:www-data -R /app && chmod 775 -R /app



# USER www-data


# Multi-stage build - Builder Stage
FROM composer:latest as builder

# RUN apk --no-cache add mysql-client msmtp perl wget procps shadow libzip libpng libjpeg-turbo libwebp freetype icu icu-data-full

RUN apk --no-cache add icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd mysqli pdo_mysql intl opcache exif zip

WORKDIR /opt
RUN curl -JL https://github.com/modulairy/aimeos/archive/refs/tags/2024.02.zip -o ./2024.02.zip && unzip /opt/2024.02.zip
RUN mkdir webshop && mv aimeos-2024.02/* webshop/ 
RUN rm -r aimeos-2024.02 && rm 2024.02.zip

WORKDIR /opt/webshop
RUN composer install

FROM php:8.3.3-apache-bookworm

RUN apt-get update && \
    apt-get install -y libfreetype-dev libjpeg62-turbo-dev libpng-dev libwebp-dev msmtp libicu-dev icu-devtools libzip-dev && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd mysqli pdo_mysql intl opcache exif zip

COPY --from=builder /opt/webshop /var/www/html

RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf && \
    sed -i '/DocumentRoot \/var\/www\/html\/public/ a\    Options +Indexes' /etc/apache2/sites-available/000-default.conf && \
    chown -R www-data:www-data /var/www/html

RUN curl -ks 'https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem' -o '/usr/local/share/ca-certificates/DigiCertGlobalRootCA.crt' && \
    /usr/sbin/update-ca-certificates
RUN a2enmod rewrite

EXPOSE 80

# Environment Variables
ENV APP_NAME=Aimeos
ENV APP_ENV=local
ENV APP_KEY=
ENV APP_DEBUG=false
ENV APP_VERSION=1
ENV APP_URL=http://localhost
ENV SHOP_MULTILOCALE=false
ENV SHOP_MULTISHOP=false
ENV SHOP_REGISTRATION=false
ENV SHOP_PERMISSION=admin

ENV LOG_CHANNEL=stack

ENV DB_CONNECTION=mysql
ENV DATABASE_URL=
ENV DB_HOST=
ENV DB_PORT=3306
ENV DB_DATABASE=
ENV DB_USERNAME=
ENV DB_PASSWORD=
ENV MYSQL_ATTR_SSL_VERIFY_SERVER_CERT=
ENV MYSQL_ATTR_SSL_CA=
ENV BROADCAST_DRIVER=log
ENV CACHE_DRIVER=file
ENV QUEUE_CONNECTION=sync
ENV SESSION_DRIVER=file
ENV SESSION_LIFETIME=120

ENV REDIS_HOST=127.0.0.1
ENV REDIS_PASSWORD=null
ENV REDIS_PORT=6379

ENV MAIL_MAILER=smtp
ENV MAIL_HOST=smtp.mailtrap.io
ENV MAIL_PORT=2525
ENV MAIL_USERNAME=null
ENV MAIL_PASSWORD=null
ENV MAIL_ENCRYPTION=null

ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=
ENV AWS_DEFAULT_REGION=us-east-1
ENV AWS_BUCKET=

ENV PUSHER_APP_ID=
ENV PUSHER_APP_KEY=
ENV PUSHER_APP_SECRET=
ENV PUSHER_APP_CLUSTER=mt1

ENV MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
ENV MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

CMD ["apache2-foreground"]
