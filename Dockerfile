# Bookmark Front-end

FROM nginx:1.13.0
COPY build/docker/default.conf /etc/nginx/conf.d/default.conf
COPY dist/index.html /usr/share/nginx/html/bookmark/index.html
COPY dist/bookmark/static /usr/share/nginx/html/bookmark/static
