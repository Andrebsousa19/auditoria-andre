# Atividade 11 – Análise de sistemas de arquivos: FAT16 "na mão"

> **Professor Esp. Marcelino Dias da Silva Junior** · UNINOVE · Disciplina: **Auditoria Forense de Sistemas Digitais**
> **Aula relacionada:** Análise de sistemas de arquivos (reforça: Tratamento de evidências lógicas)

## 🎯 Objetivo
Entender **como** um arquivo apagado continua na mídia, olhando os bytes do FAT16 em hexadecimal e recuperando o arquivo **só com `grep`, `xxd` e `dd`**.

## 📚 Conceito em 1 minuto
- **FAT** (FAT12/16/32): sistema de arquivos simples, comum em **pendrives e cartões de memória**.
- **Setor de boot** (setor 0): descreve o volume e termina com a assinatura **`55 AA`**.
- **Entrada de diretório:** guarda nome, tamanho, datas e cluster inicial de cada arquivo.
- **Arquivo apagado:** o 1º byte do nome vira **`0xE5`** e os clusters são marcados como livres (**não alocados**), mas **o conteúdo continua lá**.

## 🧪 Passo a passo

```bash
cd /workspaces/*/labs/11-sistema-de-arquivos-fat
bash ../../scripts/criar_pendrive.sh saida/pendrive01.img
```

**1. O setor de boot**

```bash
file saida/pendrive01.img
xxd -l 64 saida/pendrive01.img
xxd -s 510 -l 2 saida/pendrive01.img
```

📌 Procure `SUSPEITO` e `FAT16` na coluna da direita. Os bytes 510–511 são **`55aa`**.

**2. O que o sistema de arquivos mostra**

```bash
mdir -i saida/pendrive01.img ::/
```

**3. Cópia lógica × imagem**

```bash
mkdir -p saida/copia_logica
mcopy -s -i saida/pendrive01.img ::/ saida/copia_logica/
grep -r "PLANILHA" saida/copia_logica/ || echo "Nada na copia logica"
grep -a -c "PLANILHA" saida/pendrive01.img
```

📌 Na cópia lógica não há nada, mas na imagem bit a bit a planilha **existe**.

**4. A entrada de diretório apagada (`0xE5`)**

```bash
xxd saida/pendrive01.img | grep "ESVIO"
```

📌 O nome era `DESVIO.TXT`: o `D` (`0x44`) virou **`e5`**.

**5. Onde está o conteúdo? (offset em bytes)**

```bash
grep -a -b -o "PLANILHA PARALELA" saida/pendrive01.img
```

**6. Recuperando com `dd`** (setor = offset ÷ 512)

```bash
OFFSET=$(grep -a -b -o "PLANILHA PARALELA" saida/pendrive01.img | cut -d: -f1)
SETOR=$((OFFSET / 512))
echo "Offset $OFFSET = setor $SETOR"
dd if=saida/pendrive01.img of=saida/recuperado.txt bs=512 skip=$SETOR count=1
tr -d '\000' < saida/recuperado.txt
sha256sum saida/recuperado.txt
```

## ❓ Perguntas
1. O que significam os bytes `55 aa` no fim do setor 0?
2. Por que o arquivo não aparece no `mdir` nem na cópia lógica?
3. Qual byte marca a entrada como apagada? O nome original pode ser recuperado por completo?
4. Em qual offset e setor estava o conteúdo? O que ele revela?
5. O que teria acontecido se o suspeito gravasse muitos arquivos novos depois de apagar este?
