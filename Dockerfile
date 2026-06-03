FROM alpine:3.21

# OCI labels — links the GHCR package back to the repository
LABEL org.opencontainers.image.source="https://github.com/vegardhw/syslog-viewer"
LABEL org.opencontainers.image.description="Minimal syslog file aggregator and streamer"
LABEL org.opencontainers.image.licenses="MIT"

# Only install what is actually used at runtime:
#   coreutils — provides GNU date (needed for `date -d` in entrypoint.sh)
#   bash      — shell runtime
# DL3018: pinning apk versions is impractical; the base image is pinned instead.
# hadolint ignore=DL3018
RUN apk add --no-cache \
    coreutils \
    bash \
  && mkdir /logs

# Copy and mark executable in a single layer (no extra RUN chmod needed)
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
