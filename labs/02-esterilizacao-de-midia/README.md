# Atividade 02 – Equipamentos para obtenção e armazenamento: esterilização de mídia (wipe)

> **Professor Esp. Marcelino Dias da Silva Junior** · UNINOVE · Disciplina: **Auditoria Forense de Sistemas Digitais**
> **Aula relacionada:** Equipamentos utilizados para obtenção e armazenamento de evidências (reforça: Tratamento de evidências lógicas, esterilização da mídia)

## 🎯 Objetivo
Mostrar por que a mídia de destino precisa passar por **wipe** antes de receber uma evidência e por que a **formatação rápida não basta**.

## 📚 Conceito em 1 minuto
- **Contaminação cruzada (*cross-contamination*):** restos de um caso anterior se misturam à evidência do caso atual.
- **Wipe:** sobrescrever **todos** os setores da mídia (ex.: com zeros) antes de usá-la.
- **Formatação rápida:** recria só a estrutura do sistema de arquivos, e os dados antigos continuam nos setores.

## 🧪 Passo a passo

```bash
cd /workspaces/*/labs/02-esterilizacao-de-midia
mkdir -p saida
```

**1. Um HD "reaproveitado", ainda com dados de outro caso (8 MiB):**

```bash
yes "CASO-2025-099 DADOS SIGILOSOS DE OUTRO CASO" | head -c 8M > saida/hd_destino.img
xxd saida/hd_destino.img | head -n 3
```

**2. Formatação rápida. Os dados sumiram?**

```bash
mkfs.fat -n DESTINO saida/hd_destino.img
mdir -i saida/hd_destino.img ::/
grep -a -c "CASO-2025-099" saida/hd_destino.img
```

📌 O disco parece vazio (`mdir`), mas o `grep` ainda encontra **milhares** de ocorrências do outro caso.

**3. Wipe: sobrescrever tudo com zeros**

```bash
dd if=/dev/zero of=saida/hd_destino.img bs=1M count=8 conv=notrunc status=progress
```

**4. Conferência do wipe** (deve mostrar só zeros e contagem 0):

```bash
xxd saida/hd_destino.img | head -n 3
grep -a -c "CASO-2025-099" saida/hd_destino.img
```

Conferência pelo hash: um arquivo de 8 MiB só com zeros tem **sempre** o mesmo hash.

```bash
head -c 8M /dev/zero | sha256sum
sha256sum saida/hd_destino.img
```

**5. Registre o wipe** (vai para a cadeia de custódia):

```bash
echo "Wipe da midia de destino em $(date -u '+%Y-%m-%d %H:%M UTC') por $(whoami) - SHA-256: $(sha256sum saida/hd_destino.img | cut -d' ' -f1)" | tee saida/registro_wipe.txt
```

## ❓ Perguntas
1. Depois da formatação rápida, o `mdir` mostrou o disco vazio. Por que o `grep` ainda achou os dados?
2. Se esse HD recebesse a imagem do pendrive do caso atual **sem wipe**, qual seria o risco para o laudo?
3. Como o hash ajudou a **provar** que o wipe foi completo?
4. Cite 3 itens obrigatórios da bancada do perito além da mídia esterilizada.
