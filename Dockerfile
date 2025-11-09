FROM debian:trixie-20251103-slim AS prod
ARG TARGETPLATFORM
RUN /sbin/useradd --home /home/cfu --shell /bin/bash cfu
COPY --chown=cfu --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
COPY --chown=cfu --chmod=775 template.sh /template.sh
COPY --from=busybox:1.37.0-glibc /bin/busybox /usr/bin/busybox
RUN busybox --install
# ⚠️ We support 3 most recent minor versions: https://kubernetes.io/releases/
# Please update `./cf-deploy-kubernetes.sh` accordingly.
ADD --chown=cfu --chmod=775 https://dl.k8s.io/release/v1.34.1/bin/${TARGETPLATFORM}/kubectl /usr/local/bin/kubectl1.34
ADD --chown=cfu --chmod=775 https://dl.k8s.io/release/v1.33.5/bin/${TARGETPLATFORM}/kubectl /usr/local/bin/kubectl1.33
ADD --chown=cfu --chmod=775 https://dl.k8s.io/release/v1.32.9/bin/${TARGETPLATFORM}/kubectl /usr/local/bin/kubectl1.32
# ⚠️ Defaults to the latest version. Please update with new versions as needed.
RUN ln -s /usr/local/bin/kubectl1.34 /usr/local/bin/kubectl

WORKDIR /
USER cfu
CMD ["bash"]
