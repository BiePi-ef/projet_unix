#!/bin/bash

# Script pour scanner les ports à distance avec Nmap

# Initialisation des variables par défaut
scanType=""
ip=""
ports=""
osScan="n"
cronMode="n"
outputFile=""

# Parse des arguments passés en ligne de commande
while [[ $# -gt 0 ]]; do
    case $1 in
        --type) scanType="$2"; shift 2 ;;      # Type de scan : 1 = rapide, 2 = complet, 3 = personnalisé
        --ip) ip="$2"; shift 2 ;;              # Adresse IP ou plage
        --ports) ports="$2"; shift 2 ;;        # Ports à scanner (pour le type 3 uniquement)
        --osScan) osScan="$2"; shift 2 ;;      # Détection avancée : y ou n
        --output) outputFile="$2"; shift 2 ;;  # Fichier pour sauvegarder le rapport
        --cron) cronMode="y"; shift ;;         # Activer le mode cron
        *) echo "Option inconnue : $1"; exit 1 ;;
    esac
done

# Fonction pour demander les informations en mode interactif
function interactif() {
    echo "Quel type de scan souhaitez-vous effectuer ?
1 : Scan rapide
2 : Scan complet
3 : Scan personnalisé"
    read scanType

    echo "Entrez l'adresse IP cible :"
    read ip

    if [ "$scanType" -eq 3 ]; then
        echo "Entrez le(s) port(s) à scanner (ex : 80,443 ou 1-1000) :"
        read ports
    fi

    echo "Voulez-vous activer la détection des systèmes d'exploitation et des services actifs ? (y/n)"
    read osScan

    echo "Voulez-vous sauvegarder le rapport dans un fichier ? (y/n)"
    read saveReport
    if [ "$saveReport" = "y" ]; then
        echo "Entrez le chemin du fichier de rapport :"
        read outputFile
    fi
}

# Basculer en mode interactif si aucun argument n'est fourni
if [[ -z "$scanType" || -z "$ip" ]]; then
    echo "Aucun argument détecté. Passage en mode interactif."
    interactif
fi

# Préparer les options pour Nmap
options=""
if [ "$osScan" = "y" ]; then
    options="$options -A"
fi

# Exécution selon le type de scan choisi
case $scanType in
    1)
        echo "Lancement d'un scan rapide sur $ip..."
        nmap -F $options "$ip" ;;
    2)
        echo "Lancement d'un scan complet sur $ip..."
        nmap -p- -sT -sU $options "$ip" ;;
    3)
        if [ -z "$ports" ]; then
            echo "Erreur : Vous devez spécifier les ports pour un scan personnalisé (--ports)."
            exit 1
        fi
        echo "Lancement d'un scan personnalisé sur $ip pour les ports $ports..."
        nmap -p "$ports" $options "$ip" ;;
    *)
        echo "Type de scan invalide. Choisissez 1, 2 ou 3."
        exit 1 ;;
esac

# Génération d'un rapport si demandé
if [ -n "$outputFile" ]; then
    echo "Génération du rapport dans : $outputFile"
    nmap $options "$ip" > "$outputFile"
    echo "Rapport généré avec succès : $outputFile"
fi

# Confirmation du mode cron (pour automatisation)
if [ "$cronMode" = "y" ]; then
    echo "Script exécuté en mode cron. Rapport enregistré dans $outputFile."
fi

