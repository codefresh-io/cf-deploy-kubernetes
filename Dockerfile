FROM alpine:3.6 AS builder

RUN apk update && apk add curl

RUN export ARCH=$([[ "$(uname -m)" == "aarch64" ]] && echo "arm64" || echo "amd64") && \
    mkdir -p /tmp/kubectl-versions && cd /tmp/kubectl-versions && \
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
    curl -o kubectl1.13 -L https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.12 -L https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.11 -L https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.10 -L https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/${ARCH}/kubectl && \
    curl -o kubectl1.6 -L https://storage.googleapis.com/kubernetes-release/release/v1.6.0/bin/linux/${ARCH}/kubectl


FROM debian:bullseye-slim

RUN apt-get update -y && \
    apt-get install -y \
    busybox \
    ncurses-base=6.2+20201114-2+deb11u2 \
    ncurses-bin=6.2+20201114-2+deb11u2 \
    libc6=2.31-13+deb11u7 && \
    ln -s /bin/busybox /usr/bin/[[

RUN adduser --gecos "" --disabled-password --home /home/cfu --shell /bin/bash cfu

#RUN apt update && apt upgrade && apt install bash # THIS IS NOT REQUIRED. BASH IS ALREADY INCLUDED IN BULLSEYE

#copy all versions of kubectl to switch between them later.
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/* /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.10 /usr/local/bin/kubectl

WORKDIR /
ADD --chown=cfu --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
ADD --chown=cfu --chmod=775 template.sh /template.sh
USER cfu
CMD ["bash"]
