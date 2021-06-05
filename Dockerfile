# build stage
FROM node:10 as builder

WORKDIR /app

COPY package.json ./

RUN yarn

COPY . .

RUN yarn build --mode docker

# final stage
FROM nginx:stable-alpine

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
