#!/usr/bin/env bash
# Coleta de dados volateis seguindo a ORDEM DE VOLATILIDADE (RFC 3227):
# do mais volatil para o menos volatil. Cada saida e registrada com horario UTC e hash.
cd "$(dirname "$0")"
OUT="saida/coleta_$(date -u +%Y%m%d_%H%M%S)"
while [ -e "$OUT" ]; do sleep 1; OUT="saida/coleta_$(date -u +%Y%m%d_%H%M%S)"; done
mkdir -p "$OUT"
LOG="$OUT/00_log_coleta.txt"

coletar() {   # coletar <arquivo> <comando...>
  local arq="$OUT/$1"; shift
  echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $*" >> "$LOG"
  "$@" > "$arq" 2>&1
  echo "   -> $arq"
}

echo "Perito: $(whoami) | Host: $(hostname) | Inicio (UTC): $(date -u) | Local: $(date)" > "$LOG"
echo ">> 1. Tabela de roteamento e cache ARP";   coletar 01_rotas.txt ip route;  coletar 02_arp.txt ip neigh
echo ">> 2. Tabela de processos";                coletar 03_processos.txt ps auxww
echo ">> 3. Conexoes e portas abertas";          coletar 04_conexoes.txt ss -tunap
echo ">> 4. Usuarios logados e tempo ligado";    coletar 05_usuarios.txt who -a; coletar 06_uptime.txt uptime
echo ">> 5. Estatisticas de kernel e memoria";   coletar 07_kernel.txt uname -a; coletar 08_memoria.txt free -h
echo ">> 6. Arquivos temporarios do sistema";    coletar 09_tmp.txt ls -la /tmp
echo ">> 7. Discos e montagens";                 coletar 10_discos.txt df -h
echo "Fim (UTC): $(date -u)" >> "$LOG"
( cd "$OUT" && sha256sum 0*.txt 1*.txt > SHA256SUMS )
echo ">> Coleta concluida em $OUT (hashes em $OUT/SHA256SUMS)"
