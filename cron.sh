#!/bin/bash
LOG_DIR="$HOME/logs"
mkdir -p "$LOG_DIR"


echo "=== Configuration de l'automatisation des scans ==="
echo "1. Quotidien (toutes les 10 min)"
echo "2. Hebdomadaire"
echo "3. Personnalisé"
echo "Choisissez la fréquence (1-3) : "
read freq

case $freq in
  1)
    CRON_EXPR="*/10 * * * *"
    ;;
  2)
    CRON_EXPR="0 2 * * 0" # Tous les dimanches à 2h du matin
    ;;
  3)
    read -p "Entrez l'expression cron personnalisée : " CRON_EXPR
    ;;
  *)
    echo "Choix invalide !"
    exit 1
    ;;
esac

read -p "Entrez l'hôte ou les IPs à scanner : " cible
echo "Types de scan disponibles :"
echo " - rapide"
echo " - complet"
echo " - personnalisé"
echo " - avancé"
read -p "Entrez le type de scan : " type_scan

# Créer la commande de scan
case $type_scan in
  "rapide")
    CMD="nmap -F $cible"
    ;;
  "complet")
    CMD="nmap -p- -sU -sS $cible"
    ;;
  "personnalisé")
    read -p "Spécifiez les ports (ex : 22,80,443) : " ports
    CMD="nmap -p $ports $cible"
    ;;
  "avancé")
    CMD="nmap -A $cible"
    ;;
  *)
    echo "Type de scan invalide !"
    exit 1
    ;;
esac

# Ajouter la tâche à cron
CRON_CMD="$CMD > $LOG_DIR/scan_\$(date +\%Y-\%m-\%d_\%H-\%M-\%S).log && mail -s 'Rapport Nmap \$(date)' 88wilhem@gmail.com < $LOG_DIR/scan_\$(date +\%Y-\%m-\%d_\%H-\%M-\%S).log"
(crontab -l 2>/dev/null; echo "$CRON_EXPR $CRON_CMD") | crontab -

echo "Scan programmé avec succès !"

