# Use a lightweight Node image
FROM node:18-alpine

# Create and change to the app directory
WORKDIR /usr/src/app

# Install dependencies (only production deps in final image)
COPY package*.json ./
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Set the port your app listens on (adjust if your app uses another)
ENV PORT=3000
EXPOSE 3000

# Default command to run your app
CMD ["npm", "start"]

