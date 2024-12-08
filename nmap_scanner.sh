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

# Validation et formatage des adresses IP saisies
function valider_ip() {
    local ip_input="$1"
    # Vérifie si c'est une seule IP, une plage ou une liste séparée par des virgules
    if [[ "$ip_input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || \
       [[ "$ip_input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || \
       [[ "$ip_input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(,([0-9]{1,3}\.){3}[0-9]{1,3})+$ ]]; then
        echo "$ip_input"
    else
        echo "Erreur : Format d'adresse IP invalide. Veuillez saisir une seule IP, une plage (ex. : 192.168.1.1-192.168.1.10) ou plusieurs adresses séparées par des virgules." >&2
        exit 1
    fi
}

# Validation des ports ou plages de ports saisies
function valider_ports() {
    local ports_input="$1"
    # Vérifie si c'est un seul port, une plage ou une liste de ports
    if [[ "$ports_input" =~ ^[0-9]{1,5}$ ]] || \
       [[ "$ports_input" =~ ^[0-9]{1,5}-[0-9]{1,5}$ ]] || \
       [[ "$ports_input" =~ ^[0-9]{1,5}(,[0-9]{1,5})+$ ]]; then
        echo "$ports_input"
    else
        echo "Erreur : Format de ports invalide. Veuillez saisir un seul port (ex. : 80), une plage (ex. : 20-80), ou plusieurs ports séparés par des virgules (ex. : 80,443,8080)." >&2
        exit 1
    fi
}

# Demander les informations manquantes
demander_si_manquant "scanType" "Quel type de scan souhaitez-vous effectuer ? (1 = rapide, 2 = complet, 3 = personnalisé)" "n"
demander_si_manquant "ip" "Entrez l'adresse IP (ex. : 192.168.1.1, 192.168.1.1-192.168.1.10 ou plusieurs IP séparées par des virgules) :" "n"
ip=$(valider_ip "$ip")  # Valider l'entrée IP
if [ "$scanType" -eq 3 ]; then
    demander_si_manquant "ports" "Entrez le(s) port(s) à scanner (ex : 80,443 ou 1-1000) :" "n"
    ports=$(valider_ports "$ports")  # Valider l'entrée des ports
fi
demander_si_manquant "osScan" "Voulez-vous activer la détection des systèmes d'exploitation et des services actifs ? (y/n)" "y"
demander_si_manquant "outputFile" "Voulez-vous sauvegarder le rapport dans un fichier ? Si oui, entrez le chemin (ou appuyez sur Entrée pour ignorer) :" "y"

# Préparer les options pour Nmap
options=""
if [ "$osScan" = "y" ]; then
    options="$options -A"
fi

# Construire la commande Nmap
nmapCommand="nmap $options"
case $scanType in
    1)
        nmapCommand="$nmapCommand -F $ip" ;;
    2)
        nmapCommand="$nmapCommand -p- -sT -sU $ip" ;;
    3)
        nmapCommand="$nmapCommand -p $ports $ip" ;;
    *)
        echo "Type de scan invalide. Choisissez 1, 2 ou 3."
        exit 1 ;;
esac

# Exécuter la commande Nmap une seule fois et capturer la sortie
scanOutput=$(eval "$nmapCommand")

# Afficher ou sauvegarder la sortie en fonction du mode
if [ "$cronMode" = "y" ]; then
    # En mode cron, sauvegarder uniquement dans un fichier
    if [ -n "$outputFile" ]; then
        echo "$scanOutput" > "$outputFile"
        echo "Rapport généré avec succès : $outputFile"
    fi
else
    # En mode interactif, afficher et sauvegarder si demandé
    echo "$scanOutput"
    if [ -n "$outputFile" ]; then
        echo "$scanOutput" > "$outputFile"
        echo "Rapport généré avec succès : $outputFile"
    fi
fi

