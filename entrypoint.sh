#!/bin/bash

# arguments for vnc server
# '-fg' runs the server in foreground
VNCSERVER_ARGS=("-fg")
# allow access not only from localhost
VNCSERVER_ARGS+=("-localhost no")

# set password for the vnc server if requested (and not set before)
if [ ! -f "~/.vnc/passwd" ]; then
    if [ -n "$VNC_PASSWORD" ]; then
        printf "$VNC_PASSWORD\n$VNC_PASSWORD\n\n" | vncpasswd
    else
        # disable authentication on the server, because no password is requested by the user
        VNCSERVER_ARGS+=("-SecurityTypes None")
        # needed because of the 'localhost no' parameter above
        VNCSERVER_ARGS+=("--I-KNOW-THIS-IS-INSECURE")
    fi
fi

# this function is called when 'docker stop' was executed
function _term() {
    echo "Caught SIGTERM signal!"

    # gracefully kill the vnc server
    # there should be only one server be running...
    vncserver -kill :*
}
trap _term SIGTERM

# start vncserver
eval vncserver ${VNCSERVER_ARGS[@]} &
SERVER_PID=$!
wait "$SERVER_PID"
