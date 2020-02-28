FROM alpine:3.8.5

ENV NGINX_RELEASE 1.14.2
ENV NGINX_URL https://github.com/nginx/nginx/archive/release-$NGINX_RELEASE.tar.gz
ENV NGINX_TMP_DIR /tmp/nginx

RUN set -x \
    # Build dependencies include /etc/nginx/conf.d/*.conf;
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        perl-dev \
        libedit-dev \
        alpine-sdk \
        build-base \
    && mkdir -p $NGINX_TMP_DIR \
    && cd $NGINX_TMP_DIR \
    && curl -sSL $NGINX_URL -O \
    && tar xzf release-$NGINX_RELEASE.tar.gz --strip 1 \
    && git clone https://github.com/anomalizer/ngx_aws_auth.git -b AuthV2\
    && ./auto/configure \
        --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic --with-threads --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-stream_realip_module --with-stream_geoip_module=dynamic --with-http_slice_module --with-mail --with-mail_ssl_module --with-compat --with-file-aio --with-http_v2_module \
        --add-module=ngx_aws_auth \
    && make install \
    # Additional config
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /var/cache/nginx/client_temp \
        /var/cache/nginx/proxy_temp \
        /var/cache/nginx/fastcgi_temp \
        /var/cache/nginx/uwsgi_temp \
        /var/cache/nginx/scgi_temp \
    && chown -R nginx:nginx /var/cache/nginx/ \
    # Clean up
    && cd .. \
    && rm -rf $NGINX_TMP_DIR \
    && apk del --purge .build-deps \
    && apk add --no-cache \
        tzdata \
        pcre \
        libssl1.0 \
        libcrypto1.0 \
    && rm -rf /var/cache/apk/* /tmp/*

ADD files/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
