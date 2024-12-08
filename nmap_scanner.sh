#!/bin/bash

# Script pour scanner les ports à distance avec Nmap

# Initialisation des variables par défaut
scanType=""
ip=""
ports="0"
osScan=""
cronMode="n"
outputFile=""
noMail=""
emailFrom=""
emailTo=""
cronJob=""

# Définition des variables globales SCRIPTPATH et SCRIPTNAME
SCRIPTPATH=$(dirname "$(realpath "$0")")
SCRIPTNAME=$(basename "$0")

# Parse des arguments passés en ligne de commande
while [[ $# -gt 0 ]]; do
    case $1 in
        --type) scanType="$2"; shift 2 ;;       # Type de scan : 1 = rapide, 2 = complet, 3 = personnalisé
        --ip) ip="$2"; shift 2 ;;               # Adresse IP ou plage
        --ports) ports="$2"; shift 2 ;;         # Ports à scanner (pour le type 3 uniquement)
        --osScan) osScan="$2"; shift 2 ;;       # Détection avancée : y ou n
        --output) outputFile="$2"; shift 2 ;;   # Fichier pour sauvegarder le rapport
        --noMail) noMail="y"; shift ;;          # L'utilisateur ne veut pas envoyer de mail
        --emailFrom) emailFrom="$2"; shift 2 ;; # Adresse email d'expéditeur
        --emailTo) emailTo="$2"; shift 2 ;;     # Adresse email de destination
        --cron) cronMode="y"; shift ;;          # Activer le mode cron
        *) echo "Option inconnue : $1"; exit 1 ;;
    esac
done

# Fonction pour valider l'heure au format HH:MM
function valider_heure() {
    local heure="$1"
    if [[ "$heure" =~ ^([0-1][0-9]|2[0-3]):([0-5][0-9])$ ]]; then
        return 0  # Heure valide
    else
        return 1  # Heure invalide
    fi
}

# Fonction pour valider le jour de la semaine
function valider_jour_semaine() {
    local jour="$1"
    case "$jour" in
        Lundi|Mardi|Mercredi|Jeudi|Vendredi|Samedi|Dimanche) return 0 ;;  # Jour valide
        *) return 1 ;;  # Jour invalide
    esac
}

# Fonction interactive pour demander une réponse valide
function demander_et_valider() {
    local varName="$1"
    local question="$2"
    local validationFunction="$3"  # Nom de la fonction de validation
    local isOptional="$4"          # "y" si la variable est facultative

    while true; do
        if [ -z "${!varName}" ]; then
            echo "$question"
            read userInput
        else
            userInput="${!varName}"
        fi

        if [ -z "$userInput" ] && [ "$isOptional" = "y" ]; then
            eval "$varName=''"
            break
        elif $validationFunction "$userInput"; then
            eval "$varName='$userInput'"
            break
        else
            echo "Entrée invalide. Veuillez réessayer."
        fi
    done
}

# Validation du type de scan
function valider_scanType() {
    local scanType_input="$1"
    [[ "$scanType_input" =~ ^[1-3]$ ]]  # Accepte uniquement 1, 2 ou 3
}

# Validation des adresses IP
function valider_ip() {
    local ip_input="$1"
    [[ "$ip_input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || \
    [[ "$ip_input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || \
    [[ "$ip_input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}-[0-9]{1,3}$ ]] || \
    [[ "$ip_input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(,([0-9]{1,3}\.){3}[0-9]{1,3})+$ ]]
}

# Validation des ports
function valider_ports() {
    local ports_input="$1"
    [[ "$ports_input" =~ ^[0-9]{1,5}$ ]] || \
    [[ "$ports_input" =~ ^[0-9]{1,5}-[0-9]{1,5}$ ]] || \
    [[ "$ports_input" =~ ^[0-9]{1,5}(,[0-9]{1,5})+$ ]]
}

# Validation des emails
function valider_email() {
    local email_input="$1"
    [[ "$email_input" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# Validation pour `y` ou `n`
function valider_oui_non() {
    local input="$1"
    [[ "$input" =~ ^[yYnN]$ ]]  # Accepte uniquement "y", "n", "Y", "N"
}

# Validation du nom du fichier (outputFile)
function valider_nom_fichier() {
    local nom_fichier="$1"
    # Si l'utilisateur n'a rien entré (appuyé sur Entrée), c'est valide
    if [ -z "$nom_fichier" ]; then
        return 0
    fi
    # Vérifie que c'est un nom valide pour un fichier
    if [[ "$nom_fichier" =~ ^[a-zA-Z0-9._/-]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Fonction pour valider la réponse à la question "Lancer immédiatement ou planifier une tâche cron"
function valider_cron_choice() {
    local choice="$1"
    [[ "$choice" =~ ^[1-2]$ ]]  # Accepte uniquement 1 ou 2
}

# Fonction pour obtenir le jour de la semaine au format cron
function obtenir_jour_semaine() {
    local jour="$1"
    case "$jour" in
        Lundi) echo 1 ;;
        Mardi) echo 2 ;;
        Mercredi) echo 3 ;;
        Jeudi) echo 4 ;;
        Vendredi) echo 5 ;;
        Samedi) echo 6 ;;
        Dimanche) echo 0 ;;
        *) echo "Jour invalide" ;;
    esac
}

# Fonction pour parser l'heure et la minute
function parse_cron_time() {
    local cronTime="$1"
    IFS=":" read -r cronHour cronMinute <<< "$cronTime"
    echo "$cronMinute $cronHour"
}

# Demander et valider les informations
demander_et_valider "scanType" "Quel type de scan souhaitez-vous effectuer ? (1 = rapide, 2 = complet, 3 = personnalisé)" valider_scanType "n"
demander_et_valider "ip" "Entrez l'adresse IP (ex. : 192.168.1.1, 192.168.1.1-192.168.1.10, 192.168.1.1-100 ou plusieurs IP distinctes séparées par des virgules) :" valider_ip "n"
if [[ "$scanType" -eq 3 && "$ports" -eq 0 ]]; then
    ports=""
    demander_et_valider "ports" "Entrez le(s) port(s) à scanner (ex : 80,443 ou 1-1000) :" valider_ports "n"
fi
demander_et_valider "osScan" "Voulez-vous activer la détection des systèmes d'exploitation et des services actifs ? (y/n)" valider_oui_non "n"
demander_et_valider "outputFile" "Voulez-vous sauvegarder le rapport dans un fichier ? Si oui, entrez le nom (ou appuyez sur Entrée pour ignorer) :" valider_nom_fichier "y"

if [ -n "$outputFile" ]; then
    # Demander si l'utilisateur veut envoyer le rapport par email
    if [ "$noMail" != "y" ]; then
        demander_et_valider "emailTo" "Voulez-vous envoyer le rapport par email ? Si oui, entrez l'adresse email de destination (To) :" valider_email "y"

        # Demander l'email d'expéditeur uniquement si l'utilisateur souhaite envoyer le rapport par email
        if [ -n "$emailTo" ]; then
            demander_et_valider "emailFrom" "Entrez l'adresse email d'expéditeur (From) :" valider_email "n"
        fi
    fi
fi

# Si le script est lancé en mode manuel (sans --cron), demander s'il faut lancer la commande immédiatement ou planifier une tâche cron
if [ "$cronMode" != "y" ]; then
    while true; do
        echo "Voulez-vous lancer la commande immédiatement ou planifier une tâche cron ?"
        echo "1 : Lancer immédiatement"
        echo "2 : Planifier via cron"
        read cronChoice
        if valider_cron_choice "$cronChoice"; then
            break
        else
            echo "Réponse invalide. Veuillez entrer 1 pour lancer immédiatement ou 2 pour planifier via cron."
        fi
    done
else
    cronChoice=1  # Si en mode cron, on lance immediatement le script
fi

# Si l'utilisateur a choisi de planifier via cron, demander l'heure et la fréquence
if [ "$cronChoice" -eq 2 ]; then
    # Demander l'heure et la fréquence
    while true; do
        echo "À quelle heure voulez-vous exécuter la commande ? (Format : HH:MM)"
        read cronTime
        if valider_heure "$cronTime"; then
            break
        else
            echo "L'heure entrée est invalide. Veuillez entrer une heure valide au format HH:MM (00:00 à 23:59)."
        fi
    done

    # Parser l'heure et la minute
    cronTimeParsed=$(parse_cron_time "$cronTime")
    cronMinute=$(echo "$cronTimeParsed" | cut -d ' ' -f 1)
    cronHour=$(echo "$cronTimeParsed" | cut -d ' ' -f 2)

    echo "Fréquence de la planification :"
    echo "1 : Quotidien"
    echo "2 : Hebdomadaire"
    read cronFrequency

    if [ "$cronFrequency" -eq 1 ]; then
        # Planification quotidienne
	if [ -n "$emailTo" ]; then
            cronJob="$cronMinute $cronHour * * * $SCRIPTPATH/$SCRIPTNAME --type $scanType --ip $ip --ports $ports --osScan $osScan --output $outputFile --emailFrom \"$emailFrom\" --emailTo \"$emailTo\" --cron"
	else
            cronJob="$cronMinute $cronHour * * * $SCRIPTPATH/$SCRIPTNAME --type $scanType --ip $ip --ports $ports --osScan $osScan --output $outputFile --noMail --cron"
	fi
    elif [ "$cronFrequency" -eq 2 ]; then
        # Planification hebdomadaire
        while true; do
            echo "Quel jour de la semaine voulez-vous pour la planification ? (Lundi, Mardi, etc.)"
            read cronDay
            if valider_jour_semaine "$cronDay"; then
                cronDayNumber=$(obtenir_jour_semaine "$cronDay")
                break
            else
                echo "Jour invalide, veuillez entrer un jour valide (Lundi, Mardi, etc.)."
            fi
        done
	if [ -n "$emailTo" ]; then
            cronJob="$cronMinute $cronHour * * $cronDayNumber $SCRIPTPATH/$SCRIPTNAME --type $scanType --ip $ip --ports $ports --osScan $osScan --output $outputFile --emailFrom \"$emailFrom\" --emailTo \"$emailTo\" --cron"
        else
            cronJob="$cronMinute $cronHour * * $cronDayNumber $SCRIPTPATH/$SCRIPTNAME --type $scanType --ip $ip --ports $ports --osScan $osScan --output $outputFile --noMail --cron"
	fi
    else
        echo "Option de fréquence invalide."
        exit 1
    fi

    # Ajouter la tâche cron
    (crontab -l ; echo "$cronJob") | crontab -
    echo "Tâche planifiée avec succès : $cronJob"
else
    # Lancer immédiatement
    echo "Lancement du scan immédiatement..."
    # Préparer les options Nmap (ajout de l'option -A pour la détection avancée)
    options=""
    if [[ "$osScan" =~ ^[yY]$ ]]; then
        options="-A"
    fi

    # Construct the Nmap command and execute it
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

    # Exécuter la commande Nmap
    echo "Lancement de la commande : $nmapCommand"
    scanOutput=$(eval "$nmapCommand")

    # Si l'utilisateur a demandé de sauvegarder le rapport, le fichier sera créé dans le même répertoire que le script
    if [ -n "$outputFile" ]; then
        echo "$scanOutput" > "$SCRIPTPATH/$outputFile"
        echo "Rapport généré avec succès : $outputFile"

        # Envoyer le rapport par email
        if [ -n "$emailTo" ]; then
            if [ -n "$outputFile" ]; then
                echo "Veuillez trouver ci-joint le rapport de scan Nmap." | mail -s "Rapport de scan Nmap" -r "$emailFrom" -A "$SCRIPTPATH/$outputFile" "$emailTo"
                echo "Rapport envoyé avec succès de $emailFrom à $emailTo"
            else
                echo "Erreur : Aucune pièce jointe à envoyer. Veuillez spécifier un fichier de rapport avec --output."
                exit 1
            fi
        fi
    else
        echo "$scanOutput"
    fi
fi

