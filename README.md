# Toolbox for Kubernetes

A multi-arch debug and maintenance image for Kubernetes clusters — nodes and pods.

This image is not meant to run applications. It exists to give you a comfortable shell inside the cluster for troubleshooting, network inspection, and maintenance tasks.

---

## Tools Included

- `zsh` + `oh-my-zsh` (agnoster theme)
- `vim`, `nano`
- `curl`, `wget`, `jq`
- `git`, `tree`, `file`, `less`
- `htop`, `lsof`, `procps`
- `iproute2`, `iptables`, `iputils-ping`
- `dnsutils`, `netcat-openbsd`, `nmap`, `traceroute`, `mtr-tiny`
- `openssl`, `telnet`, `tcpdump`
- `tmux`, `rsync`, `zip`, `unzip`
- `postgresql-client-17`

---

## Build

The `bootstrap.sh` script handles everything:

1. Copies your local `~/.zshrc` into the build context
2. Sets up a multi-arch buildx builder
3. Builds and pushes `amd64` + `arm64` to your registry

Edit the registry IP at the top of the file before running:

```sh
# bootstrap.sh
REGISTRY_IP="192.168.1.191:3000"
```

Then run:

```bash
./bootstrap.sh
```

---

## Shell Functions

The file `functions.sh` contains zsh functions to use the toolbox in your cluster. Source it or paste the functions into your `~/.zshrc`.

### Node Maintenance

Spawns a **privileged pod** with full host access (`hostPID`, `hostNetwork`, `/`, `/dev`, `/run` mounted). Used for low-level node troubleshooting.

```bash
kmaintenance_prox   # lands on worker-prox (amd64)
kmaintenance_rasp   # lands on worker-rasp (arm64)
```

### Pod Maintenance

Spawns a temporary toolbox pod co-located on the same node as a target pod. No privileges — useful for network and filesystem debugging at the application level.

```bash
kmaintenance_pod <namespace> <pod>

# example
kmaintenance_pod forgejo forgejo-5d97dd6f9c-dn6b6
```

The pod is automatically deleted after you exit the shell.

---

## Image Pull Policy

Always set `imagePullPolicy: Always` on maintenance pods to avoid stale cached images on nodes. All YAMLs in this repo already include this.
