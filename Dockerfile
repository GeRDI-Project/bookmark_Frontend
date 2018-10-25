FROM nginx:1.15.5-alpine
WORKDIR /home/app
COPY . /home/app
RUN mkdir /usr/share/nginx/html/bookmark
RUN mkdir /usr/share/nginx/html/bookmark/static
RUN apk add nodejs npm git
RUN npm install
RUN npm run build
RUN cp build/docker/default.conf /etc/nginx/conf.d/default.conf
RUN cp dist/index.html /usr/share/nginx/html/bookmark/index.html
RUN cp -r dist/bookmark/static/* /usr/share/nginx/html/bookmark/static
CMD nginx -g "daemon off;"
