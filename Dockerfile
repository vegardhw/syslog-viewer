# Use the latest lightweight Alpine base image
FROM alpine:latest

# Install required packages including curl and lnav
RUN apk add --no-cache \
    curl \
    coreutils \
    gzip \
    bash

# Create the directory for the logs
RUN mkdir /logs

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make the script executable
RUN chmod +x /entrypoint.sh

# Expose the port for the web server
# EXPOSE 8081

# Use the custom entrypoint
ENTRYPOINT ["/entrypoint.sh"]
