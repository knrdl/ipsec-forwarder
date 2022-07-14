#!/bin/bash

set -euo pipefail

: ${VPNC_GATEWAY?env var is not set}
: ${VPNC_ID?env var is not set}
: ${VPNC_SECRET?env var is not set}
: ${VPNC_USERNAME?env var is not set}
: ${VPNC_PASSWORD?env var is not set}

vpnc --no-detach --gateway "$VPNC_GATEWAY" --id "$VPNC_ID" --secret "$VPNC_SECRET" --username "$VPNC_USERNAME" \
     --password "$VPNC_PASSWORD" --ifmode tap --non-inter --dpd-idle 0 --debug 1 &

: ${FORWARDS?env var is not set}

readarray -td, FWDS <<< "$FORWARDS,"
unset 'FWDS[-1]'

for fwd in "${FWDS[@]}"
do
    readarray -td: parts <<< "$fwd:"
    unset 'parts[-1]'
    LOCAL_PORT="${parts[0]}"
    REMOTE_IP="${parts[1]}"
    REMOTE_PORT="${parts[2]}"

    : ${LOCAL_PORT?bad FORWARDS env var}
    : ${REMOTE_IP?bad FORWARDS env var}
    : ${REMOTE_PORT?bad FORWARDS env var}

    echo "Forwarding $REMOTE_IP:$REMOTE_PORT (remove) to port $LOCAL_PORT (local)"
    socat "TCP-LISTEN:$LOCAL_PORT,bind=0.0.0.0,reuseaddr,fork" "TCP:$REMOTE_IP:$REMOTE_PORT" &
done

# Wait for any process (socats or vpnc) to exit
wait -n

# Exit with status of process that exited first
exit $?
