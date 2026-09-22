# Atividade 07 – Análise ao vivo de processos

> **Professor Esp. Marcelino Dias da Silva Junior** · UNINOVE · Disciplina: **Auditoria Forense de Sistemas Digitais**
> **Aula relacionada:** Análise ao vivo de processos (reforça: Ordem de volatilidade, Cadeia de custódia e MACTimes)

## 🎯 Objetivo
Encontrar um processo suspeito numa máquina **ligada**, identificar o executável e os arquivos abertos por ele e **recuperar** um executável que já foi apagado do disco.

## 📚 Conceito em 1 minuto
- **Processo:** um programa em execução. Tem **PID** (identificador) e **PPID** (processo pai).
- No Linux, cada processo tem uma pasta **`/proc/<PID>/`** com o executável (`exe`), a linha de comando (`cmdline`), a pasta de trabalho (`cwd`) e os arquivos abertos (`fd/`).
- Um arquivo **apagado** que ainda está **aberto** por um processo continua acessível até o processo terminar. Por isso a análise viva vem **antes** de desligar a máquina.

## 🧪 Passo a passo

```bash
cd /workspaces/*/labs/07-analise-viva-de-processos
mkdir -p saida
bash iniciar_suspeito.sh
```

**1. Liste os processos.** Algum nome parece estranho?

```bash
ps -eo pid,ppid,user,etime,cmd --sort=start_time | tail -n 15
```

Veja a árvore de processos (quem é pai de quem) e o `top` em modo texto:

```bash
pstree -p | head -n 20
top -b -n 1 | head -n 15
```

**2. Guarde o PID do suspeito**

```bash
PID=$(pgrep -f kworker-upd)
echo "PID suspeito: $PID"
```

**3. Investigue o processo pelo `/proc`**

```bash
ls -l /proc/$PID/exe
tr '\0' ' ' < /proc/$PID/cmdline; echo
ls -l /proc/$PID/cwd
ls -l /proc/$PID/fd
```

📌 O `exe` e um arquivo aberto em `fd` aparecem como **`(deleted)`**: o suspeito apagou os arquivos, mas eles continuam na memória.

Liste os arquivos abertos com o `lsof`:

```bash
lsof -p $PID
```

**4. Recupere o executável e o arquivo apagados**

```bash
cp /proc/$PID/exe saida/executavel_recuperado
FD=$(ls -l /proc/$PID/fd | grep keylog | awk '{print $9}')
cat /proc/$PID/fd/$FD | tee saida/keylog_recuperado.txt
```

Descubra o que é o executável, comparando o hash com os programas do sistema:

```bash
sha256sum saida/executavel_recuperado
sha256sum /usr/bin/* 2>/dev/null | grep "$(sha256sum saida/executavel_recuperado | cut -d' ' -f1)"
file saida/executavel_recuperado
```

Ele também abriu uma **porta de rede**. Veja qual:

```bash
ss -tlnp | grep kworker
```

**5. Registre as evidências e só então encerre o processo**

```bash
sha256sum saida/executavel_recuperado saida/keylog_recuperado.txt | tee saida/hashes.txt
kill $PID
ls /proc/$PID 2>/dev/null || echo "Processo encerrado: /proc/$PID nao existe mais"
```

## ❓ Perguntas
1. Que nome o processo suspeito usava? Por que esse nome foi escolhido?
2. De qual pasta ele rodava? O que há de suspeito nessa pasta?
3. Como você recuperou um executável que já tinha sido **apagado** do disco?
4. O que o hash revelou sobre o "programa desconhecido"? Que porta ele abriu?
5. Por que o `kill` só foi feito depois de salvar tudo? O que teria sido perdido se a máquina fosse desligada antes?
