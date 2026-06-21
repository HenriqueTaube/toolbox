FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        dnsutils \
        e2fsprogs \
        fdisk \
        file \
        gnupg \
        git \
        htop \
        iproute2 \
        iptables \
        iputils-ping \
        jq \
        less \
        lm-sensors \
        lsof \
        mtr-tiny \
        nano \
        netcat-openbsd \
        nmap \
        openssh-client \
        openssl \
        procps \
        parted \
        rsync \
        telnet \
        tcpdump \
        tmux \
        traceroute \
        tree \
        unzip \
        util-linux \
        vim \
        wget \
        zip \
        zsh \
    && install -d /usr/share/postgresql-common/pgdg \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      | gpg --dearmor -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.gpg \
    && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client-17 \
    && useradd -m -u 1000 -s /bin/zsh toolbox \
    && git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /home/toolbox/.oh-my-zsh || true \
    && chown -R 1000:0 /home/toolbox \
    && rm -rf /var/lib/apt/lists/*

ENV TERM=xterm-256color
ENV HOME=/home/toolbox
ENV ZSH=/home/toolbox/.oh-my-zsh

COPY zshrc /home/toolbox/.zshrc

RUN chown 1000:0 /home/toolbox/.zshrc

LABEL org.opencontainers.image.title="toolbox-k8s" \
      org.opencontainers.image.description="Imagem de toolbox para debug e manutencao em Kubernetes" \
      org.opencontainers.image.source="https://forgejo.example.local" \
      org.opencontainers.image.licenses="MIT"

USER 1000
WORKDIR /home/toolbox

ENTRYPOINT ["/bin/zsh","-i"]
