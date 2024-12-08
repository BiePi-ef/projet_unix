# projet_unix
the project of our unix class

Procedure à suivre :
  1) Avant chaque modification :
     - je créer une nouvelle branch depuis Dev
     - je checkout sur cette branch
  2) Je fais ma modification
  3) Apres chaque modification
     - je git add *
     - je git commit -m "object de la modif : details"
     - je git push
  4) Quand j'ai fini et push toutes mes modifs, et que mon code marche bien, SANS PROBLEMES, AUCUN :
     - je merge ma branche (depuis l'interface github) à la branche dev
     - je résoud les problemes de compatibilité du merge
     - JE VERFIE QUE TOUT MARCHE PLEASE

Exemples d'exécution
Mode manuel avec affichage de la sortie :

```./nmap_scanner.sh```

Mode non interactif avec rapport uniquement :

```./nmap_scanner.sh --type 1 --ip 192.168.1.1 --cron --output scan_rapport.txt```

Scan complet avec détection avancée et rapport enregistré :

```./nmap_scanner.sh --type 2 --ip 192.168.1.1 --osScan y --output scan_complet.txt```

Scan personnalisé sur des ports spécifiques avec rapport :

```./nmap_scanner.sh --type 3 --ip 192.168.1.1 --ports 80,443 --output scan_perso.txt```

