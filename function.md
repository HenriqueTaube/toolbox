kmaintenance_rasp() {
  k apply -f /home/henrique/talos/toolbox/maintenance-namespace.yaml >/dev/null
  k -n maintenance delete pod toolbox-maintenance-rasp --ignore-not-found >/dev/null 2>&1
  k apply -f /home/henrique/talos/toolbox/maintenance-rasp.yaml >/dev/null
  k -n maintenance wait --for=condition=Ready pod/toolbox-maintenance-rasp --timeout=120s
  sleep 10
  k -n maintenance exec -it toolbox-maintenance-rasp -- zsh
}

kmaintenance_prox() {
  k apply -f /home/henrique/talos/toolbox/maintenance-namespace.yaml >/dev/null
  k -n maintenance delete pod toolbox-maintenance-prox --ignore-not-found >/dev/null 2>&1
  k apply -f /home/henrique/talos/toolbox/maintenance-prox.yaml >/dev/null
  k -n maintenance wait --for=condition=Ready pod/toolbox-maintenance-prox --timeout=120s
  sleep 10
  k -n maintenance exec -it toolbox-maintenance-prox -- zsh
}
