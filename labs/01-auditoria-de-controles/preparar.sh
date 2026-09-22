#!/usr/bin/env bash
# Monta uma copia (amostra) das configuracoes do servidor FIN-SRV01 para a auditoria
set -e
cd "$(dirname "$0")"
rm -rf saida && mkdir -p saida/servidor/etc saida/servidor/financeiro
cat > saida/servidor/etc/passwd <<'TXT'
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
ana.souza:x:1001:1001:Ana Souza - Financeiro:/home/ana.souza:/bin/bash
joao.lima:x:1002:1002:Joao Lima - Compras:/home/joao.lima:/bin/bash
suporte:x:0:0:Conta de suporte:/root:/bin/bash
estagiario2024:x:1003:1003:Estagiario (desligado em 2024):/home/estagiario2024:/bin/bash
TXT
cat > saida/servidor/etc/shadow <<'TXT'
root:$6$xyz$hashficticio:20000:0:99999:7:::
daemon:*:20000:0:99999:7:::
ana.souza:$6$abc$hashficticio:20100:0:90:7:::
joao.lima:$6$def$hashficticio:19000:0:99999:7:::
suporte::20000:0:99999:7:::
estagiario2024:$6$ghi$hashficticio:19500:0:99999:7:::
TXT
echo "mes;fornecedor;valor" > saida/servidor/financeiro/pagamentos.csv
echo "relatorio interno" > saida/servidor/financeiro/relatorio.txt
chmod 640 saida/servidor/financeiro/relatorio.txt
chmod 777 saida/servidor/financeiro/pagamentos.csv
echo "Amostra do servidor FIN-SRV01 pronta em saida/servidor/"
