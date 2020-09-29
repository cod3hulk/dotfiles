#!/bin/bash
KUBE_BINARY='kubectl'
KUBE_CONTEXT=`$KUBE_BINARY config current-context`
KUBE_NAMESPACE=`$KUBE_BINARY config view --minify --output 'jsonpath={..namespace}'`
echo "${KUBE_CONTEXT}:${KUBE_NAMESPACE:-none}"
