FROM openresty/openresty:1.21.4.1-0-alpine
COPY ./index.html /usr/share/nginx/html/index.html
COPY ./my-custom.conf /etc/nginx/conf.d/default.conf
COPY ./upstream.conf /etc/nginx/upstream.conf
