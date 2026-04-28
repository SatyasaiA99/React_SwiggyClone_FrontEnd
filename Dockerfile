# Stage 1: Build React (Vite)
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

# Stage 2: Serve using Nginx
FROM nginx:alpine

# ✅ FIX: Vite output is "dist", NOT "build"
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
