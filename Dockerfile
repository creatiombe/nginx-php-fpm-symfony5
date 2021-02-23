FROM richarvey/nginx-php-fpm

LABEL maintainer="Jan Ooms <jan@creatiom.be>"

ENV TZ 'Europe/Brussels'
ENV LANG 'nl_BE.UTF-8'
ENV LANGUAGE 'nl_BE.UTF-8'
ENV LC_ALL 'nl_BE.UTF-8'
ENV APP_ENV 'dev'
ENV NODE_ENV 'dev'
ENV APP_SECRET ''
ENV DATABASE_URL 'mysql://db:db@db/db'
ENV APP_DEBUG false
ENV MAILER_URL ~
ENV API_URL 'http://127.0.0.1:8080'
ENV PROXY_URL 'http://127.0.0.1:8080'
ENV TRUSTED_PROXIES '127.0.0.1,10.244.0.0/16,10.245.0.0/16,10.0.0.0/8,167.99.19.77'
ENV TRUSTED_HOSTS ''
ENV CORS_ALLOW_ORIGIN .
ENV BACKEND_DOMAIN ''
ENV API_DOMAIN ''
ENV FRONTEND_DOMAIN ''
ENV MUSL_LOCPATH '/usr/share/i18n/locales/musl'
ENV COMPOSER_MEMORY_LIMIT -1
ENV WKHTMLTOPDF_PATH '/usr/bin/wkhtmltopdf'
ENV WKHTMLTOIMAGE_PATH '/usr/bin/wkhtmltoimage'
ENV WKHTML_BASEPATH 'http://127.0.0.1:8080'

RUN apk update && apk upgrade &&\
    apk add --no-cache \
    gcc musl-dev linux-headers \
    libffi-dev augeas-dev \
    python3-dev make autoconf \
    rabbitmq-c \
    rabbitmq-c-dev \
    imagemagick-dev \
    musl-dev \
    libintl \
    libpng-dev \
    icu-dev \
    libpq \
    libxslt-dev \
    libffi-dev \
    freetype-dev \
    sqlite-dev \
    libgcc libstdc++ libx11 glib libxrender libxext libintl ghostscript \
    ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family \
    wkhtmltopdf && \
    pecl install -o -f imagick && \
    echo "extension=imagick.so" > /usr/local/etc/php/conf.d/imagick.ini && \
    pecl install -o -f amqp && \
    echo "extension=amqp.so" > /usr/local/etc/php/conf.d/amqp.ini && \
    pecl install -o -f apcu && \
    echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini


# nginx site conf
RUN mkdir -p /etc/nginx/sites-available/ && \
mkdir -p /etc/nginx/sites-enabled/ && \
mkdir -p /etc/nginx/ssl/ && \
rm -Rf /var/www/* && \
mkdir -p /var/www/html/ && \
sed -i -e "s/memory_limit\s*=\s*128M/memory_limit = -1/g" ${fpm_conf}
COPY conf/nginx-site.conf /etc/nginx/sites-available/default.conf
COPY conf/nginx-site-ssl.conf /etc/nginx/sites-available/default-ssl.conf
COPY scripts/start.sh /start.sh

EXPOSE 8443 8080