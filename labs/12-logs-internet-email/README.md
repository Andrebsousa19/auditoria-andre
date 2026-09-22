# Atividade 12 – Swap e paginação, LOGs, internet e correio eletrônico

> **Professor Esp. Marcelino Dias da Silva Junior** · UNINOVE · Disciplina: **Auditoria Forense de Sistemas Digitais**
> **Aula relacionada:** Análise dos arquivos de hibernação, swap e paginação. Análise de LOGs, recursos de internet e correios eletrônicos

## 🎯 Objetivo
Correlacionar quatro fontes de evidência da estação **FIN-014** na noite do incidente: **arquivo de paginação**, **log de autenticação**, **histórico do navegador** e **cabeçalho de e-mail**.

## 📚 Conceito em 1 minuto
- **Swap/paginação (`pagefile.sys`, `hiberfil.sys`):** pedaços da RAM gravados em disco. Podem guardar **senhas, URLs e textos** que nunca foram salvos em arquivo.
- **Logs:** trilhas de auditoria do sistema (no Linux, o **syslog**). Devem ser guardados **fora** da máquina atacada.
- **Histórico de internet:** o navegador guarda URLs e horários num banco **SQLite**.
- **Cabeçalho de e-mail:** o campo `From` pode ser **falsificado** (*spoofing*). As linhas `Received` são adicionadas por cada servidor e se leem **de baixo para cima**.

## 🧪 Passo a passo

```bash
cd /workspaces/*/labs/12-logs-internet-email
bash preparar.sh
ls -lh saida/evidencias/
sha256sum saida/evidencias/* | tee saida/hashes.txt
```

### Parte 1 – Arquivo de paginação

```bash
strings -n 8 saida/evidencias/pagefile.sys | grep -i -E "senha|wireless|https?://"
grep -a -b -o "senha_bancaria=[^;]*" saida/evidencias/pagefile.sys
```

📌 A senha nunca foi salva em arquivo, mas ficou nos **restos de memória** gravados em disco.

### Parte 2 – Log de autenticação

```bash
head -n 5 saida/evidencias/auth.log
grep -c "Failed password" saida/evidencias/auth.log
```

Tentativas que falharam, **por IP de origem**:

```bash
grep "Failed password" saida/evidencias/auth.log | grep -o -E 'from [0-9.]+' | sort | uniq -c | sort -rn
```

Logins que deram certo:

```bash
grep "Accepted" saida/evidencias/auth.log
```

📌 Depois de **40 tentativas** do IP `203.0.113.45`, veio um login **aceito** às **21:58**. Como isso se chama?

### Parte 3 – Histórico do navegador (SQLite)

```bash
sqlite3 -header -column saida/evidencias/History.sqlite \
  "SELECT datetime(last_visit_time/1000000 - 11644473600, 'unixepoch', '-3 hours') AS horario_brasilia, title, url
   FROM urls ORDER BY last_visit_time;"
```

> O Chrome grava o tempo em **microssegundos desde 01/01/1601**. A conta converte para data normal, e o `-3 hours` ajusta para o horário de Brasília.

### Parte 4 – Cabeçalho do e-mail

```bash
cat saida/evidencias/mensagem_suspeita.eml
grep -E "^(From|Reply-To|Return-Path):" saida/evidencias/mensagem_suspeita.eml
grep -A1 "^Received:" saida/evidencias/mensagem_suspeita.eml
```

📌 O `From` diz que o e-mail veio do **Diretor Financeiro**, mas o primeiro `Received` (o de baixo) mostra que ele saiu de **`203.0.113.45`**, o **mesmo IP** do ataque de força bruta.

### Parte 5 – Linha do tempo correlacionada

Monte a sequência da noite de 14/08 juntando as quatro fontes:

| Horário | Fonte | Evento |
|---|---|---|
| 21:10–21:49 | auth.log | |
| 21:40 | e-mail | |
| 21:58 | auth.log | |
| | histórico | |
| | pagefile | |

## ❓ Perguntas
1. Que informação sensível foi encontrada no `pagefile.sys`? Por que ela estava lá?
2. Qual IP fez o ataque de força bruta? O ataque teve sucesso? Quando?
3. Qual pesquisa no navegador reforça a suspeita? Em que horário?
4. Por que o `From` do e-mail não prova quem enviou? Que campo mostra a origem real?
5. Por que os logs deveriam estar guardados num servidor **separado** da estação FIN-014?
