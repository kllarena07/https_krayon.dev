FROM tsl0922/ttyd:latest

# Install git, rust, and create non-root user
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git curl build-essential clang cmake tzdata figlet && \
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
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME

# Set working directory for build
WORKDIR /build

# Clone the repository
RUN git clone https://github.com/kllarena07/ssh_krayon.dev . && \
    git checkout 1a1b1838d3ea92e803aa78f6bab4813863c1a5dc

# Build the Rust project
RUN cargo build --release

# Create app directory and copy binary
RUN mkdir -p /app && \
    cp target/release/portfolio-v2 /app/ && \
    mkdir -p /app/hikari-dance && \
    cp hikari-dance/frames_cache.bin /app/hikari-dance/

# Copy welcome script and set up read-only environment
COPY welcome.sh /app/
RUN chown -R root:root /app && \
    chmod -R 555 /app && \
    chmod 755 /app/portfolio-v2 && \
    chmod 755 /app/welcome.sh

# Switch to appuser
USER appuser

# Expose ttyd default port
EXPOSE 7681

# Start ttyd with binary
WORKDIR /app
CMD ["ttyd", "--writable", "-p", "7681", "sh", "-c", "./portfolio-v2; ./welcome.sh; exec bash"]