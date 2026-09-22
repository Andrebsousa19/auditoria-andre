#!/usr/bin/env bash
# Simula um "incidente" na maquina: um servico escutando numa porta estranha
# e um arquivo temporario deixado pelo invasor. Nada disso e malicioso de verdade.
cd "$(dirname "$0")"
nohup nc -l -k 127.0.0.1 4444 >/dev/null 2>&1 &
echo "id=4471 destino=exfil.exemplo.invalid" > /tmp/.sessao_4471
echo "Incidente simulado: porta 4444 aberta (PID $!) e arquivo /tmp/.sessao_4471 criado."
