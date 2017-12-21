FROM alpine:3.6 AS builder

RUN apk update && apk add curl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl


FROM alpine:3.6

RUN apk add --update bash

COPY --from=builder ./kubectl /usr/local/bin/kubectl

RUN chmod +x /usr/local/bin/kubectl

WORKDIR /

ADD cf-deploy-kubernetes.sh /cf-deploy-kubernetes
ADD template.sh /template.sh

RUN \
    chmod +x /cf-deploy-kubernetes && \
    chmod +x /template.sh

CMD ["bash"]
