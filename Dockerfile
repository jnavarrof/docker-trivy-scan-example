# This image might have critical vulnerabilities
FROM php:8.0.1-fpm-alpine

# Add a vulnerable package
RUN apk add --no-cache \
  zabbix-agent2~=5.2.7 \
  && rm -f /var/cache/apk/*
