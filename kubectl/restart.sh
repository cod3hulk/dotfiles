#!/bin/sh
FZF_CMD="fzf"
[ ! -z "$1" ] && FZF_CMD="$FZF_CMD -q $1"
DEPLOYMENT="$(kubectl get deployments --no-headers -o custom-columns=':metadata.name' | sort -u | $FZF_CMD)"
kubectl rollout restart deployment "$DEPLOYMENT"
