#!/bin/bash

# Initialisation des variables par défaut
scanType=""
ip=""
ports=""
osScan="n"
cronMode="n"

# Parse des arguments passés en ligne de commande
while [[ $# -gt 0 ]]; do
    case $1 in
        --type) scanType="$2"; shift 2 ;;
        --ip) ip="$2"; shift 2 ;;
        --ports) ports="$2"; shift 2 ;;
        --osScan) osScan="$2"; shift 2 ;;
        --cron) cronMode="y"; shift ;;
        *) echo "Option inconnue : $1"; exit 1 ;;
    esac
done

# Vérification des paramètres requis
if [[ -z "$scanType" || -z "$ip" ]]; then
    echo "Usage : $0 --type <1|2|3> --ip <adresse_ip> [--ports <ports>] [--osScan <y|n>] [--cron]"
    exit 1
fi

# Préparer les options pour Nmap
options=""
if [ "$osScan" = "y" ]; then
    options="$options -A"
fi

# Exécution selon le type de scan
if [ "$scanType" -eq 1 ]; then
    echo "Lancement d'un scan rapide sur $ip..."
    nmap -F $options "$ip"

elif [ "$scanType" -eq 2 ]; then
    echo "Lancement d'un scan complet sur $ip..."
    nmap -p- -sT -sU $options "$ip"

elif [ "$scanType" -eq 3 ]; then
    if [ -z "$ports" ]; then
        echo "Erreur : Vous devez spécifier les ports pour un scan personnalisé (--ports)."
        exit 1
    fi
    echo "Lancement d'un scan personnalisé sur $ip pour les ports $ports..."
    nmap -p "$ports" $options "$ip"

else
    echo "Option de type invalide. Choisissez 1, 2 ou 3."
    exit 1
fi

# En mode cron, générer un rapport
if [ "$cronMode" = "y" ]; then
    rapport="rapport_scan_$(date +%F_%T).txt"
    nmap $options "$ip" > "$rapport"
    echo "Rapport généré : $rapport"
fi

