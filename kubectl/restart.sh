#!/bin/sh
if [ -z "$1" ]
then
  deployment="$(kubectl get deployments --no-headers -o custom-columns=':metadata.name' | sort -u | fzf)"
  kubectl rollout restart deployment "$deployment"
else
  kubectl rollout restart deployment "$1"
fi
