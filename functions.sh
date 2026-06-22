TOOLBOX_REPO="${TOOLBOX_REPO:-$HOME/projetos/kube/toolbox}"
TOOLBOX_IMAGE="${TOOLBOX_IMAGE:-192.168.1.191:3000/henrique/toolbox:latest}"

kmaintenance_rasp() {
  k apply -f "$TOOLBOX_REPO/maintenance-namespace.yaml" >/dev/null
  k -n maintenance delete pod toolbox-maintenance-rasp --ignore-not-found >/dev/null 2>&1
  k apply -f "$TOOLBOX_REPO/maintenance-rasp.yaml" >/dev/null
  k -n maintenance wait --for=condition=Ready pod/toolbox-maintenance-rasp --timeout=120s
  sleep 10
  k -n maintenance exec -it toolbox-maintenance-rasp -- zsh
}

kmaintenance_prox() {
  k apply -f "$TOOLBOX_REPO/maintenance-namespace.yaml" >/dev/null
  k -n maintenance delete pod toolbox-maintenance-prox --ignore-not-found >/dev/null 2>&1
  k apply -f "$TOOLBOX_REPO/maintenance-prox.yaml" >/dev/null
  k -n maintenance wait --for=condition=Ready pod/toolbox-maintenance-prox --timeout=120s
  sleep 10
  k -n maintenance exec -it toolbox-maintenance-prox -- zsh
}

kmaintenance_pod() {
  local ns="$1"
  local target_pod="$2"

  if [ -z "$ns" ] || [ -z "$target_pod" ]; then
    echo "usage: kmaintenance_pod <namespace> <pod>"
    echo "ex: kmaintenance_pod forgejo forgejo-5d97dd6f9c-dn6b6"
    return 1
  fi

  local node
  node="$(k -n "$ns" get pod "$target_pod" -o jsonpath='{.spec.nodeName}')"

  export POD_NAMESPACE="$ns"
  export POD_NODE="$node"
  export TOOLBOX_IMAGE

  k -n "$ns" delete pod toolbox-maintenance-pod --ignore-not-found >/dev/null 2>&1
  envsubst < "$TOOLBOX_REPO/maintenance-pod.yaml" | k apply -f -
  k -n "$ns" wait --for=condition=Ready pod/toolbox-maintenance-pod --timeout=60s
  k -n "$ns" exec -it toolbox-maintenance-pod -- /bin/zsh -i
  k -n "$ns" delete pod toolbox-maintenance-pod --ignore-not-found
}
