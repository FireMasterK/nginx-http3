rm -rf quiche nginx nginx-1.16.1.tar.gz
addgroup -S nginx
adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx
curl -O https://nginx.org/download/nginx-1.16.1.tar.gz
tar xvzf nginx-1.16.1.tar.gz
git clone --recursive https://github.com/cloudflare/quiche
mv nginx-1.16.1 nginx
cd nginx
patch -p01 <../quiche/extras/nginx/nginx-1.16.patch
./configure \
	--prefix=/etc/nginx \
	--sbin-path=/usr/sbin/nginx \
	--modules-path=/etc/nginx/modules \
	--conf-path=/etc/nginx/nginx.conf \
	--pid-path=/run/nginx/nginx.pid \
	--lock-path=/run/nginx/nginx.lock \
	--user=nginx \
	--group=nginx \
	--with-http_ssl_module \
	--with-http_v2_module \
	--with-http_v3_module \
	--with-file-aio \
	--with-http_sub_module \
	--with-threads \
	--with-http_gunzip_module \
	--with-openssl=../quiche/deps/boringssl \
	--with-quiche=../quiche
make
make install
