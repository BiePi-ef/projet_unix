# projet_unix

Exemples d'exécution
Mode manuel avec affichage de la sortie :

```./nmap_scanner.sh```

Lorsqu'on lance cette commande le programme se lance et il nous demande directement le scan que l'on veut et après nous demande les differents parametres que l'on veut comme :
- savoir si l'on veut une adresse ip, ou bien une plage, etc...
- activer la detection des systemes d'exploitations
- sauvegarder le rapport dans un fichier
- envoyer le rapport crees avant par mail (envoyeur/receveur du mail)


Mode non interactif avec rapport uniquement :

```./nmap_scanner.sh --type 1 --ip 192.168.1.1 --cron --output scan_rapport.txt```

Scan complet avec détection avancée et rapport enregistré :

```./nmap_scanner.sh --type 2 --ip 192.168.1.1 --osScan y --output scan_complet.txt```

Scan personnalisé sur des ports spécifiques avec rapport :

```./nmap_scanner.sh --type 3 --ip 192.168.1.1 --ports 80,443 --output scan_perso.txt```

Détails des paramètres :

1. ./nmap_scanner.sh
  
  - Exécute le script Bash dans le répertoire courant.
  - Le script utilise Nmap, un outil réseau puissant, pour effectuer des analyses de ports et collecter des informations.

2. --type 1

Définit le type de scan à effectuer.

  - 1 : Scan rapide.
  - Cela utilise l'option -F de Nmap, qui analyse uniquement les ports les plus fréquemment utilisés.
  - C'est utile pour obtenir des résultats rapides avec un niveau de détail suffisant.

3.--ip 192.168.1.1-30

Spécifie la plage d'adresses IP à scanner :
  - Ici, les IP comprises entre 192.168.1.1 et 192.168.1.30 seront analysées.
  - Nmap testera chaque adresse pour voir quels ports sont ouverts et quels services y fonctionnent.

--osScan y

Active la détection avancée des systèmes d'exploitation et des services (-A dans Nmap).
Cela inclut :
  - L'identification du système d'exploitation des machines ciblées.
  - L'analyse des services actifs sur les ports détectés.
  - La collecte d'informations détaillées sur chaque hôte.

--output rapport.txt

Indique que le rapport de scan doit être sauvegardé dans un fichier nommé rapport.txt.

  - Le fichier sera créé dans le même répertoire que le script, sauf indication contraire.
  - Cela permet de conserver une trace des résultats pour une analyse ultérieure.

--emailFrom maxime@desclaux.fr
Définit l'adresse email d'expéditeur utilisée pour envoyer le rapport.

--emailTo maxime@desclaux.fr
Spécifie l'adresse email de destination où le rapport sera envoyé après le scan.

--cron

Indique que la commande doit être planifiée dans une tâche cron pour une exécution ultérieure automatique.
Le script demandera des informations supplémentaires (heure, fréquence) pour ajouter la tâche à cron.
