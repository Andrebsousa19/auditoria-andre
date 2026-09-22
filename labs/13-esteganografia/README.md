# Atividade 13 – Esteganografia: mensagens escondidas em imagens

> **Professor Esp. Marcelino Dias da Silva Junior** · UNINOVE · Disciplina: **Auditoria Forense de Sistemas Digitais**
> **Aula relacionada:** Esteganografia

## 🎯 Objetivo
Esconder uma mensagem dentro de uma imagem (para entender a técnica) e depois **detectar e extrair** o conteúdo escondido numa imagem suspeita.

## 📚 Conceito em 1 minuto
- **Criptografia** esconde o **significado** da mensagem. A **esteganografia** esconde a **existência** dela.
- Uma técnica simples é **colar dados depois do fim da imagem**. O PNG termina no bloco **`IEND`**, e tudo o que vem depois é ignorado pelo visualizador, então a foto abre normalmente.
- **Esteganálise** é a detecção: tamanho anormal, hash diferente do original, bytes depois do marcador de fim.

## 🧪 Parte 1 – Escondendo (para entender)

```bash
cd /workspaces/*/labs/13-esteganografia
mkdir -p saida
echo "Mensagem secreta da turma: a prova e na quarta!" > saida/segredo.txt
cat amostra/logo_empresa.png saida/segredo.txt > saida/logo_com_segredo.png
```

Abra as duas imagens no explorador do Codespaces (clique no arquivo): **são idênticas à vista**. Agora compare:

```bash
ls -l amostra/logo_empresa.png saida/logo_com_segredo.png
sha256sum amostra/logo_empresa.png saida/logo_com_segredo.png
file saida/logo_com_segredo.png
tail -c 60 saida/logo_com_segredo.png
```

📌 O `file` continua dizendo "PNG image". Só o **tamanho**, o **hash** e o **final do arquivo** denunciam a mensagem.

## 🧪 Parte 2 – Esteganálise: a foto do evento

O suspeito postou uma "foto do evento" na rede social da empresa. Analise-a:

```bash
bash preparar.sh
file saida/foto_evento.png
ls -l saida/foto_evento.png amostra/logo_empresa.png
```

**1. Onde a imagem deveria terminar?** Procure o marcador `IEND`:

```bash
grep -a -b -o "IEND" saida/foto_evento.png
```

📌 O PNG termina **8 bytes depois** do início de `IEND` (4 bytes do nome + 4 de verificação). Calcule quantos bytes sobram:

```bash
POS=$(grep -a -b -o "IEND" saida/foto_evento.png | tail -n 1 | cut -d: -f1)
FIM=$((POS + 8))
TAM=$(stat -c %s saida/foto_evento.png)
echo "A imagem termina no byte $FIM, mas o arquivo tem $TAM bytes: sobram $((TAM - FIM)) bytes escondidos"
```

**2. Que tipo de dado está escondido?**

```bash
tail -c +$((FIM + 1)) saida/foto_evento.png > saida/escondido.bin
file saida/escondido.bin
xxd -l 16 saida/escondido.bin
```

📌 `50 4b 03 04` = **`PK`**: é um arquivo **ZIP** (lembra da Atividade 03?).

**3. Extraia e leia o conteúdo**

```bash
unzip -l saida/escondido.bin
unzip -o -d saida/extraido saida/escondido.bin
cat saida/extraido/instrucoes.txt
```

> 💡 Atalho: o `unzip` sabe procurar o ZIP dentro de outro arquivo. Tente `unzip -l saida/foto_evento.png`.

**4. Registre as evidências**

```bash
sha256sum saida/foto_evento.png saida/escondido.bin saida/extraido/instrucoes.txt | tee saida/hashes.txt
```

## ❓ Perguntas
1. Qual a diferença entre criptografia e esteganografia?
2. Por que a imagem com a mensagem escondida abre normalmente?
3. Quais três sinais denunciaram a esteganografia na Parte 1?
4. O que estava escondido na foto do evento? Qual a relevância para o caso?
5. Existem técnicas que **não** mudam o tamanho do arquivo (ex.: alterar os bits menos significativos dos pixels, *LSB*). Como o perito poderia detectá-las?
