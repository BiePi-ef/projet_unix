#!/bin/bash

echo $1 $2 $3 $4

if [ "$1" = "rapide" ];then
    echo "Lancement d'un scan rapide sur le/s hôte/s :$2"
    nmap -F $2

elif [ "$1" = "complet" ]; then
    echo "lancement scan complet sur le/s hoste/s : $2"
    echo "Ce scan peut prendre du temps..."
    nmap -p- -sU -sT $2

elif [ "$1" = "perso" ];then
		echo "lancement d'un scan sur le/s hoste/s : $1, avec le/s port/s : 
    $3"
    nmap $2 -p $3
fi
