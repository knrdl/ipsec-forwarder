FROM alpine:3.22.0

RUN apk update && apk add vpnc bash socat

# requires `docker build` to be executed with DOCKER_BUILDKIT=1
COPY --chown=0:0 --chmod=700 entrypoint.sh /

ENTRYPOINT /entrypoint.sh
