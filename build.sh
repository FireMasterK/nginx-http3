set -e
rm -rf quiche zestginx
git clone --depth=1 --recursive --shallow-submodules https://github.com/FireMasterK/zestginx
cd zestginx
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
	--without-http_geoip_module \
	--without-stream_geoip_module \
	--with-cc-opt="-O3 -march=native -flto -Wno-vla-parameter"
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
