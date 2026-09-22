# Ambiente dos laboratorios - Auditoria Forense de Sistemas Digitais (UNINOVE)
# Todas as ferramentas ja ficam instaladas na imagem: o aluno nao precisa instalar nada.
FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      dosfstools mtools dcfldd sleuthkit \
      xxd file binutils bsdextrautils \
      openssl zip unzip sqlite3 \
      procps psmisc lsof iproute2 netcat-openbsd tree \
 && rm -rf /var/lib/apt/lists/*

ENV MTOOLS_SKIP_CHECK=1
ENV PATH="$PATH:/usr/sbin:/sbin"
