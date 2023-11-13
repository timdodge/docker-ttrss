# Using https://github.com/gliderlabs/docker-alpine,
# plus  https://github.com/just-containers/s6-overlay for a s6 Docker overlay.
FROM docker.io/alpine:3 AS builder
# Initially was based on work of Christian Lück <christian@lueck.tv>.
LABEL description="A complete, self-hosted Tiny Tiny RSS (TTRSS) environment." 
ARG S6_OVERLAY_VERSION=3.1.3.0

RUN set -xe && \
    apk update && apk upgrade && \
    apk add --no-cache --virtual=run-deps \
    busybox nginx git ca-certificates curl \
    php82 php82-fpm php82-phar php82-sockets php82-pecl-apcu \
    php82-pdo php82-gd php82-pgsql php82-pdo_pgsql php82-xmlwriter php82-opcache \
    php82-mbstring php82-intl php82-xml php82-curl php82-simplexml \
    php82-session php82-tokenizer php82-dom php82-fileinfo php82-ctype \
    php82-json php82-iconv php82-pcntl php82-posix php82-zip php82-exif \
    php82-openssl sudo php82-pecl-xdebug rsync tzdata \
    tar xz

# Add user www-data for php-fpm.
# 82 is the standard uid/gid for "www-data" in Alpine.
RUN adduser -u 82 -D -S -G www-data www-data

# Copy root file system.
COPY root /

# Add s6 overlay.
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

# Add wait-for-it.sh
ADD https://raw.githubusercontent.com/Eficode/wait-for/v2.2.4/wait-for /srv
RUN chmod 755 /srv/wait-for

# Expose Nginx ports.
EXPOSE 8080
EXPOSE 4443

# Expose default database credentials via ENV in order to ease overwriting.
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME 0

# Clean up.
RUN set -xe && apk del --progress --purge && rm -rf /var/cache/apk/* && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/init"]
