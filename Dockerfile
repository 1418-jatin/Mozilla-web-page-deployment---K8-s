# Base image: Nginx lightweight Alpine version
FROM nginx:alpine

# Set working directory inside container
WORKDIR /usr/share/nginx/html

# Remove default nginx static files
RUN rm -rf ./*

# Copy repo files (HTML, CSS, images) into container
COPY . .

# Expose port 80 for web traffic
EXPOSE 99

# Nginx will auto-start via base image entrypoint
