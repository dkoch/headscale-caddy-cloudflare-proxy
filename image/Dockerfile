# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv
ARG TAILSCALE_VERSION=v1.84.2

# Build Caddy with Cloudflare DNS integration.
FROM caddy:builder-alpine AS builder
RUN caddy-builder github.com/caddy-dns/cloudflare

# Build the actual deployment image using Tailscale.
FROM tailscale/tailscale:$TAILSCALE_VERSION

LABEL maintainer="dk@dkoch.org"

ENV CADDY_TARGET=
ENV CLOUDFLARE_DNS_API_TOKEN=
ENV TS_TAILNET=
ENV TS_HOSTNAME=
ENV TS_EXTRA_ARGS=
ENV TS_USERSPACE=true
ENV TS_STATE_DIR=/var/lib/tailscale/
ENV TS_AUTH_ONCE=true

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache ca-certificates mailcap && \
    caddy upgrade

# Ensure Caddy can access the tailscale socket, Caddy expects it to be under /var/run/tailscale so make a symlink
RUN mkdir --parents /var/run/tailscale && ln -s /tmp/tailscaled.sock /var/run/tailscale/tailscaled.sock

# Add the modified startup script
COPY start.sh /usr/bin/start.sh
RUN  chmod +x /usr/bin/start.sh

# And run it
CMD  [ "start.sh" ]
