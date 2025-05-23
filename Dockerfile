FROM alpine:3.21 AS builder

RUN apk add --no-cache curl

ARG TARGETARCH
WORKDIR /tmp/kubectl-versions
RUN curl -o kubectl1.6 -L https://storage.googleapis.com/kubernetes-release/release/v1.6.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.10 -L https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.11 -L https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.12 -L https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.13 -L https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.14 -L https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.15 -L https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.16 -L https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.17 -L https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.18 -L https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.19 -L https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.20 -L https://storage.googleapis.com/kubernetes-release/release/v1.20.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.21 -L https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.22 -L https://storage.googleapis.com/kubernetes-release/release/v1.22.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.23 -L https://storage.googleapis.com/kubernetes-release/release/v1.23.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.24 -L https://storage.googleapis.com/kubernetes-release/release/v1.24.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.25 -L https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.26 -L https://storage.googleapis.com/kubernetes-release/release/v1.26.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.27 -L https://storage.googleapis.com/kubernetes-release/release/v1.27.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.28 -L https://storage.googleapis.com/kubernetes-release/release/v1.28.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.29 -L https://storage.googleapis.com/kubernetes-release/release/v1.29.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.30 -L https://storage.googleapis.com/kubernetes-release/release/v1.30.0/bin/linux/${TARGETARCH}/kubectl
RUN curl -o kubectl1.31 -L https://storage.googleapis.com/kubernetes-release/release/v1.31.0/bin/linux/${TARGETARCH}/kubectl

FROM debian:12.11-slim
WORKDIR /
RUN adduser --gecos "" --disabled-password --home /home/cfu --shell /bin/bash cfu
USER cfu

# copy all versions of kubectl to switch between them later.
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.6 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.10 /usr/local/bin/kubectl
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.11 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.12 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.13 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.14 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.15 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.16 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.17 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.18 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.19 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.20 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.21 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.22 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.23 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.24 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.25 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.26 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.27 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.28 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.29 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.30 /usr/local/bin/
COPY --chown=cfu --chmod=775 --from=builder /tmp/kubectl-versions/kubectl1.31 /usr/local/bin/

COPY --chown=cfu --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
COPY --chown=cfu --chmod=775 template.sh /template.sh

CMD ["bash"]
