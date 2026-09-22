# 🔍 Laboratórios de Auditoria Forense de Sistemas Digitais

**UNINOVE · Disciplina: Auditoria Forense de Sistemas Digitais**
**Professor Esp. Marcelino Dias da Silva Junior**

Atividades práticas curtas, que rodam direto no navegador pelo **GitHub Codespaces** (funciona no Chromebook). Todas as ferramentas já vêm **instaladas no ambiente**.

> ⚖️ Todos os casos, empresas, pessoas, contas, IPs e domínios são **fictícios** e servem apenas para fins didáticos. IPs e domínios usam faixas reservadas para documentação (`203.0.113.x`, `198.51.100.x`, `.invalid`).

---

## 📋 Atividades

| Atividade | Tema | Aula relacionada |
|---|---|---|
| [01](labs/01-auditoria-de-controles/) | Auditoria de controles e papel de trabalho | Planejamento e execução da auditoria |
| [02](labs/02-esterilizacao-de-midia/) | Esterilização de mídia (wipe) e contaminação cruzada | Equipamentos utilizados para obtenção e armazenamento de evidências |
| [03](labs/03-evidencias-logicas/) | Assinatura de arquivos, entropia e palavras-chave | Tratamento de evidências lógicas |
| [04](labs/04-coleta-de-dados-volateis/) | Coleta de dados voláteis | Norma Internacional: RFC 3227 · Ordem de volatilidade |
| [05](labs/05-algoritmos-criptograficos/) | Hash, cifra AES e assinatura digital | Uso de algoritmos criptográficos para armazenamento seguro de evidências |
| [06](labs/06-cadeia-de-custodia-mactimes/) | Linha do tempo com MACtimes e registro de custódia | Cadeia de custódia e análise de MACTimes |
| [07](labs/07-analise-viva-de-processos/) | Processo disfarçado e recuperação pelo `/proc` | Análise ao vivo de processos |
| [08](labs/08-analise-de-malware/) | Triagem estática de amostra didática e IOCs | Análise de malwares |
| [09](labs/09-ferramentas-sleuth-kit/) | The Sleuth Kit: `fls`, `icat`, `mactime` | Ferramentas utilizadas durante uma análise forense computacional |
| [10](labs/10-duplicacao-pericial/) | Cópia bit a bit com `dd` e `dcfldd` | Análise por meio de duplicação pericial |
| [11](labs/11-sistema-de-arquivos-fat/) | FAT16 em hexadecimal e arquivo apagado (`0xE5`) | Análise de sistemas de arquivos |
| [12](labs/12-logs-internet-email/) | Pagefile, logs, histórico do navegador e cabeçalho de e-mail | Análise de hibernação, swap e paginação; LOGs, internet e correio eletrônico |
| [13](labs/13-esteganografia/) | Dados escondidos em imagem | Esteganografia |

Cada atividade leva entre **20 e 40 minutos** e é independente das outras.

---

## 🚀 Como começar

### 1. Crie a sua cópia do repositório
Você precisa de uma conta gratuita no [GitHub](https://github.com). Com o e-mail institucional, você pode pedir o [GitHub Education](https://education.github.com/), que aumenta a cota gratuita de horas.

Nesta página, clique em **`Use this template` → `Create a new repository`**, dê um nome e crie. Se o botão não aparecer, use **`Fork`**.

### 2. Abra o Codespace
No **seu** repositório: **`<> Code` → aba `Codespaces` → `Create codespace on main`**.

Na **primeira vez**, o ambiente é montado com todas as ferramentas (leva de 2 a 4 minutos). Ao final, o terminal mostra a lista de ferramentas com `[OK]`. Para conferir de novo:

```bash
bash scripts/verificar_ambiente.sh
```

### 3. Faça a atividade
Abra o `README.md` da atividade (pasta `labs/`) e siga os comandos **no terminal** (menu **☰ → Terminal → New Terminal**). Para colar no terminal do navegador, use **Ctrl+Shift+V**.

> 📁 Tudo o que você gerar fica na pasta `saida/` de cada atividade. Ela **não** vai para o git. Para entregar, clique com o botão direito no arquivo → **Download**.

### 4. Ao terminar
Pare o Codespace para não gastar sua cota: **`<> Code` → Codespaces → `...` → Stop codespace**.

---

## 📝 Entregas
- [Modelo de relatório](docs/modelo_relatorio.md): estrutura vista em aula (introdução e escopo, metodologia, critérios, evidências, não conformidades, limitações, conclusão e recomendações).
- [Formulário de cadeia de custódia](docs/cadeia_de_custodia.md).

Responda as perguntas de cada atividade **colando as saídas do terminal**: em perícia, afirmação sem evidência não vale.

---

## 🛡️ Regras de ouro do perito
1. **Nunca trabalhe na evidência original.** Trabalhe sempre na cópia.
2. **Hash antes e depois** de qualquer manuseio.
3. **Documente tudo**: quem, quando (em UTC), o quê, como e por quê.
4. **Nunca execute** uma amostra suspeita fora de um ambiente controlado.
5. Use estas técnicas **somente** em ambientes e evidências para os quais você tem **autorização**.

---

<sub>Para o professor: o ambiente é definido em `.devcontainer/` (Dockerfile com as ferramentas pré-instaladas). O script `scripts/criar_pendrive.sh` gera o pendrive suspeito usado nas atividades 09, 10 e 11.</sub>
