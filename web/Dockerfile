FROM node:22-slim

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

EXPOSE 3000

# Dev-mode server with the source bind-mounted (infra/docker-compose.yml),
# same "runserver in the container" pattern as backend/Dockerfile — no
# production multi-stage build yet, that's a later-phase concern.
CMD ["npm", "run", "dev"]
