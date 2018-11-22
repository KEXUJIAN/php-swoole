FROM php:7.2.5-cli-stretch
COPY php-date.ini /usr/local/etc/php/conf.d/
COPY zip-1.15.4.tgz /
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && cp /etc/apt/sources.list /etc/apt/sources.list.bac \
    && { \
            echo "deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib"; \
            echo "deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib"; \
            echo "deb http://mirrors.aliyun.com/debian-security stretch/updates main"; \
            echo "deb-src http://mirrors.aliyun.com/debian-security stretch/updates main"; \
            echo "deb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib"; \
            echo "deb-src http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib"; \
            echo "deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib"; \
            echo "deb-src http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib"; \
        } | tee /etc/apt/sources.list \
    && apt-get update \ 
    && apt-get -y --no-install-recommends install \
        locales \
        locales-all \
        git \
        zip \
        unzip \
        libzip-dev \
    && pecl install zip-1.15.4.tgz \
    && docker-php-ext-enable zip \
    && rm -f /zip-1.15.4.tgz

ENV LANG zh_CN.UTF-8
ENV LANGUAGE zh_CN:zh
ENV LC_ALL zh_CN.UTF-8

# 安装 composer 并更换源
COPY composer-1.7.3 /
RUN cp /composer-1.7.3 /usr/local/sbin/composer \ 
    && sync && chmod +x /usr/local/sbin/composer \
    && composer config -g repo.packagist composer https://packagist.laravel-china.org \
    && apt-get install -y --no-install-recommends libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql \
    && rm -rf /var/lib/apt/lists/* \
    && \
        { \
            echo "if [ -f ~/.bash_aliases ]; then"; \
            echo "    . ~/.bash_aliases"; \
            echo "fi"; \
        } | tee /root/.bashrc \
    && touch /root/.bash_aliases \
    && \
        { \
            echo "alias ls='ls --color=auto'"; \
            echo "alias ll='ls --color=auto -al'"; \
            echo "alias l='ls --color=auto -lA'"; \
            echo 'alias sf="php bin/console"'; \
        } | tee /root/.bash_aliases

# 安装 Swoole
COPY install-swoole.sh /
COPY swoole-4.2.8.tgz /root/build/tmp/
RUN cd / && chmod +x /install-swoole.sh && sync \
    && /install-swoole.sh \
    && rm -f /install-swoole.sh && rm -rf /root/build \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /composer-1.7.3 \
    && touch ~/.composer/composer.json \
    && echo "{}" > ~/.composer/composer.json
EXPOSE 80
EXPOSE 8096
