# DHI source: https://hub.docker.com/repository/docker/octopusdeploy/dhi-debian-base/customizations/8303889275873263714
FROM octopusdeploy/dhi-debian-base:trixie_cf-classic-deploy-kubernetes-debian13@sha256:ffb200209298d12083c0b10a779cc2536d9ad975b18d422d79e533fd9bd59376 AS prod
COPY --chown=nonroot --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
COPY --chown=nonroot --chmod=775 template.sh /template.sh
# ⚠️ We support 3 most recent minor versions: https://kubernetes.io/releases/
# Please update `./cf-deploy-kubernetes.sh` accordingly.
COPY --chown=nonroot --chmod=775 --from=octopusdeploy/dhi-kubectl:1.34-debian13 /usr/local/bin/kubectl /usr/local/bin/kubectl1.34
COPY --chown=nonroot --chmod=775 --from=octopusdeploy/dhi-kubectl:1.33-debian13 /usr/local/bin/kubectl /usr/local/bin/kubectl1.33
COPY --chown=nonroot --chmod=775 --from=octopusdeploy/dhi-kubectl:1.32-debian13 /usr/local/bin/kubectl /usr/local/bin/kubectl1.32
# ⚠️ Defaults to the latest version. Please update with new versions as needed.
RUN ln -s /usr/local/bin/kubectl1.34 /usr/local/bin/kubectl

WORKDIR /
USER nonroot
CMD ["bash"]
