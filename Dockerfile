FROM composer:latest as builder

ARG AIMEOS_VERSION

# RUN apk --no-cache add mysql-client msmtp perl wget procps shadow libzip libpng libjpeg-turbo libwebp freetype icu icu-data-full

RUN apk --no-cache add icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd mysqli pdo_mysql intl opcache exif zip

WORKDIR /opt
RUN curl -JL https://github.com/modulairy/aimeos/archive/refs/tags/${AIMEOS_VERSION}.zip -o ./${AIMEOS_VERSION}.zip && unzip /opt/${AIMEOS_VERSION}.zip
RUN mkdir webshop && mv aimeos-${AIMEOS_VERSION}/* webshop/ 

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
