#!/usr/bin/env bash
# Cria o "pendrive suspeito" (imagem FAT16 de 16 MiB) usado nas atividades 09, 10 e 11.
# Uso: bash ../../scripts/criar_pendrive.sh saida/pendrive_suspeito.img
# - FERIAS.JPG e na verdade um PDF (camuflagem)
# - DESVIO.TXT e gravado e depois APAGADO: o conteudo continua na midia
set -euo pipefail
export PATH="$PATH:/usr/sbin:/sbin" MTOOLS_SKIP_CHECK=1
IMG="${1:-saida/pendrive_suspeito.img}"
TMP=$(mktemp -d)
mkdir -p "$(dirname "$IMG")"
rm -f "$IMG"

dd if=/dev/zero of="$IMG" bs=1M count=16 status=none
mkfs.fat -F 16 -n SUSPEITO "$IMG" >/dev/null

echo "Pendrive do almoxarifado - uso interno." > "$TMP/LEIAME.TXT"
printf 'Fornecedora Alfa - comercial - (11) 0000-0000\nFornecedora Beta - financeiro - (11) 0000-0001\n' > "$TMP/CONTATOS.TXT"
printf 'item;valor\nManutencao de TI;18500.00\nLicencas de software;4200.00\n' > "$TMP/ORCAMENT.CSV"
cat > "$TMP/FERIAS.JPG" <<'TXT'
%PDF-1.4
1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj
3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 595 200] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >> endobj
4 0 obj << /Length 120 >>
stream
BT /F1 14 Tf 40 150 Td (NOTA FISCAL 000123 - FORNECEDORA ALFA) Tj 0 -30 Td (Servicos adicionais - R$ 13.450,00) Tj ET
endstream
endobj
5 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj
trailer << /Root 1 0 R >>
%%EOF
TXT
cat > "$TMP/DESVIO.TXT" <<'TXT'
PLANILHA PARALELA - NAO DIVULGAR
mes;valor_desviado;conta_destino
2026-04;8800.00;AG 0001 CC 99999-9
2026-05;13450.00;AG 0001 CC 99999-9
TOTAL DESVIADO: 22250.00
TXT
mcopy -i "$IMG" "$TMP/LEIAME.TXT" "$TMP/CONTATOS.TXT" "$TMP/ORCAMENT.CSV" "$TMP/FERIAS.JPG" "$TMP/DESVIO.TXT" ::/
mdel -i "$IMG" ::/DESVIO.TXT
rm -rf "$TMP"
echo "Pendrive suspeito criado: $IMG ($(stat -c %s "$IMG") bytes)"
