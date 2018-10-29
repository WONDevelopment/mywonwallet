# nginx and go support docker, the nginx conf and root folder and log folder is volumed by docker-compose, the go src folder is volumed by docker-compose
FROM node:8.11

# -- use docker run
ARG APP_HOME=/product/won/production/wallet/htdocs

WORKDIR ${APP_HOME}

COPY ./MyWonWallet/ ${APP_HOME}

RUN echo "alias ll='ls -hl'" >> /etc/bash.bashrc
RUN apt-get update && apt-get install -y vim net-tools telnet curl nginx

COPY conf.d/ /etc/nginx/conf.d/
COPY key/ /etc/nginx/key/
COPY nginx.conf /etc/nginx/

RUN ln -sf  /usr/share/zoneinfo/PST8PDT /etc/localtime
RUN echo "PST8PDT" > /etc/timezone
RUN date

# -- install node and npm
RUN node --version && npm version
RUN pwd
RUN npm install
RUN npm run build
RUN ls -hl dist
