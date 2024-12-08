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

# Fonction pour demander les informations manquantes
function demander_si_manquant() {
    local varName="$1"  # Nom de la variable à vérifier
    local question="$2" # Question à poser si la variable est vide
    local isOptional="$3" # "y" si la variable est facultative

    # Si la variable est vide, poser la question
    if [ -z "${!varName}" ]; then
        echo "$question"
        read userInput

        # Vérification pour les variables obligatoires
        if [ -z "$userInput" ] && [ "$isOptional" != "y" ]; then
            echo "Erreur : Ce champ est obligatoire."
            exit 1
        fi

        # Affecter la valeur entrée par l'utilisateur
        eval "$varName='$userInput'"
    fi
}

# Demander les informations manquantes
demander_si_manquant "scanType" "Quel type de scan souhaitez-vous effectuer ? (1 = rapide, 2 = complet, 3 = personnalisé)" "n"
demander_si_manquant "ip" "Entrez l'adresse IP cible :" "n"
if [ "$scanType" -eq 3 ]; then
    demander_si_manquant "ports" "Entrez le(s) port(s) à scanner (ex : 80,443 ou 1-1000) :" "n"
fi
demander_si_manquant "osScan" "Voulez-vous activer la détection des systèmes d'exploitation et des services actifs ? (y/n)" "y"
demander_si_manquant "outputFile" "Voulez-vous sauvegarder le rapport dans un fichier ? Si oui, entrez le chemin (ou appuyez sur Entrée pour ignorer) :" "y"

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

