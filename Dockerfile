FROM alpine:3.20 AS builder

RUN apk update && apk add curl

RUN export ARCH=$([[ "$(uname -m)" == "aarch64" ]] && echo "arm64" || echo "amd64") && \
    mkdir -p /tmp/kubectl-versions && cd /tmp/kubectl-versions && \
    curl -o kubectl1.30 -L https://storage.googleapis.com/kubernetes-release/release/v1.30.0/bin/linux/${ARCH}/kubectl && \
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


FROM debian:bookworm-20240701-slim

RUN apt-get update -y && apt-get install busybox -y && ln -s /bin/busybox /usr/bin/[[

RUN adduser --gecos "" --disabled-password --home /home/cfu --shell /bin/bash cfu

#RUN apt update && apt upgrade && apt install bash # THIS IS NOT REQUIRED. BASH IS ALREADY INCLUDED IN BOOKWORM

#copy all versions of kubectl to switch between them later.
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/* /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.30 /usr/local/bin/kubectl

WORKDIR /
ADD --chown=cfu --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
ADD --chown=cfu --chmod=775 template.sh /template.sh
USER cfu
CMD ["bash"]
