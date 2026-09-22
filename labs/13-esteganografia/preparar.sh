#!/usr/bin/env bash
# Cria a "foto do evento" que o suspeito postou na rede social da empresa.
# Ela esconde um ZIP colado depois do fim da imagem PNG (marcador IEND).
set -e
cd "$(dirname "$0")"
rm -rf saida && mkdir -p saida/tmp
printf 'Contas para deposito:\nAG 0001 CC 99999-9\nAG 0002 CC 88888-8\nEntrega do pendrive: sexta, 19h, estacionamento\n' > saida/tmp/instrucoes.txt
( cd saida/tmp && zip -q ../pacote.zip instrucoes.txt )
cat amostra/logo_empresa.png saida/pacote.zip > saida/foto_evento.png
rm -rf saida/tmp saida/pacote.zip
echo "Imagem suspeita pronta: saida/foto_evento.png"
