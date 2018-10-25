FROM nginx:1.15.5-alpine
WORKDIR /home/app
RUN apk add nodejs npm git
COPY build/docker/default.conf /etc/nginx/conf.d/default.conf
RUN mkdir /usr/share/nginx/html/bookmark
RUN mkdir /usr/share/nginx/html/bookmark/static
COPY . /home/app
RUN npm install
RUN npm run build
RUN cp dist/index.html /usr/share/nginx/html/bookmark/index.html
RUN cp -r dist/bookmark/static/* /usr/share/nginx/html/bookmark/static
CMD nginx -g "daemon off;"
