FROM docker.io/node:17 as build

LABEL maintainer="Oscar Koeroo <okoeroo@gmail.com>"

ARG VERSION

RUN chown -R node:node /srv

USER node
WORKDIR /srv

RUN git clone -b "$VERSION" --depth=1 https://github.com/gchq/CyberChef.git .
RUN npm install

ENV NODE_OPTIONS="--max-old-space-size=2048"
RUN npx grunt prod


FROM docker.io/nginxinc/nginx-unprivileged:alpine as app

LABEL maintainer="Martijn Pepping <martijn.pepping@automiq.nl>" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-ref="github.com/okoeroo/docker-cyberchef" \
    org.label-schema.name="okoeroo/cyberchef" \
    org.label-schema.description="CyberChef" \
    org.label-schema.url="https://github.com/okoeroo/docker-cyberchef" \
    org.label-schema.vcs-url="https://github.com/okoeroo/docker-cyberchef" \
    org.label-schema.vendor="Martijn Pepping" \
    org.label-schema.docker.cmd="docker run -it okoeroo/cyberchef:latest"

# old http-server was running on port 8000, avoid breaking change
RUN sed -i 's|listen       8080;|listen       8000;|g' /etc/nginx/conf.d/default.conf

COPY --from=build /srv/build/prod /usr/share/nginx/html

EXPOSE 8000
