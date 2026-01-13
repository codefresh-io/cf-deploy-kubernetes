FROM debian:trixie-20251229-slim AS prod
ARG TARGETPLATFORM
RUN useradd --home /home/cfu --shell /bin/bash cfu
COPY --chown=cfu --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
COPY --chown=cfu --chmod=775 template.sh /template.sh
COPY --from=busybox:1.37.0-glibc /bin/busybox /usr/bin/busybox
RUN busybox --install
# ⚠️ We support 3 most recent minor versions: https://kubernetes.io/releases/
# Please update `./cf-deploy-kubernetes.sh` accordingly.
COPY --chown=cfu --chmod=775 --from=octopusdeploy/dhi-kubectl:1.34-debian13 /usr/local/bin/kubectl /usr/local/bin/kubectl1.34
COPY --chown=cfu --chmod=775 --from=octopusdeploy/dhi-kubectl:1.33-debian13 /usr/local/bin/kubectl /usr/local/bin/kubectl1.33
COPY --chown=cfu --chmod=775 --from=octopusdeploy/dhi-kubectl:1.32-debian13 /usr/local/bin/kubectl /usr/local/bin/kubectl1.32
# ⚠️ Defaults to the latest version. Please update with new versions as needed.
RUN ln -s /usr/local/bin/kubectl1.34 /usr/local/bin/kubectl

WORKDIR /
USER cfu
CMD ["bash"]
