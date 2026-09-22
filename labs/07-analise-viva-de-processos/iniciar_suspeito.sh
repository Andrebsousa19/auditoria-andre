#!/usr/bin/env bash
# Simula um processo suspeito, SEM nenhuma acao maliciosa:
# - e apenas uma copia do utilitario "nc" (netcat) escutando so na propria maquina (127.0.0.1)
# - usa um nome disfarcado de processo do sistema e roda de uma pasta oculta em /tmp
# - apaga o proprio executavel depois de iniciar (tecnica comum para esconder rastros)
# - mantem aberto um arquivo de "log" que tambem e apagado
set -e
DIR=/tmp/.cache-sys
mkdir -p "$DIR"
cp "$(readlink -f "$(command -v nc)")" "$DIR/kworker-upd"
cd "$DIR"
( exec 3>"$DIR/.keylog.txt"; echo "registro simulado de teclas: usuario=ana.souza" >&3
  exec ./kworker-upd -l -k 127.0.0.1 5555 >/dev/null 2>&1 ) &
sleep 1
rm -f "$DIR/kworker-upd" "$DIR/.keylog.txt"
echo "Processo suspeito iniciado. Descubra qual e!"
