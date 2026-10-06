# DHI source: https://hub.docker.com/repository/docker/octopusdeploy/dhi-debian-base/customizations/8303889275873263714
FROM octopusdeploy/dhi-debian-base:trixie_cf-classic-deploy-kubernetes-debian13@sha256:1b7a14ef1f59efa395bc64081f24a26ccb20c886c22a73ddf1a8f41d1adebfb1 AS prod
RUN busybox --install
COPY --chown=nonroot --chmod=775 cf-deploy-kubernetes.sh /cf-deploy-kubernetes
COPY --chown=nonroot --chmod=775 template.sh /template.sh
# ⚠️ We support 3 most recent minor versions: https://kubernetes.io/releases/
# Please update `./cf-deploy-kubernetes.sh` accordingly.
COPY --chown=nonroot --chmod=775 --from=octopusdeploy/dhi-kubectl:1.35-debian13 /usr/local/bin/kubectl /usr/local/bin/kubectl1.35
COPY --chown=nonroot --chmod=775 --from=octopusdeploy/dhi-kubectl:1.36-debian13 /usr/local/bin/kubectl /usr/local/bin/kubectl1.36
COPY --chown=nonroot --chmod=775 --from=octopusdeploy/dhi-kubectl:1.37-debian13 /usr/local/bin/kubectl /usr/local/bin/kubectl1.37
# ⚠️ Defaults to the latest version. Please update with new versions as needed.
RUN ln -s /usr/local/bin/kubectl1.37 /usr/local/bin/kubectl

WORKDIR /
USER nonroot
CMD ["bash"]
