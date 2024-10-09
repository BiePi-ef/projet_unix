#!/bin/bash

if [ "$1"="personalise" ];then
    echo "quel l'ip de/s hote a analyser ?";
    read idHote;

    echo "Entrez le(s) numero(s) de port(s) a scanner.
    - Pour le scan d'un seul port entrez son adresse
    - Pour le scan de plusieurs ports entrez les separe par des virgules (ex: 1,2)
    - Pour une plage separez les ports de debut et de fin (compris) par des tirets (ex: 1-5)";
    read ports

    nmap $idHote -p $ports
fi