set -e
rm -rf nginx ngx_brotli openssl nginx.tar.gz
curl -o nginx.tar.gz https://hg.nginx.org/nginx-quic/archive/quic.tar.gz
tar xvzf nginx.tar.gz
git clone --depth=1 --recursive --shallow-submodules -b openssl-3.0.8-quic1 https://github.com/quictls/openssl
git clone --depth=1 --recursive --shallow-submodules https://github.com/google/ngx_brotli
mv nginx-quic-* nginx
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
	--with-cc-opt="-O3 -march=native -flto -Wno-sign-compare" \
	--with-ld-opt="-fuse-ld=mold -flto" \
	--with-cc="clang"
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
