rm -rf quiche nginx ngx_brotli nginx-1.16.1.tar.gz
addgroup -S nginx
adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx
curl -O https://nginx.org/download/nginx-1.16.1.tar.gz
tar xvzf nginx-1.16.1.tar.gz
git clone --depth=1 --recursive --shallow-submodules https://github.com/cloudflare/quiche
git clone --depth=1 --recursive --shallow-submodules https://github.com/google/ngx_brotli
mv nginx-1.16.1 nginx
cd nginx
patch -p01 <../quiche/extras/nginx/nginx-1.16.patch
./configure \
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
	--with-openssl=../quiche/deps/boringssl \
	--with-quiche=../quiche \
	--with-cc-opt="-O3 -march=native -flto"
make -j$(nproc)
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
