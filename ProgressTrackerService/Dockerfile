FROM node:12.13.0-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

EXPOSE 7096

CMD ["npm", "run", "start-server"]