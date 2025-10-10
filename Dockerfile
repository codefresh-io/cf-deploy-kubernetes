FROM alpine:3.22.1 AS builder
RUN apk update \
    && apk add curl
RUN export ARCH=$([[ "$(uname -m)" == "aarch64" ]] && echo "arm64" || echo "amd64") \
    && mkdir -p /tmp/kubectl-versions && cd /tmp/kubectl-versions \
    && curl -o kubectl1.34 -L https://storage.googleapis.com/kubernetes-release/release/v1.34.1/bin/linux/${ARCH}/kubectl \
    && curl -o kubectl1.33 -L https://storage.googleapis.com/kubernetes-release/release/v1.33.5/bin/linux/${ARCH}/kubectl \
    && curl -o kubectl1.32 -L https://storage.googleapis.com/kubernetes-release/release/v1.32.9/bin/linux/${ARCH}/kubectl

FROM debian:bookworm-20250908-slim AS prod
RUN apt-get update -y
# install busybox by building source until it's unavailable by apt-get for v1.36.1 ad no need to link [[
RUN apt-get install --no-install-recommends wget build-essential -y && \
    wget --no-check-certificate https://busybox.net/downloads/busybox-1.36.1.tar.bz2 && \
    tar -xvjf busybox-1.36.1.tar.bz2 && \
    cd busybox-1.36.1 && \
    make defconfig && \
    make && \
    make CONFIG_PREFIX="/" install
RUN adduser --gecos "" --disabled-password --home /home/cfu --shell /bin/bash cfu
#copy all versions of kubectl to switch between them later.
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/* /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.34 /usr/local/bin/kubectl

WORKDIR /
ADD --chown=cfu --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
ADD --chown=cfu --chmod=775 template.sh /template.sh
USER cfu
CMD ["bash"]
