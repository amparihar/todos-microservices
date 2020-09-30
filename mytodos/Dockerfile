FROM node:12.13.0-alpine as build 
WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM nginx 
EXPOSE 3000
COPY --from=build /app/build /usr/share/nginx/html
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

CMD ["/bin/sh",  "-c",  "envsubst < /usr/share/nginx/html/env-config.template.js > /usr/share/nginx/html/env-config.js && exec nginx -g 'daemon off;'"]

#docker run --env USER_API_BASE_URL="http://localhost:4096/api" --env GROUP_API_BASE_URL="http://localhost:5096/api" --env TASK_API_BASE_URL="http://localhost:6096/api"  -p 3000:3000 --rm -d --name mytodos-ecs mytodos-ecs:1.0