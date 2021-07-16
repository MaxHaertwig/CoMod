FROM node:lts AS builder

WORKDIR /usr/src/app
COPY package*.json .
RUN npm install
COPY .eslintrc.yml tsconfig.json ./
COPY src src
RUN npm run lint
RUN npm run build


FROM node:lts

WORKDIR /usr/src/app
COPY package*.json .
RUN npm install --only=prod
COPY --from=builder /usr/src/app/dist dist
CMD ["node", "dist/index.js"]
EXPOSE 3000
