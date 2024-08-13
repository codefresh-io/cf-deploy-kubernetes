FROM alpine:3.20 AS builder

RUN apk update && apk add curl

RUN export ARCH=$([[ "$(uname -m)" == "aarch64" ]] && echo "arm64" || echo "amd64") && \
    mkdir -p /tmp/kubectl-versions && cd /tmp/kubectl-versions && \
    curl -o kubectl1.30 -L https://storage.googleapis.com/kubernetes-release/release/v1.30.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.29 -L https://storage.googleapis.com/kubernetes-release/release/v1.29.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.28 -L https://storage.googleapis.com/kubernetes-release/release/v1.28.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.27 -L https://storage.googleapis.com/kubernetes-release/release/v1.27.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.26 -L https://storage.googleapis.com/kubernetes-release/release/v1.26.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.25 -L https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.24 -L https://storage.googleapis.com/kubernetes-release/release/v1.24.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.23 -L https://storage.googleapis.com/kubernetes-release/release/v1.23.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.22 -L https://storage.googleapis.com/kubernetes-release/release/v1.22.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.21 -L https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.20 -L https://storage.googleapis.com/kubernetes-release/release/v1.20.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.19 -L https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.18 -L https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.17 -L https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.16 -L https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.15 -L https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.14 -L https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.6 -L https://storage.googleapis.com/kubernetes-release/release/v1.6.0/bin/linux/${ARCH}/kubectl


FROM debian:bookworm-20240812-slim

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
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.10 /usr/local/bin/kubectl

WORKDIR /
ADD --chown=cfu --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
ADD --chown=cfu --chmod=775 template.sh /template.sh
USER cfu
CMD ["bash"]
