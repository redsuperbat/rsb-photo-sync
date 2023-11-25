FROM node:slim as deps
COPY . .
RUN npm ci


FROM node:slim as builder
COPY . .
COPY --from=deps node_modules node_modules
RUN npm run build


FROM node:slim as runner
WORKDIR /app
COPY --from=deps node_modules node_modules
COPY --from=builder dist/main.js main.js
COPY package.json package.json
CMD ["node", "main.js"]
