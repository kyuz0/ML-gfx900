ARG BASE_IMAGE="docker.io/mixa3607/rocm-gfx900:7.2.1-complete"
FROM ${BASE_IMAGE}

# Add required Fedora Toolbox compatibility labels
LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox command" \
      summary="Ubuntu ROCm toolbox"

# Install toolbox dependencies and handle the machine-id so DBUS propagates through the host
RUN apt-get update && apt-get install -y \
    sudo \
    libcap2-bin \
    libnss-myhostname \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/machine-id && touch /etc/machine-id
