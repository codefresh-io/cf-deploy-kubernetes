FROM alpine

RUN apk add --no-cache python py-pip && \
    apk add --update bash

ENV GCLOUD_SDK_VERSION="141.0.0"

ENV \
  GCLOUD_SDK_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz" \
  GCLOUD_SDK_FILENAME="google-cloud-sdk-${GCLOUD_SDK_VERSION}.tar.gz"

WORKDIR /

# Install kubectl and gcloud command line utilities
ADD ${GCLOUD_SDK_URL} ${GCLOUD_SDK_FILENAME}

RUN tar xf "${GCLOUD_SDK_FILENAME}" && \
    sed -i -e 's/true/false/' /google-cloud-sdk/lib/googlecloudsdk/core/config.json; \
    /google-cloud-sdk/bin/gcloud components install -q kubectl; \
    pip install shyaml

ADD cf-deploy-kubernetes.sh /cf-deploy-kubernetes
ADD template.sh /template.sh

# Set the default path to include all the commands
RUN \
    ln -s /google-cloud-sdk/bin/kubectl /usr/local/bin/kubectl && \
    chmod +x /cf-deploy-kubernetes && \
    chmod +x /template.sh

CMD ["bash"]
