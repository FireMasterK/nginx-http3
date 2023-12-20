#!/bin/sh

set -e
rm -rf nginx ngx_brotli openssl nginx.tar.gz
curl -o nginx.tar.gz https://hg.nginx.org/nginx/archive/release-1.25.3.tar.gz
tar xvzf nginx.tar.gz
git clone --depth=1 --recursive --shallow-submodules -b openssl-3.1.4-quic1 https://github.com/quictls/openssl
git clone --depth=1 --recursive --shallow-submodules https://github.com/google/ngx_brotli
git clone --depth=1 --recursive --shallow-submodules https://github.com/zlib-ng/zlib-ng
cd ngx_brotli/deps/brotli
mkdir out && cd out
CC=clang cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-O3 -march=native -mtune=native -flto=thin -funroll-loops -ffunction-sections -fdata-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
MAKEFLAGS=-j"$(nproc)" cmake --build . --config Release --target brotlienc
cd ../../../..
cd zlib-ng
CC=clang CXX=clang++ cmake -DWITH_NATIVE_INSTRUCTIONS=ON -DZLIB_COMPAT=ON -DCMAKE_LINKER=mold -DCMAKE_C_FLAGS="-O3 -march=native -mtune=native -flto=thin" -DCMAKE_LINKER=mold -DCMAKE_CXX_FLAGS="-O3 -march=native -mtune=native -flto=thin" .
MAKEFLAGS=-j"$(nproc)" cmake --build . --config Release
cd ..
mv nginx-release-* nginx
cd nginx
./auto/configure \
	--prefix=/var/lib/nginx \
	--sbin-path=/usr/sbin/nginx \
	--modules-path=/etc/nginx/modules \
	--conf-path=/etc/nginx/nginx.conf \
	--pid-path=/run/nginx/nginx.pid \
	--lock-path=/run/nginx/nginx.lock \
	--error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--http-client-body-temp-path=/var/lib/nginx/tmp/client_body \
	--http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
	--http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \
	--http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi \
	--http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
	--user=nginx \
	--group=nginx \
	--with-http_ssl_module \
	--with-http_v2_module \
	--with-http_v3_module \
	--with-file-aio \
	--with-http_sub_module \
	--with-threads \
	--with-http_gunzip_module \
	--with-http_addition_module \
	--with-stream_ssl_preread_module \
	--add-module=../ngx_brotli \
	--with-openssl=../openssl \
	--with-openssl-opt=enable-ktls \
	--with-cc-opt="-O3 -march=native -flto=thin -Wno-sign-compare -I ..$(pwd)/../zlib-ng/include" \
	--with-ld-opt="-fuse-ld=mold -flto=thin -L ..$(pwd)/../zlib-ng/lib" \
	--with-cc="clang"
make -j"$(nproc)"
make install
cd ..
mkdir -p /etc/nginx/http.d/ /etc/nginx/snippets/
install -dm700 -o nginx -g nginx /var/lib/nginx/tmp
install -Dm644 nginx.conf /etc/nginx/nginx.conf
install -Dm644 https-config.conf /etc/nginx/snippets/https-config.conf
if ! [ -e /etc/nginx/http.d/default.conf ]; then
	install -m644 default.conf /etc/nginx/http.d/default.conf
fi
install -Dm755 nginx.initd /etc/init.d/nginx
install -Dm644 nginx.confd /etc/conf.d/nginx
openssl rand 80 >/etc/nginx/ticket.key

# create default tls certs with dummy data
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
	-keyout /etc/ssl/private/ssl-cert-default.key \
	-out /etc/ssl/certs/ssl-cert-default.pem \
	-subj "/C=US/ST=New York/L=New York/O=Your Organization/OU=Your Organizational Unit/CN=example.com/emailAddress=your.email@example.com"
