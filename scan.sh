#!/bin/bash

echo " Saisir une adresse ip :"
read ip

if [ $a -eq 1 ];then
    echo "Saisie un ip pour un scan rapide:"
    read ip
    echo "Lancement d'un scan rapide sur les hôtes :$ip"
    nmap -F $ip
fi


