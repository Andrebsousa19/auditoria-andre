# Atividade 10 – Análise por meio de duplicação pericial (`dd` e `dcfldd`)

> **Professor Esp. Marcelino Dias da Silva Junior** · UNINOVE · Disciplina: **Auditoria Forense de Sistemas Digitais**
> **Aula relacionada:** Análise por meio de duplicação pericial (reforça: Equipamentos, Algoritmos criptográficos)

## 🎯 Objetivo
Fazer a **cópia bit a bit** do pendrive suspeito e **provar com hash** que a cópia é idêntica à original.

## 📚 Conceito em 1 minuto
- **Cópia bit a bit (*bit-stream*):** replica cada 0 e 1 da mídia, inclusive **arquivos apagados** e **áreas não alocadas**. O Ctrl+C / Ctrl+V não faz isso.
- **Duas cópias:** uma para **análise** e outra **guardada** em local seguro.
- **Integridade:** hash da original, depois a cópia, depois o hash da cópia e a comparação.

```
dd if=<ORIGEM> of=<DESTINO> bs=<BLOCO> status=progress
```

| Parâmetro | Significado |
|---|---|
| `if=` | Entrada: a **mídia original** (na vida real: `/dev/sdc1`, atrás do write blocker) |
| `of=` | Saída: a **imagem** (ex.: `/mnt/usb/pendrive01.img`) |
| `bs=` | Tamanho do bloco lido/gravado por vez |
| `conv=noerror,sync` | Não para em setor defeituoso e completa com zeros |

> 🚨 **Trocar `if` e `of` grava por cima da evidência original.** É o erro mais grave da aula.

## 🧪 Passo a passo

```bash
cd /workspaces/*/labs/10-duplicacao-pericial
bash ../../scripts/criar_pendrive.sh saida/pendrive_suspeito.img
```

📌 A partir de agora, `saida/pendrive_suspeito.img` **é o pendrive original**. Ele não deve ser alterado.

**1. Hash da original**

```bash
sha256sum saida/pendrive_suspeito.img | tee saida/hash_original.txt
md5sum    saida/pendrive_suspeito.img | tee -a saida/hash_original.txt
```

**2. Cópia bit a bit (cópia de trabalho)**

```bash
dd if=saida/pendrive_suspeito.img of=saida/pendrive01.img bs=4M conv=noerror,sync status=progress
```

📌 `4+0 records` = 4 blocos **completos** de 4 MiB (16 MiB no total).

**3. Hash da cópia e comparação**

```bash
sha256sum saida/pendrive_suspeito.img saida/pendrive01.img
md5sum    saida/pendrive_suspeito.img saida/pendrive01.img
cmp saida/pendrive_suspeito.img saida/pendrive01.img && echo "IDENTICOS BYTE A BYTE"
```

**4. Segunda cópia (cópia de guarda), com hash calculado durante a cópia**

```bash
dd if=saida/pendrive_suspeito.img bs=4M status=progress | tee saida/pendrive01_guarda.img | sha256sum
```

**5. Prova: um único byte alterado**

```bash
cp saida/pendrive01.img saida/teste.img
printf X | dd of=saida/teste.img bs=1 seek=100 conv=notrunc
sha256sum saida/pendrive01.img saida/teste.img
cmp saida/pendrive01.img saida/teste.img
rm saida/teste.img
```

**6. `dcfldd`: o `dd` forense (SIFT Workstation), com hash e log automáticos**

```bash
dcfldd if=saida/pendrive_suspeito.img of=saida/pendrive02.img bs=4M hash=md5,sha256 hashlog=saida/hashlog.txt
cat saida/hashlog.txt
```

**7. Log da aquisição (anexo da cadeia de custódia)**

```bash
{ echo "Aquisicao - $(date -u '+%F %T UTC') - perito: $(whoami) - $(dd --version | head -n1)"
  echo "Tamanho: $(stat -c %s saida/pendrive01.img) bytes"
  sha256sum saida/pendrive_suspeito.img saida/pendrive01.img saida/pendrive01_guarda.img
} | tee saida/log_aquisicao.txt
```

## ❓ Perguntas
1. Os hashes da original e das cópias conferem? Cole a saída.
2. O que o `cmp` mostrou quando você alterou 1 byte?
3. Por que fazer **duas** cópias? Onde fica cada uma?
4. O que o `dcfldd` faz a mais que o `dd`?
5. Compare seu hash com o do colega. É igual? Por quê? *(Dica: o pendrive é criado com data/hora e número de série diferentes para cada aluno.)*
