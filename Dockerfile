FROM node:18 AS build

WORKDIR /app


COPY package*.json ./

RUN npm install --only=production


COPY . .

# Create a lightweight runtime image
FROM node:18-slim

WORKDIR /app

COPY --from=build /app .
EXPOSE 3000

# Define environment variables (optional, or use a mounted .env file)
ENV NODE_ENV=production
ENV PORT=3000

CMD ["node", "index.js"]
