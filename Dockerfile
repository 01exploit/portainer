# Optimized Multi-Stage Build Dockerfile for Portainer CE

# Stage 1: Builder
FROM alpine:latest AS builder

# Install required dependencies
RUN apk add --no-cache \
    curl \
    tar \
    jq

# Fetch the latest version of Portainer CE from GitHub and extract the binary
WORKDIR /build
RUN LATEST_VERSION=$(curl -sSL https://api.github.com/repos/portainer/portainer/releases/latest | jq -r '.tag_name') && \
    curl -fSL https://github.com/portainer/portainer/releases/download/${LATEST_VERSION}/portainer-${LATEST_VERSION#v}-linux-amd64.tar.gz \
    -o portainer.tar.gz && \
    tar -xzf portainer.tar.gz

# Stage 2: Minimal Image
FROM alpine:latest

# Copy the Portainer CE binary from the builder stage
COPY --from=builder /build/portainer /portainer

# Set up a non-root user for better security
RUN addgroup -S portainer && adduser -S -G portainer portainer && \
    mkdir -p /data && \
    chown -R portainer:portainer /data

# Expose the necessary Portainer ports
EXPOSE 8000 9000

# Switch to the non-root user
USER portainer

# Set the working directory and command to start Portainer
WORKDIR /data
ENTRYPOINT ["/portainer"]
