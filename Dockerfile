FROM base/archlinux
MAINTAINER cluster-mailboxes

# Bug with stupid key revocation and old images
RUN pacman -Syy && \
    pacman --noconfirm -S archlinux-keyring wget && \
    pacman -Syu --noconfirm && \
    pacman-db-upgrade && \
    pacman --noconfirm -S --needed base-devel && \
    wget https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64 -O /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu && \
    useradd -m worker-bee && \
    echo 'worker-bee ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/worker-bee && \
    install -d -m 777 /tmp/aur

USER worker-bee
WORKDIR /tmp/aur

RUN wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz && \
    tar xf package-query.tar.gz && \
    wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz && \
    tar xf yaourt.tar.gz

WORKDIR /tmp/aur/package-query
RUN makepkg -sri --noconfirm

WORKDIR /tmp/aur/yaourt
RUN makepkg -sri --noconfirm

USER root
RUN pacman --noconfirm -Rns $(pacman -Qttdq) && \
    pacman --noconfirm -Sc && \
    rm -rf /tmp/* && \
    userdel worker-bee
