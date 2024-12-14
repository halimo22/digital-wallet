# Stage 1: Build the application
FROM node:18 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install production dependencies only
RUN npm install --only=production

# Copy the rest of the application files
COPY . .

# Build the application (if needed, adjust according to your project)
# Uncomment if you have a build step like for React or other frontend frameworks

# Stage 2: Create a lightweight runtime image
FROM node:18-slim

# Set the working directory inside the container
WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=build /app .

# Expose the port the application will run on
EXPOSE 3000

# Define environment variables (optional, or use a mounted .env file)
ENV NODE_ENV=production
ENV PORT=3000

# Start the application
CMD ["node", "index.js"]
