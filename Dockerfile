# Шаг 1: Сборка приложения (builder stage)
FROM node:18-alpine AS builder

# Устанавливаем зависимости (включая git для некоторых npm-пакетов)
RUN apk add --no-cache git

# Создаем рабочую директорию
WORKDIR /app

# Копируем package.json и package-lock.json (или yarn.lock)
COPY package*.json ./

# Устанавливаем зависимости (включая devDependencies для сборки)
RUN npm ci

# Копируем все файлы проекта
COPY .. .

# Собираем приложение (если используется TypeScript)
RUN npm run build

# Удаляем devDependencies после сборки
RUN npm prune --production

# Шаг 2: Финальный образ (production stage)
FROM node:18-alpine

WORKDIR /app

# Копируем только нужные файлы из builder-стадии
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Указываем переменные окружения (опционально)
ENV NODE_ENV=production
ENV PORT=4000

# Открываем порт (по умолчанию NestJS использует 3000)
EXPOSE 4000

# Запускаем приложение
CMD ["node", "dist/main.js"]
