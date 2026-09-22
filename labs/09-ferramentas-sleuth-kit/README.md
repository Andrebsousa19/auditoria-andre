# Atividade 09 – Ferramentas forenses: The Sleuth Kit (o "motor" do Autopsy)

> **Professor Esp. Marcelino Dias da Silva Junior** · UNINOVE · Disciplina: **Auditoria Forense de Sistemas Digitais**
> **Aula relacionada:** Ferramentas utilizadas durante uma análise forense computacional

## 🎯 Objetivo
Analisar a imagem do pendrive suspeito com uma **ferramenta forense de verdade**: listar arquivos (inclusive apagados), recuperar conteúdo e gerar uma **linha do tempo** automaticamente.

## 📚 Conceito em 1 minuto
- **The Sleuth Kit (TSK):** conjunto de ferramentas livres de linha de comando. O **Autopsy** é a interface gráfica que usa o TSK por baixo, assim como EnCase e FTK fazem com os motores deles.

| Ferramenta | Para que serve |
|---|---|
| `fsstat` | Informações do sistema de arquivos |
| `fls` | Lista arquivos e diretórios, **incluindo apagados** (marcados com `*`) |
| `istat` | Metadados de um arquivo (tamanho, datas, clusters) |
| `icat` | Extrai o conteúdo de um arquivo pelo número (inode) |
| `mactime` | Monta a linha do tempo a partir do `fls -m` |

## 🧪 Passo a passo

```bash
cd /workspaces/*/labs/09-ferramentas-sleuth-kit
bash ../../scripts/criar_pendrive.sh saida/pendrive01.img
sha256sum saida/pendrive01.img | tee saida/pendrive01.sha256
```

**1. O sistema de arquivos**

```bash
fsstat saida/pendrive01.img | head -n 25
```

**2. Lista de arquivos, incluindo os apagados**

```bash
fls -r saida/pendrive01.img
```

📌 A linha com **`*`** é um arquivo **apagado**. O número antes do `:` é o endereço (inode) dele. O nome aparece como **`_ESVIO.TXT`** porque, ao apagar, o FAT troca a **1ª letra** por `0xE5` (veja a Atividade 11), e a ferramenta mostra `_` no lugar dela.

Só os apagados:

```bash
fls -r -d saida/pendrive01.img
```

**3. Metadados e recuperação do arquivo apagado**

```bash
INODE=$(fls -r -d saida/pendrive01.img | grep -i esvio | awk '{print $3}' | tr -d ':')
echo "Inode do arquivo apagado: $INODE"
istat saida/pendrive01.img $INODE
icat saida/pendrive01.img $INODE | tee saida/DESVIO_recuperado.txt
```

**4. Extraindo um arquivo "normal" e conferindo o tipo real**

```bash
INODE_FOTO=$(fls saida/pendrive01.img | grep -i ferias | awk '{print $2}' | tr -d ':')
icat saida/pendrive01.img $INODE_FOTO > saida/FERIAS.JPG
file saida/FERIAS.JPG
```

**5. Linha do tempo automática**

```bash
fls -r -m / saida/pendrive01.img > saida/body.txt
mactime -b saida/body.txt -d 2>/dev/null | tee saida/linha_do_tempo.csv
```

**6. A imagem continua íntegra?**

```bash
sha256sum -c saida/pendrive01.sha256
```

## ❓ Perguntas
1. Qual o tipo do sistema de arquivos e o rótulo do volume (`fsstat`)?
2. Como o `fls` indica um arquivo apagado? Por que o nome aparece como `_ESVIO.TXT`? Qual era o nome original?
3. Qual o conteúdo recuperado com o `icat`? Ele é relevante para o caso?
4. O que o `file` revelou sobre `FERIAS.JPG`?
5. Qual a vantagem de uma ferramenta como o TSK/Autopsy em relação a fazer tudo "na mão" com `xxd` e `dd` (Atividade 11)?
