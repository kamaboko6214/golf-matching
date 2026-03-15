FROM node:20-slim

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install
RUN npx tailwindcss init -p

COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev", "--", "--host"]