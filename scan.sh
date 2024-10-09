#!/bin/bash

echo "Saisie un ip pour un scan rapide:"
read ip

if [ "$1"="rapide" ];then
    echo "Lancement d'un scan rapide sur les hôtes :$ip"
    nmap -F $ip
fi

