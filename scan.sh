#!/bin/bash

echo " Saisir une adresse ip :"
read ip

if [ "$1"="Complet" ];then
    echo "Lancement du scan complet : $ip" 
    nmap -F $ip
fi


