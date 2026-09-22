# Atividade 05 – Algoritmos criptográficos: hash, cifra e assinatura digital

> **Professor Esp. Marcelino Dias da Silva Junior** · UNINOVE · Disciplina: **Auditoria Forense de Sistemas Digitais**
> **Aula relacionada:** Uso de algoritmos criptográficos para armazenamento seguro de evidências

## 🎯 Objetivo
Usar os três recursos criptográficos que protegem uma evidência:

| Pilar | Recurso | Nesta atividade |
|---|---|---|
| **Integridade** | Função hash | Partes 1 e 2 |
| **Confidencialidade** | Criptografia simétrica (AES) | Parte 3 |
| **Autenticidade + integridade** | Assinatura digital (RSA + hash) | Parte 4 |

## 📚 Conceito em 1 minuto
- **Hash:** entrada de qualquer tamanho produz uma saída de **tamanho fixo**. Mudar 1 bit muda o hash inteiro (**efeito avalanche**).

| Algoritmo | Bits | Caracteres hex | Situação |
|---|---|---|---|
| MD5 | 128 | 32 | Colisões conhecidas: usar só como complemento |
| SHA-1 | 160 | 40 | Colisões conhecidas |
| SHA-256 | 256 | 64 | Recomendado |
| SHA-512 | 512 | 128 | Recomendado |

- **Simétrica:** **uma** chave cifra e decifra (DES, 3DES, **AES**).
- **Assimétrica:** **par** de chaves, uma privada e uma pública (**RSA**, DSS).
- **Assinatura digital:** o hash dá a integridade e a chave privada dá a autenticidade.

## 🧪 Parte 1 – Hash e efeito avalanche

```bash
cd /workspaces/*/labs/05-algoritmos-criptograficos
mkdir -p saida
echo -n "Pagamento fornecedor R$ 48.300,00" | md5sum
echo -n "Pagamento fornecedor R$ 48.300,00" | sha1sum
echo -n "Pagamento fornecedor R$ 48.300,00" | sha256sum
echo -n "Pagamento fornecedor R$ 48.300,00" | sha512sum
```

Troque **um dígito** e compare:

```bash
echo -n "Pagamento fornecedor R$ 48.300,00" | sha256sum
echo -n "Pagamento fornecedor R$ 48.301,00" | sha256sum
```

O hash vê o **conteúdo**, não o nome do arquivo:

```bash
cp evidencias/ata_reuniao.txt saida/outro_nome_qualquer.txt
sha256sum evidencias/ata_reuniao.txt saida/outro_nome_qualquer.txt
```

## 🧪 Parte 2 – Integridade das evidências coletadas

Na coleta, a auditoria gerou um **manifesto** com o hash de cada documento. Confira:

```bash
cat evidencias/SHA256SUMS
cd evidencias && sha256sum -c SHA256SUMS; md5sum -c MD5SUMS; cd ..
```

📌 **Uma evidência foi adulterada depois da coleta.** Qual?

🏆 **Desafio:** um documento vazou na internet com este SHA-256. Qual arquivo é?

```
1e580f65ab34bfde28004f8676aaea0cef90dc4f07e01ab84dd1de3aed787250
```

<details><summary>💡 Dica</summary>

```bash
sha256sum evidencias/* | grep 1e580f65
```
</details>

## 🧪 Parte 3 – Confidencialidade: cifrando o pacote de evidências (AES-256)

Empacote e cifre as evidências. A senha é **uma chave simétrica**: a mesma que cifra também decifra.

```bash
tar czf saida/pacote_evidencias.tar.gz evidencias/
openssl enc -aes-256-cbc -pbkdf2 -salt -in saida/pacote_evidencias.tar.gz -out saida/pacote_evidencias.enc -pass pass:Uninove2026
file saida/pacote_evidencias.tar.gz saida/pacote_evidencias.enc
```

> ⚠️ Em aula a senha fica no comando para facilitar. Na vida real, omita `-pass` e o `openssl` pedirá a senha sem exibi-la.

Tente decifrar com a senha **errada** e depois com a **certa**:

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -in saida/pacote_evidencias.enc -out saida/decifrado.tar.gz -pass pass:senhaerrada
openssl enc -d -aes-256-cbc -pbkdf2 -in saida/pacote_evidencias.enc -out saida/decifrado.tar.gz -pass pass:Uninove2026
sha256sum saida/pacote_evidencias.tar.gz saida/decifrado.tar.gz
```

## 🧪 Parte 4 – Autenticidade: assinando o laudo (RSA)

Gere o **par de chaves** do perito:

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out saida/perito_privada.pem
openssl pkey -in saida/perito_privada.pem -pubout -out saida/perito_publica.pem
cat saida/perito_publica.pem
```

Escreva o laudo e **assine** com a chave **privada**:

```bash
echo "LAUDO: o documento relatorio_financeiro.csv foi adulterado apos a coleta. Perito: $(whoami)" > saida/laudo.txt
openssl dgst -sha256 -sign saida/perito_privada.pem -out saida/laudo.sig saida/laudo.txt
```

Qualquer pessoa **verifica** com a chave **pública**:

```bash
openssl dgst -sha256 -verify saida/perito_publica.pem -signature saida/laudo.sig saida/laudo.txt
```

Agora adultere o laudo e verifique de novo:

```bash
sed -i 's/foi adulterado/NAO foi adulterado/' saida/laudo.txt
openssl dgst -sha256 -verify saida/perito_publica.pem -signature saida/laudo.sig saida/laudo.txt
```

📌 `Verified OK` antes e `Verification failure` depois: a assinatura prova **quem** assinou e que o texto **não mudou**.

## ❓ Perguntas
1. Quantos caracteres tem cada hash? Quantos bits isso representa?
2. Qual evidência foi adulterada e qual documento vazou? Mostre os comandos.
3. Por que a criptografia simétrica precisa de um **canal seguro** para entregar a senha?
4. Na assinatura, qual chave o perito guarda em segredo e qual ele divulga? Por quê?
5. O hash sozinho garante **autenticidade**? Explique usando a Parte 4.
