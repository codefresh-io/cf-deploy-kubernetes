# ⚠️ If updating supported `kubectl` versions,
# please also update `./cf-deploy-kubernetes.sh` accordingly.

ARG DEBIAN_VERSION=bookworm-20251103-slim


FROM debian:${DEBIAN_VERSION} AS builder
ARG TARGETPLATFORM
RUN apt-get update && apt-get install -y build-essential

ARG BUSYBOX_VERSION=1.36.1
ADD https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2 /busybox-${BUSYBOX_VERSION}.tar.bz2
ADD https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2.sha256 /busybox-${BUSYBOX_VERSION}.tar.bz2.sha256
RUN echo "$(cat busybox-${BUSYBOX_VERSION}.tar.bz2.sha256)  busybox-${BUSYBOX_VERSION}.tar.bz2" | sha256sum --check
RUN tar -xvjf busybox-${BUSYBOX_VERSION}.tar.bz2 \
    && cd busybox-${BUSYBOX_VERSION} \
    && make defconfig \
    && make \
    && make CONFIG_PREFIX="/" install

ADD https://dl.k8s.io/release/v1.34.1/bin/${TARGETPLATFORM}/kubectl /kubectl/kubectl1.34
ADD https://dl.k8s.io/release/v1.34.1/bin/${TARGETPLATFORM}/kubectl.sha256 /kubectl1.34.sha256
RUN echo "$(cat kubectl1.34.sha256)  /kubectl/kubectl1.34" | sha256sum --check

ADD https://dl.k8s.io/release/v1.33.5/bin/${TARGETPLATFORM}/kubectl /kubectl/kubectl1.33
ADD https://dl.k8s.io/release/v1.33.5/bin/${TARGETPLATFORM}/kubectl.sha256 /kubectl1.33.sha256
RUN echo "$(cat kubectl1.33.sha256)  /kubectl/kubectl1.33" | sha256sum --check

ADD https://dl.k8s.io/release/v1.32.9/bin/${TARGETPLATFORM}/kubectl /kubectl/kubectl1.32
ADD https://dl.k8s.io/release/v1.32.9/bin/${TARGETPLATFORM}/kubectl.sha256 /kubectl1.32.sha256
RUN echo "$(cat kubectl1.32.sha256)  /kubectl/kubectl1.32" | sha256sum --check



FROM debian:${DEBIAN_VERSION} AS prod
RUN adduser --gecos "" --disabled-password --home /home/cfu --shell /bin/bash cfu

COPY --chown=cfu --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
COPY --chown=cfu --chmod=775 template.sh /template.sh

COPY --chown=cfu --chmod=775 --from=builder /usr/bin/busybox /usr/bin/busybox
RUN busybox --install

COPY --chown=cfu --chmod=775 --from=builder /kubectl/* /usr/local/bin/
# ⚠️ Defaults to the latest kubectl version. Please update with new versions as needed.
RUN ln -s /usr/local/bin/kubectl1.34 /usr/local/bin/kubectl

WORKDIR /
USER cfu
CMD ["bash"]
