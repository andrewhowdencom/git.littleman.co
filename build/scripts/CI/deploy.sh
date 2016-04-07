#!/bin/bash

set -e

google-cloud-sdk/bin/kubectl rolling-update webserver --image="gogs/gogs:$GOGS_VERSION"
