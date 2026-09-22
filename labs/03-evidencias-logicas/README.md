# Atividade 03 – Tratamento de evidências lógicas: assinatura, entropia e palavras-chave

> **Professor Esp. Marcelino Dias da Silva Junior** · UNINOVE · Disciplina: **Auditoria Forense de Sistemas Digitais**
> **Aula relacionada:** Tratamento de evidências lógicas

## 🎯 Objetivo
Analisar uma pasta de documentos do suspeito usando três técnicas: **assinatura de arquivo** (contra a camuflagem), **entropia** (taxa de compressão) e **busca por palavras-chave**.

## 📚 Conceito em 1 minuto
- **Camuflagem:** trocar a extensão para esconder o tipo real (ex.: um `.pdf` renomeado para `.jpg`).
- **Assinatura (*magic number*):** os primeiros bytes revelam o tipo real do arquivo, seja qual for a extensão.
- **Entropia:** quanto mais "aleatório" o conteúdo, **menos** ele comprime. Dados **cifrados ou compactados** têm entropia alta.

| Tipo | Primeiros bytes (hex) | Texto |
|---|---|---|
| JPEG | `ff d8 ff` | `ÿØÿ` |
| PDF | `25 50 44 46` | `%PDF` |
| ZIP / DOCX / XLSX | `50 4b 03 04` | `PK..` |
| PNG | `89 50 4e 47` | `.PNG` |

## 🧪 Passo a passo

```bash
cd /workspaces/*/labs/03-evidencias-logicas
bash preparar.sh
ls -l saida/documentos/
```

**1. Assinatura: o tipo real de cada arquivo**

```bash
file saida/documentos/*
```

Confira os primeiros bytes dos arquivos suspeitos:

```bash
xxd -l 8 saida/documentos/praia.jpg
xxd -l 8 saida/documentos/lista_compras.txt
xxd -l 8 saida/documentos/churrasco.jpg
```

📌 Qual extensão **mente**? Veja o que o "texto" esconde:

```bash
unzip -l saida/documentos/lista_compras.txt
unzip -p saida/documentos/lista_compras.txt
```

**2. Entropia: taxa de compressão.** Compare o tamanho original com o tamanho compactado:

```bash
for f in saida/documentos/*; do
  orig=$(stat -c %s "$f"); comp=$(gzip -c "$f" | wc -c)
  echo "$(basename "$f")  original=$orig  comprimido=$comp  taxa=$((comp * 100 / orig))%"
done
```

📌 Taxa perto de **100%** significa entropia alta: o arquivo não comprime (aleatório, cifrado ou já compactado, como JPEG e ZIP). Taxa baixa significa texto repetitivo.
> Arquivos **muito pequenos** podem passar de 100%, porque o cabeçalho do gzip é maior que a economia. Ignore-os nessa comparação.

**3. Busca por palavras-chave**

```bash
grep -r -i -l -E "senha|conta|nota fiscal" saida/documentos/
```

📌 O `grep` **não** encontra a palavra "senha" dentro do ZIP camuflado, porque o conteúdo está **compactado**. Por isso o perito primeiro identifica e extrai os arquivos, e só depois faz a busca:

```bash
unzip -p saida/documentos/lista_compras.txt | grep -i -E "senha|conta"
```

**4. Hash de tudo o que foi analisado**

```bash
sha256sum saida/documentos/* | tee saida/hashes_documentos.txt
```

## ❓ Perguntas
1. Quais arquivos estavam camuflados? Qual o tipo real de cada um?
2. Qual arquivo tem a maior entropia? O que isso pode indicar numa perícia?
3. Por que a busca por palavras-chave falhou no arquivo ZIP?
4. Monte uma tabela: arquivo, extensão, tipo real, taxa de compressão e relevância para o caso.
