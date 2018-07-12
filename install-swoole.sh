#!/bin/bash
apt-get update
apt-get install -y --no-install-recommends libpcre3 libpcre3-dev libssl-dev libnghttp2-dev

mkdir -p ~/build
cd ~/build
mkdir -p tmp
SWOOLE_VERSION=4.0.1
rm -rf ./swoole-${SWOOLE_VERSION}
tar zxvf ./tmp/swoole-${SWOOLE_VERSION}.tgz
mv swoole-${SWOOLE_VERSION}* swoole-${SWOOLE_VERSION}
cd swoole-${SWOOLE_VERSION}
phpize
./configure --enable-openssl  \
        --enable-http2  \
        --enable-mysqlnd
make clean && make && make install

docker-php-ext-enable swoole
