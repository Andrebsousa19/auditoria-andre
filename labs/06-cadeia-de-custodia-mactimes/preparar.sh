#!/usr/bin/env bash
# Recria a pasta do usuario jsilva na estacao FIN-014, com os horarios originais dos arquivos
set -e
cd "$(dirname "$0")"
rm -rf saida && mkdir -p saida/FIN-014/home/jsilva/{Documentos,Downloads,.cache}
B=saida/FIN-014/home/jsilva
echo "planilha de pagamentos - agosto" > $B/Documentos/pagamentos.xlsx
echo "comprovante TED 180.000,00"      > $B/Downloads/comprovante_ted.pdf
echo "lista de fornecedores"           > $B/Documentos/fornecedores.txt
echo "E:\pagamentos.xlsx aberto"       > $B/.cache/recentes.log
echo "ferias em familia"               > $B/Documentos/ferias.txt
touch -d "2026-08-03 09:15" $B/Documentos/fornecedores.txt
touch -d "2026-07-20 18:00" $B/Documentos/ferias.txt
touch -d "2026-08-14 22:17" $B/Documentos/pagamentos.xlsx
touch -d "2026-08-14 22:34" $B/Downloads/comprovante_ted.pdf
touch -d "2026-08-14 22:10" $B/.cache/recentes.log
touch -a -d "2026-08-14 22:39" $B/Documentos/pagamentos.xlsx
echo "Pasta da estacao FIN-014 pronta em saida/FIN-014/"
