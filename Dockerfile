# Build stage
FROM tsl0922/ttyd:latest AS builder

# Install build dependencies and create user
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git curl build-essential clang cmake && \
    groupadd -g 1000 appgroup && \
    useradd -u 1000 -g appgroup -m -s /bin/bash appuser && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Rust
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    CC=clang \
    CXX=clang++
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME && \
    git clone https://github.com/kllarena07/ssh_krayon.dev /build && \
    cd /build && \
    git checkout 1a1b1838d3ea92e803aa78f6bab4813863c1a5dc && \
    cargo build --release

# Runtime stage
FROM tsl0922/ttyd:latest

# Install only runtime dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata figlet && \
    groupadd -g 1000 appgroup && \
    useradd -u 1000 -g appgroup -m -s /bin/bash appuser && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy only necessary files from builder
COPY --from=builder /build/target/release/portfolio-v2 /app/
COPY --from=builder /build/hikari-dance/frames_cache.bin /app/hikari-dance/
COPY welcome.sh /app/
COPY start.sh /app/
COPY favicon.ico /app/

# Set up read-only environment and permissions
RUN chown -R root:root /app && \
    chmod -R 555 /app && \
    chmod 755 /app/portfolio-v2 && \
    chmod 755 /app/welcome.sh && \
    chmod 755 /app/start.sh && \
    chmod 644 /app/favicon.ico

# Switch to appuser
USER appuser

# Expose ttyd default port
EXPOSE 7681

# Start ttyd with binary
WORKDIR /app
CMD ["./start.sh"]
