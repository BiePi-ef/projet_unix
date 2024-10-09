#!/bin/bash

echo "Quel est l'operation que vous voulez realiser ?
- 1 : rapide
- 2 : complet
- 3 : personalise"
read a;

if [ $a -eq 1 ];then
    echo "Saisie un ip pour un scan rapide:"
    read ip
    echo "Lancement d'un scan rapide sur les hôtes :$ip"
    nmap -F $ip

elif [ $a -eq 3 ];then
    echo "quel l'ip de/s hote a analyser ?";
    read idHote;

    echo "Entrez le(s) numero(s) de port(s) a scanner.
    - Pour le scan d'un seul port entrez son adresse
    - Pour le scan de plusieurs ports entrez les separe par des virgules (ex: 1,2)
    - Pour une plage separez les ports de debut et de fin (compris) par des tirets (ex: 1-5)";
    read ports

    nmap $idHote -p $ports
fi