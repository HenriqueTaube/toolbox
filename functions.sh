kmaintenance_rasp() {
  k apply -f /home/henrique/projetos/kube/toolbox/maintenance-namespace.yaml >/dev/null
  k -n maintenance delete pod toolbox-maintenance-rasp --ignore-not-found >/dev/null 2>&1
  k apply -f /home/henrique/projetos/kube/toolbox/maintenance-rasp.yaml >/dev/null
  k -n maintenance wait --for=condition=Ready pod/toolbox-maintenance-rasp --timeout=120s
  sleep 10
  k -n maintenance exec -it toolbox-maintenance-rasp -- zsh
}

kmaintenance_prox() {
  k apply -f /home/henrique/projetos/kube/toolbox/maintenance-namespace.yaml >/dev/null
  k -n maintenance delete pod toolbox-maintenance-prox --ignore-not-found >/dev/null 2>&1
  k apply -f /home/henrique/projetos/kube/toolbox/maintenance-prox.yaml >/dev/null
  k -n maintenance wait --for=condition=Ready pod/toolbox-maintenance-prox --timeout=120s
  sleep 10
  k -n maintenance exec -it toolbox-maintenance-prox -- zsh
}

kmaintenance_pod() {
  local ns="$1"
  local target_pod="$2"

  if [ -z "$ns" ] || [ -z "$target_pod" ]; then
    echo "uso: kmaintenance_pod <namespace> <pod>"
    echo "ex: kmaintenance_pod forgejo forgejo-5d97dd6f9c-dn6b6"
    return 1
  fi

  local node
  node="$(k -n "$ns" get pod "$target_pod" -o jsonpath='{.spec.nodeName}')"

  export POD_NAMESPACE="$ns"
  export POD_NODE="$node"

  k -n "$ns" delete pod toolbox-maintenance-pod --ignore-not-found >/dev/null 2>&1
  envsubst < /home/henrique/projetos/kube/toolbox/maintenance-pod.yaml | k apply -f -
  k -n "$ns" wait --for=condition=Ready pod/toolbox-maintenance-pod --timeout=60s
  k -n "$ns" exec -it toolbox-maintenance-pod -- /bin/zsh -i
  k -n "$ns" delete pod toolbox-maintenance-pod --ignore-not-found
}
