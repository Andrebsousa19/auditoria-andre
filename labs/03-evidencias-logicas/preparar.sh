#!/usr/bin/env bash
# Gera a pasta "Documentos" copiada do notebook do suspeito
set -e
cd "$(dirname "$0")"
rm -rf saida && mkdir -p saida/documentos && cd saida/documentos
printf 'Reuniao com fornecedores - pauta\n1. Renovacao de contratos\n2. Prazos de entrega\n' > pauta.txt
# PDF disfarcado de foto
printf '%%PDF-1.4\n%% Nota fiscal 000123 - Fornecedora Alfa - Servicos adicionais R$ 13.450,00\n%%%%EOF\n' > praia.jpg
# ZIP disfarcado de texto
{ printf 'conta_destino: AG 0001 CC 99999-9\nsenha do banco: anotada no caderno\n'
  for i in $(seq 1 30); do echo "obs $i: nao comentar com ninguem"; done; } > dados.txt
zip -q anotacoes.zip dados.txt && rm dados.txt && mv anotacoes.zip lista_compras.txt
# foto "de verdade" (apenas o cabecalho JPEG + dados)
{ printf '\xff\xd8\xff\xe0\x00\x10JFIF\x00'; head -c 20000 /dev/urandom; printf '\xff\xd9'; } > churrasco.jpg
# arquivo com dados aleatorios (alta entropia, parece cifrado)
head -c 50000 /dev/urandom > backup.dat
# texto grande e repetitivo (baixa entropia)
for i in $(seq 1 500); do echo "Relatorio de estoque linha $i - item parafuso - quantidade 100"; done > estoque.txt
echo "Pasta do suspeito pronta em saida/documentos/"
