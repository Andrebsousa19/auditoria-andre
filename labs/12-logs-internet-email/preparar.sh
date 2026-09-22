#!/usr/bin/env bash
# Gera as evidencias da estacao FIN-014: log de autenticacao, historico do navegador,
# um e-mail suspeito e um arquivo de paginacao (pagefile)
set -e
cd "$(dirname "$0")"
rm -rf saida && mkdir -p saida/evidencias && cd saida/evidencias

# 1) Log de autenticacao (formato syslog)
{
  for i in $(seq 10 49); do
    echo "Aug 14 21:$i:0$((i % 10)) fin-014 sshd[21$i]: Failed password for ana.souza from 203.0.113.45 port 5$i ssh2"
  done
  for u in admin root teste; do
    echo "Aug 14 21:50:1$((RANDOM % 10)) fin-014 sshd[2201]: Failed password for invalid user $u from 198.51.100.7 port 40022 ssh2"
  done
  echo "Aug 14 21:58:02 fin-014 sshd[2210]: Accepted password for ana.souza from 203.0.113.45 port 51000 ssh2"
  echo "Aug 14 22:41:30 fin-014 sshd[2210]: Disconnected from user ana.souza 203.0.113.45 port 51000"
  echo "Aug 15 08:02:11 fin-014 sshd[3001]: Accepted password for ana.souza from 192.168.10.25 port 50110 ssh2"
} > auth.log

# 2) Historico do navegador (esquema simplificado do Chrome: tempo em microssegundos desde 1601)
sqlite3 History.sqlite <<'SQL'
CREATE TABLE urls(id INTEGER PRIMARY KEY, url TEXT, title TEXT, visit_count INTEGER, last_visit_time INTEGER);
INSERT INTO urls(url,title,visit_count,last_visit_time) VALUES
 ('https://intranet.empresa-exemplo.local/pagamentos','Sistema de Pagamentos',42,13431230220000000),
 ('https://www.google.com/search?q=como+apagar+arquivo+sem+deixar+rastro','como apagar arquivo sem deixar rastro - Pesquisa',1,13431231480000000),
 ('https://banco.exemplo.invalid/ted','Banco - Transferencia TED',3,13431231000000000),
 ('https://webmail.exemplo.invalid/','Webmail',15,13431228300000000),
 ('https://noticias.exemplo.invalid/esportes','Esportes',8,13431106800000000);
SQL

# 3) E-mail suspeito (.eml) com remetente falsificado (spoofing)
cat > mensagem_suspeita.eml <<'MAIL'
Return-Path: <cobranca@fornecedora-alfa.exemplo.invalid>
Received: from mail.empresa-exemplo.local (mail.empresa-exemplo.local [192.168.10.5])
	by mx.empresa-exemplo.local with ESMTP id 7F3A1; Fri, 14 Aug 2026 21:40:12 -0300
Received: from smtp.hospedagem-barata.exemplo.invalid ([203.0.113.45])
	by mail.empresa-exemplo.local with ESMTP id 55C2E; Fri, 14 Aug 2026 21:40:10 -0300
From: "Diretor Financeiro" <diretor.financeiro@empresa-exemplo.local>
Reply-To: <pagamentos.urgente@exemplo.invalid>
To: ana.souza@empresa-exemplo.local
Subject: URGENTE - liberar pagamento Fornecedora Alfa hoje
Date: Fri, 14 Aug 2026 21:40:05 -0300
Message-ID: <20260814214005.99@smtp.hospedagem-barata.exemplo.invalid>

Ana, libere hoje o pagamento de R$ 180.000,00 para a Fornecedora Alfa.
Nao comente com ninguem. Responda so para este endereco.
MAIL

# 4) Arquivo de paginacao (pagefile.sys) com restos de memoria
{ head -c 300000 /dev/urandom
  printf 'usuario=ana.souza;senha_bancaria=Alfa@2026;'
  head -c 200000 /dev/urandom
  printf 'Rede Wireless conectada: SSID=CAFE_GRATIS_WIFI'
  head -c 200000 /dev/urandom
  printf 'https://banco.exemplo.invalid/ted?valor=180000'
  head -c 300000 /dev/urandom; } > pagefile.sys
echo "Evidencias prontas em saida/evidencias/"
