#!/usr/bin/env bash
# Confere se todas as ferramentas dos laboratorios estao disponiveis
echo ">> Verificando ferramentas dos laboratorios..."
falta=0
for f in md5sum sha256sum dd dcfldd xxd file strings mkfs.fat mdir mcopy fls icat fsstat mactime \
         openssl zip unzip sqlite3 ps pstree lsof ss nc tree; do
  if command -v "$f" >/dev/null 2>&1; then echo "   [OK]    $f"; else echo "   [FALTA] $f"; falta=1; fi
done
[ $falta -eq 0 ] && echo ">> Ambiente pronto! Abra o README.md para escolher a atividade." \
                 || echo ">> Alguma ferramenta falta. Avise o professor."
