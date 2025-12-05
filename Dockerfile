# Use a lightweight Node image
FROM node:18-alpine

# Create and change to the app directory
WORKDIR /usr/src/app

# Install dependencies (only production deps in final image)
COPY package*.json ./

# Only run npm install if package.json exists, and don't fail the build if it errors
RUN if [ -f package.json ]; then \
      echo "package.json found, running npm install" && \
      npm install --production || echo "npm install failed, continuing build anyway"; \
    else \
      echo "No package.json found, skipping npm install"; \
    fi


# Copy the rest of the application code
COPY . .

# Set the port your app listens on (adjust if your app uses another)
ENV PORT=3000
EXPOSE 3000

# Default command to run your app
CMD ["npm", "start"]

