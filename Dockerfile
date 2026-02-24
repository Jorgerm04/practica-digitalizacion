# --- Stage 1: Base & Dependencies ---
FROM node:22-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# --- Target: test ---
# Si los tests fallan, el proceso de construcción se detiene [cite: 174]
FROM base AS test
RUN npm run test

# --- Target: dev ---
# Servidor de desarrollo en puerto 3000 con host 0.0.0.0 [cite: 71, 187]
FROM base AS dev
EXPOSE 3000
CMD ["npm", "run", "dev"]

# --- Stage: build ---
# Genera los archivos estáticos en /app/dist [cite: 192]
FROM base AS build
RUN npm run build

# --- Target: production ---
# Usa Nginx para servir los archivos de la etapa anterior [cite: 198, 209]
FROM nginx:stable-alpine AS production
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]