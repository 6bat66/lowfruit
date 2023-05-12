#!/bin/bash

mkdir $1
cd $1

if [ "$2" == "" ]
then
    #------------------------- Usei meu outro script para enumeranção de subdominios ----------------------------------#
    amass enum --passive -d $1 -o domains_$1
    assetfinder --subs-only $1 | tee -a domains_$1

    subfinder -d $1 -silent -o domains_subfinder_$1
    cat domains_subfinder_$1 | tee -a domains_$1

    sort -u domains_$1 -o domains_$1
    cat domains_$1 | filter-resolved | tee -a domains_$1.txt

    rm domains_$1
    rm domains_subfinder_$1
    #------------------------- Usei meu outro script para enumeranção de subdominios ----------------------------------#

    # Procurar URLs com base na internet
    cat domains_$1.txt | gau --threads 5 --subs | httpx -silent | sort | tee allUrls.txt
    
    # Scaner de vuln
    nuclei -l domains_$1.txt -silent -o nuclei.txt

    # Encontrar todos os parametros especificos
    mkdir parametros
    cat allUrls.txt | gf debug_logic | tee parametros/debug_logic
    cat allUrls.txt | gf img-traversal | tee parametros/img-traversal
    cat allUrls.txt | gf interestingparams | tee parametros/interestingparams
    cat allUrls.txt | gf jsvar | tee parametros/jsvar
    cat allUrls.txt | gf sqli | tee parametros/sqli
    cat allUrls.txt | gf ssti | tee parametros/ssti
    cat allUrls.txt | gf idor | tee parametros/idor
    cat allUrls.txt | gf interestingEXT | tee parametros/interestingEXT
    cat allUrls.txt | gf interestingsubs | tee parametros/interestingsubs
    cat allUrls.txt | gf lfi | tee parametros/lfi
    cat allUrls.txt | gf rce | tee parametros/rce
    cat allUrls.txt | gf redirect | tee parametros/redirect
    cat allUrls.txt | gf ssrf | tee parametros/ssrf
    cat allUrls.txt | gf xss | tee parametros/xss
    # Encontrar paginas que não temos acesso
    cat allUrls.txt | httpx --silent -sc -nc | grep "403\|401" | tee parametros/bypass
    # Encontrar paineis administrativos
    cat allUrls.txt | httpx --silent -title | grep "admin\|login\|dashboard" | tee loginpanel.txt

    # Encontrar parametros refletidos
    #cat parametros/xss | kxss | cut -d " " -f 2 | tee xsstest

    # Validar Path Transversal
    #httpx --silent -l allUrls.txt -path "///////../../../../../../etc/passwd" -status-code -mc 200 -ms 'root:' | tee pathTraversal.txt

    # Subdomain takeonver
    #subzy run --targets domains_$1.txt --https | tee subzy.txt

    # Encontrar extensões
    #mkdir ext
    #cat allUrls.txt | grep -i "\.log$" | tee ext/log.txt
    #cat allUrls.txt | grep -i "\.bak$" | tee ext/bak.txt
    #cat allUrls.txt | grep -i "\.xlsx$" | tee ext/xlsx.txt
    #cat allUrls.txt | grep -i "\.js$" | tee ext/jsfiles.txt
    
    echo ""
    echo "Enumeração concluida"

else
    echo "MODO DE USO"
    echo "./lowfruit.sh <dominio> <arquivo de sudominios>"
    echo "Obs: Caso não tenha o arquivo de subdominios o script fara a enumeração sozinho"
    echo ""
fi
