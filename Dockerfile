FROM alpine:3.21 AS builder


RUN apk update && apk add curl

RUN export ARCH=$([[ "$(uname -m)" == "aarch64" ]] && echo "arm64" || echo "amd64") && \
    mkdir -p /tmp/kubectl-versions && cd /tmp/kubectl-versions && \
    curl -o kubectl1.32 -L https://storage.googleapis.com/kubernetes-release/release/v1.32.0/bin/linux/${ARCH}/kubectl


FROM debian:trixie-slim


RUN apt-get update -y && \
    apt-get upgrade && \
    apt-get install busybox -y && \
    ln -s /bin/busybox /usr/bin/[[


RUN adduser --gecos "" --disabled-password --home /home/cfu --shell /bin/bash cfu

#copy all versions of kubectl to switch between them later.
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/* /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.32 /usr/local/bin/kubectl

WORKDIR /
ADD --chown=cfu --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
ADD --chown=cfu --chmod=775 template.sh /template.sh
USER cfu
CMD ["bash"]
