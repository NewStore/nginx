FROM ubuntu:16.04

ENV NGINX_VERSION=1.15.0 \
    NGINX_LUA_MODULE_VERSION=0.10.13 \
    NGINX_DEVELKIT_MODULE_VERSION=0.3.1rc1 \
    CONSUL_TEMPLATE_VERSION=0.20.0 \
    NGINX_OPENTRACING_VERSION=v0.8.0 \
    JAEGER_CPP_VERSION=v0.4.2 \
    LIGHTSTEP_CPP_VERSION=v0.9.0

RUN apt-get update && \
    apt-get install -y \
    wget \
    build-essential \
    libpcre3-dev \
    libssl-dev \
    libluajit-5.1-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev && \
    cd /tmp && \
    wget https://github.com/openresty/lua-nginx-module/archive/v${NGINX_LUA_MODULE_VERSION}.tar.gz && tar zxvf v${NGINX_LUA_MODULE_VERSION}.tar.gz && \
    wget https://github.com/simplresty/ngx_devel_kit/archive/v${NGINX_DEVELKIT_MODULE_VERSION}.tar.gz && tar zxvf v${NGINX_DEVELKIT_MODULE_VERSION}.tar.gz && \
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar zxvf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    LUAJIT_LIB=/usr/lib \
    LUAJIT_INC=/usr/include/luajit-2.0 \
    ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=www-data \
    --group=www-data \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --add-module=/tmp/lua-nginx-module-${NGINX_LUA_MODULE_VERSION} \
    --add-module=/tmp/ngx_devel_kit-${NGINX_DEVELKIT_MODULE_VERSION} \
    --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
    --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' && \
    make && \
    make install && \
    # create temp folders
    mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp && \
    # Adding open tracing modules
    mkdir /usr/lib/nginx && \
    mkdir /usr/lib/nginx/modules && \
    cd /usr/lib/nginx/modules && \
    wget -O - https://github.com/opentracing-contrib/nginx-opentracing/releases/download/${NGINX_OPENTRACING_VERSION}/linux-amd64-nginx-${NGINX_VERSION}-ngx_http_module.so.tgz | tar zxf - && \
    wget -O - https://github.com/lightstep/lightstep-tracer-cpp/releases/download/${LIGHTSTEP_CPP_VERSION}/linux-amd64-liblightstep_tracer_plugin.so.gz | gunzip -c > /usr/lib/nginx/modules/liblightstep_tracer_plugin.so && \
    wget -O /usr/lib/nginx/modules/libjaegertracing_plugin.so https://github.com/jaegertracing/jaeger-client-cpp/releases/download/${JAEGER_CPP_VERSION}/libjaegertracing_plugin.linux_amd64.so && \
    # Clean up
    rm -rf \
    /tmp/v${NGINX_LUA_MODULE_VERSION}.tar.gz \
    /tmp/v${NGINX_DEVELKIT_MODULE_VERSION}.tar.gz \
    /tmp/nginx-${NGINX_VERSION}.tar.gz \
    /tmp/lua-nginx-module-${NGINX_LUA_MODULE_VERSION} \
    /tmp/ngx_devel_kit-${NGINX_DEVELKIT_MODULE_VERSION} \
    /tmp/nginx-${NGINX_VERSION} && \
    apt-get -y purge \
    wget \
    build-essential && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Available modules:" && \
    ls /usr/lib/nginx/modules
