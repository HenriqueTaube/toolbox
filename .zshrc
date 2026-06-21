export ZSH=/usr/share/oh-my-zsh

alias wireguard="ssh netbird@192.168.1.188"
alias nextcloud-ssh="ssh nextcloud@192.168.1.224"
alias knots="ssh knots@192.168.1.151"
alias pihole="ssh pihole@192.168.1.233"
alias grafana="ssh root@192.168.1.115"

alias si='sudo -i'
alias perm='sudo chown -R $USER:$USER'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

alias tm='tmux a'

alias impressora='xdg-open http://localhost:631/printers >/dev/null 2>&1 &'

export TALOSCONFIG=/home/henrique/talos/talosconfig
export KUBECONFIG=/home/henrique/talos/kubeconfig

export TOOLBOX_IMAGE=192.168.1.152:30090/henrique/toolbox:latest
export KUBECONFIG_TALOS="/home/henrique/talos/kubeconfig"

export TOOLBOX_NS="default"

export TALOS_WORKER=192.168.1.152
export TALOS_CONTROL=192.168.1.113
export TALOSCONFIG_FILE=/home/henrique/talos/talosconfig

eval "$(fnm env --use-on-cd)"

pc-on() {
  kubectl delete job pc-on -n arduino --ignore-not-found >/dev/null 2>&1
  kubectl apply -k /home/henrique/gitops/apps/pc-on/overlays/homelab
}

k() {
  kubectl --kubeconfig /home/henrique/talos/kubeconfig "$@"
}

tc() {
  talosctl --talosconfig /home/henrique/talos/talosconfig "$@"
}

tn() {
  local node="$1"
  shift
  talosctl --talosconfig /home/henrique/talos/talosconfig -e 192.168.1.113 -n "$node" "$@"
}

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

ktoolbox() {
  local ns="$1"
  local pod="$2"
  local pvc="$3"
  local mount_path="${4:-/data}"

  if [ -z "$ns" ] || [ -z "$pod" ] || [ -z "$pvc" ]; then
    echo "uso: ktoolbox <namespace> <pod> <pvc> [mount_path]"
    echo "ex: ktoolbox forgejo forgejo-5d97dd6f9c-dn6b6 forgejo-data /data"
    return 1
  fi

  local node
  node="$(kubectl --kubeconfig /home/henrique/talos/kubeconfig -n "$ns" get pod "$pod" -o jsonpath='{.spec.nodeName}')"

  kubectl --kubeconfig /home/henrique/talos/kubeconfig apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: toolbox
  namespace: $ns
spec:
  restartPolicy: Never
  nodeSelector:
    kubernetes.io/hostname: $node
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: toolbox
      image: $TOOLBOX_IMAGE
      stdin: true
      tty: true
      command: ["/bin/zsh", "-i"]
      securityContext:
        allowPrivilegeEscalation: false
        runAsNonRoot: true
        runAsUser: 1000
        capabilities:
          drop: ["ALL"]
      volumeMounts:
        - name: target-pvc
          mountPath: $mount_path
  volumes:
    - name: target-pvc
      persistentVolumeClaim:
        claimName: $pvc
EOF

  kubectl --kubeconfig /home/henrique/talos/kubeconfig -n "$ns" wait --for=condition=Ready pod/toolbox --timeout=60s
  kubectl --kubeconfig /home/henrique/talos/kubeconfig -n "$ns" exec -it toolbox -- /bin/zsh -i
  kubectl --kubeconfig /home/henrique/talos/kubeconfig -n "$ns" delete pod toolbox --ignore-not-found
}

klonghorn() {
  kubectl -n longhorn-system port-forward --address 0.0.0.0 svc/longhorn-frontend 8080:80
}

tapply() {
  local ip="$1"
  local file="$2"
  shift 2 || true

  if [ -z "$ip" ] || [ -z "$file" ]; then
    echo "uso: tapply <ip> <arquivo.yaml>"
    return 1
  fi

  talosctl --talosconfig "$TALOSCONFIG_FILE" -e "$ip" -n "$ip" apply-config --file "$file" "$@"
}

ZSH_THEME="agnoster"
plugins=(git)
source /usr/share/oh-my-zsh/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH=$HOME/.npm-global/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
