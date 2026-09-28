# Atividade 01 – Planejamento e execução da auditoria: auditoria de controles

> **Professor Esp. Marcelino Dias da Silva Junior** · UNINOVE · Disciplina: **Auditoria Forense de Sistemas Digitais**
> **Aula relacionada:** Planejamento e execução da auditoria (reforça: Introdução à auditoria, Relatórios preliminares)

## 🎯 Objetivo
Executar uma auditoria simples: comparar a configuração de um servidor com **critérios** definidos no planejamento e registrar cada **evidência** num papel de trabalho.

## 📚 Conceito em 1 minuto
- **Planejamento:** antes de começar, a auditoria define **objetivo, escopo e critérios**.
- **Execução:** o auditor coleta **evidências** que mostram se cada critério foi cumprido.
- **Não conformidade (NC):** critério não atendido, descrita de forma **clara, firme e objetiva** (fato, critério e efeito).

**Escopo desta auditoria:** servidor **FIN-SRV01** (setor financeiro), usando uma **cópia** das configurações.

| Critério | Regra (política da empresa) |
|---|---|
| C1 | Somente a conta `root` pode ter UID 0 (privilégio máximo) |
| C2 | Nenhuma conta pode ficar sem senha |
| C3 | Arquivos do financeiro não podem ter permissão de escrita para "outros" |
| C4 | Contas de funcionários desligados devem ser removidas |

## 🧪 Passo a passo

```bash
cd /workspaces/*/bslabs/01-auditoria-de-controles
bash preparar.sh
tree saida/servidor
```

**C1: contas com UID 0.** O 3º campo do `passwd` é o UID:

```bash
awk -F: '$3 == 0 {print $1, "-> UID", $3}' saida/servidor/etc/passwd
```

**C2: contas sem senha.** No `shadow`, o 2º campo vazio significa conta sem senha:

```bash
awk -F: '$2 == "" {print "SEM SENHA:", $1}' saida/servidor/etc/shadow
```

**C3: arquivos com escrita para "outros".**

```bash
ls -l saida/servidor/financeiro/
find saida/servidor/financeiro -type f -perm -o+w
```

**C4: contas de funcionários desligados.** Leia a descrição (5º campo):

```bash
cut -d: -f1,5 saida/servidor/etc/passwd
grep -i "desligad" saida/servidor/etc/passwd
```

**Guarde as evidências com hash**, para que ninguém possa dizer que foram alteradas depois:

```bash
{ echo "Auditoria FIN-SRV01 - $(date -u '+%Y-%m-%d %H:%M UTC') - auditor: $(whoami)"
  awk -F: '$3 == 0' saida/servidor/etc/passwd
  awk -F: '$2 == ""' saida/servidor/etc/shadow
  find saida/servidor/financeiro -type f -perm -o+w
  grep -i "desligad" saida/servidor/etc/passwd
} > saida/evidencias_auditoria.txt
sha256sum saida/evidencias_auditoria.txt | tee saida/evidencias_auditoria.sha256
```

## 📝 Papel de trabalho (preencha)

| Critério | Evidência (comando + resultado) | Conforme? | NC |
|---|---|---|---|
| C1 | `awk -F: '$3 == 0 {print $1, "-> UID", $3}' saida/servidor/etc/passwd` → `root -> UID 0`; `suporte -> UID 0` | Não | NC-01 |
| C2 | `awk -F: '$2 == "" {print "SEM SENHA:", $1}' saida/servidor/etc/shadow` → `SEM SENHA: suporte` | Não | NC-01 |
| C3 | `find saida/servidor/financeiro -type f -perm -o+w` → `saida/servidor/financeiro/pagamentos.csv` | Não | NC-02 |
| C4 | `grep -i "desligad" saida/servidor/etc/passwd` → `estagiario2024` consta como desligado em 2024 | Não | NC-03 |

## ❓ Perguntas
1. A conta `suporte` viola dois critérios: C1, porque possui UID 0, e C2, porque está sem senha. O risco é permitir acesso não autenticado com privilégio máximo, possibilitando o comprometimento total do servidor.
2. **NC-01:** Foi identificada a conta `suporte` com UID 0 e campo de senha vazio. Isso descumpre C1, que reserva o UID 0 exclusivamente à conta `root`, e C2, que proíbe contas sem senha. Essa situação pode permitir acesso não autenticado com privilégio máximo, comprometendo a confidencialidade, a integridade e a disponibilidade dos dados.
3. A auditoria foi realizada em uma cópia para preservar o servidor e as configurações originais, evitar alterações ou interrupções no ambiente de produção e permitir a repetição dos testes. Dessa forma, as evidências originais permanecem íntegras.
4. **NC-01:** retirar o UID 0 da conta `suporte`, conceder somente os privilégios necessários e configurar uma autenticação forte ou bloquear a conta até sua regularização. **NC-02:** remover a permissão de escrita para “outros” de `pagamentos.csv` e restringir o acesso aos usuários ou grupos autorizados. **NC-03:** desativar e remover a conta `estagiario2024`, revogar suas credenciais e preservar ou transferir seus arquivos antes da remoção, conforme a política da empresa.
