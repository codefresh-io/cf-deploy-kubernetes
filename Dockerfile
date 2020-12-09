FROM alpine:3.6 AS builder

RUN apk update && apk add curl

RUN export ARCH=$([[ "$(uname -m)" == "aarch64" ]] && echo "arm64" || echo "${ARCH}") && \ 
    curl -o kubectl1.16 -L https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/${ARCH}/kubectl && \ 
    curl -o kubectl1.15 -L https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/${ARCH}/kubectl && \ 
    curl -o kubectl1.14 -L https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/${ARCH}/kubectl && \ 
    curl -o kubectl1.13 -L https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/${ARCH}/kubectl && \ 
    curl -o kubectl1.12 -L https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/${ARCH}/kubectl && \ 
    curl -o kubectl1.11 -L https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/${ARCH}/kubectl && \ 
    curl -o kubectl1.10 -L https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/${ARCH}/kubectl && \ 
    curl -o kubectl1.6 -L https://storage.googleapis.com/kubernetes-release/release/v1.6.0/bin/linux/${ARCH}/kubectl

FROM alpine:3.10

RUN apk add --update bash

#copy all versions of kubectl to switch between them later.
COPY --from=builder kubectl1.16 /usr/local/bin/
COPY --from=builder kubectl1.15 /usr/local/bin/
COPY --from=builder kubectl1.14 /usr/local/bin/
COPY --from=builder kubectl1.13 /usr/local/bin/
COPY --from=builder kubectl1.12 /usr/local/bin/
COPY --from=builder kubectl1.11 /usr/local/bin/
COPY --from=builder kubectl1.10 /usr/local/bin/kubectl
COPY --from=builder kubectl1.6 /usr/local/bin/

RUN chmod +x /usr/local/bin/kubectl /usr/local/bin/kubectl1.6 /usr/local/bin/kubectl1.11 /usr/local/bin/kubectl1.12 /usr/local/bin/kubectl1.13 /usr/local/bin/kubectl1.14 /usr/local/bin/kubectl1.15 /usr/local/bin/kubectl1.16

WORKDIR /

ADD cf-deploy-kubernetes.sh /cf-deploy-kubernetes
ADD template.sh /template.sh

RUN \
    chmod +x /cf-deploy-kubernetes && \
    chmod +x /template.sh

CMD ["bash"]
