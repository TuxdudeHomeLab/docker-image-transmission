# syntax=docker/dockerfile:1

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} AS with-scripts

COPY scripts/start-transmission.sh /scripts/

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG PACKAGES_TO_INSTALL

# hadolint ignore=SC3040
RUN --mount=type=bind,target=/scripts,from=with-scripts,source=/scripts \
    set -E -e -o pipefail \
    && export HOMELAB_VERBOSE=y \
    # Install dependencies. \
    && homelab install ${PACKAGES_TO_INSTALL:?} \
    # Copy the start-transmission.sh script. \
    && mkdir -p /opt/transmission \
    && cp /scripts/start-transmission.sh /opt/transmission/ \
    && ln -sf /opt/transmission/start-transmission.sh /opt/bin/start-transmission \
    # Clean up. \
    && homelab cleanup

# Transmission RPC
EXPOSE 9091

WORKDIR /

CMD ["start-transmission"]
STOPSIGNAL SIGTERM
