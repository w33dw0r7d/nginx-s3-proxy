# Nginx S3 proxy

## About

Nginx with S3 Auth v2 module

Docker image: [docker.io/w33dw0r7d/nginx-s3-proxy](https://hub.docker.com/repository/docker/w33dw0r7d/nginx-s3-proxy)

- Alpine 3.8.5
- Nginx v1.14.2 with original configure options
- S3 Auth v2 module [anomalizer/ngx_aws_auth](https://github.com/anomalizer/ngx_aws_auth.git)

## Usage example

### sample.conf

```config
server {
    listen 80;
    server_name test.test;
    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log;
    location / {
        # uncomment for http basic auth
        # auth_basic "Restrict";
        # auth_basic_user_file /tmp/htpasswd;
        aws_access_key AWS_ACCESS_KEY;
        aws_secret_key AWS_SECRET_KEY;
        s3_bucket BUCKET_NAME;

        proxy_set_header Authorization $s3_auth_token;
        proxy_set_header x-amz-date $aws_date;
        proxy_pass https://ENDPOINT;
    }
}
```

### run docker cli

```bash
docker run -p 8080:80 -v sample.conf:/etc/nginx/conf.d/sample.conf docker.io/w33dw0r7d/nginx-s3-proxy
```

### run docker-compose

```yaml
---
version: '3.0'

services:
  nginx-s3-proxy:
    image: docker.io/w33dw0r7d/nginx-s3-proxy:v1
    build:
      context: nginx-s3-proxy
      dockerfile: Dockerfile
    hostname: nginx-s3-proxy
    container_name: nginx-s3-proxy
    ports:
      - "8080:80"
    volumes:
      - ./sample.conf:/etc/nginx/conf.d/vhost_config.conf:ro
    #   - ./htpasswd:/tmp/htpasswd:ro # uncomment for http basic auth
    restart: unless-stopped
```

## Credits

Thanks for [@anomalizer](https://github.com/anomalizer) for module [anomalizer/ngx_aws_auth](https://github.com/anomalizer/ngx_aws_auth.git)

Inspired by [@coopernurse](https://github.com/coopernurse) [coopernurse/nginx-s3-proxy](https://github.com/coopernurse/nginx-s3-proxy)
