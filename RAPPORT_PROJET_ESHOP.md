# Rapport du Projet EShop - Base de Donnees Distribuee Oracle PL/SQL

## 1. Introduction

Ce projet a pour objectif de concevoir et mettre en oeuvre une base de donnees distribuee pour une application EShop en utilisant Oracle Database, SQL et PL/SQL.

Le projet met en pratique plusieurs concepts importants des bases de donnees distribuees:

- la creation d'un schema relationnel global;
- la fragmentation horizontale des donnees;
- la simulation de deux sites distribues;
- l'utilisation de procedures stockees PL/SQL;
- l'utilisation de triggers pour synchroniser les donnees;
- l'optimisation de requetes avec indexes et plans d'execution;
- l'execution d'une requete distribuee sur deux sites.

Le projet est dockerise afin de pouvoir etre execute facilement sur une autre machine sans installation manuelle complexe d'Oracle Database.

## 2. Technologies Utilisees

Les technologies utilisees sont:

- Oracle Database Free dans Docker;
- SQL pour la creation et la manipulation des tables;
- PL/SQL pour les procedures stockees et les triggers;
- Docker Compose pour lancer la base de donnees;
- SQL*Plus et Oracle SQL Developer pour tester le projet.

L'image Docker utilisee est:

```text
gvenzl/oracle-free:23-slim
```

Le service Oracle utilise:

```text
Service name: FREEPDB1
User: eshop
Password: eshop
Port local: 1523
```

## 3. Structure du Projet

Le projet est organise comme suit:

```text
.
├── docker-compose.yml
├── README.md
├── SUBMISSION.md
├── SUBMISSION_SQL_DEVELOPER.md
├── RAPPORT_PROJET_ESHOP.md
└── sql/
    ├── 01_create_global_schema.sql
    ├── 02_create_site1_schema.sql
    ├── 03_create_site2_schema.sql
    ├── 04_insert_sample_data.sql
    ├── 05_fragmentation_scenario1.sql
    ├── 06_fragmentation_scenario2.sql
    ├── 07_procedures_site1.sql
    ├── 08_procedures_site2.sql
    ├── 09_triggers_global.sql
    ├── 10_queries_optimization.sql
    ├── 11_distributed_query.sql
    └── 12_demo_check.sql
```

Chaque fichier SQL a un role precis et les scripts sont numerotes pour garantir un ordre logique d'execution.

## 4. Modele Relationnel Global

La base globale EShop contient quatre tables principales:

```text
Clients
Commandes
Produits
LigneCommandes
```

### 4.1 Table Clients

La table `Clients` contient les informations des clients:

```text
idclient, codeclient, societe, contact, ville, pays, telephone
```

La cle primaire est:

```text
idclient
```

### 4.2 Table Produits

La table `Produits` contient les produits vendus dans l'EShop:

```text
idproduit, idcateg, designation, prixunitaire
```

La cle primaire est:

```text
idproduit
```

La colonne `idcateg` represente la categorie du produit. Elle est utilisee dans le scenario 1 de fragmentation.

### 4.3 Table Commandes

La table `Commandes` contient les commandes effectuees par les clients:

```text
idcommande, idemploye, idclient, datecommande, adresse_livraison, ville_livraison, pays_livraison
```

La cle primaire est:

```text
idcommande
```

La table `Commandes` reference la table `Clients` avec une cle etrangere:

```sql
FOREIGN KEY (idclient) REFERENCES Clients(idclient)
```

Cela signifie qu'une commande doit toujours appartenir a un client existant.

### 4.4 Table LigneCommandes

La table `LigneCommandes` contient les lignes de commandes:

```text
idlignecommande, idcommande, idproduit, quantite, remise
```

La cle primaire est:

```text
idlignecommande
```

Cette table reference:

```text
Commandes(idcommande)
Produits(idproduit)
```

Cela signifie qu'une ligne de commande doit toujours etre liee a une commande et a un produit existants.

## 5. Contraintes d'Integrite

Le projet applique plusieurs contraintes:

- des cles primaires sur tous les identifiants principaux;
- des cles etrangeres pour relier les tables;
- des contraintes `CHECK` pour eviter les valeurs incorrectes.

Exemples:

```sql
quantite > 0
remise >= 0 AND remise < 1
prixunitaire >= 0
```

Ces contraintes assurent la coherence des donnees.

## 6. Principe de Base de Donnees Distribuee

Une base de donnees distribuee est une base dont les donnees sont reparties sur plusieurs sites.

Dans un cas reel, chaque site peut etre sur un serveur different. Dans ce projet, les sites sont simules dans le meme conteneur Oracle pour faciliter les tests.

Les deux sites sont:

```text
Site1
Site2
```

Les tables du Site1 sont:

```text
Clients1
Commandes1
Produits1
LigneCommandes1
```

Les tables du Site2 sont:

```text
Clients2
Commandes2
Produits2
LigneCommandes2
```

Chaque site contient une partie des donnees globales selon les regles de fragmentation.

## 7. Fragmentation Horizontale

La fragmentation horizontale consiste a decouper une table par lignes.

Dans ce projet, la table principalement fragmentee est:

```text
LigneCommandes
```

Les lignes de cette table sont reparties entre `LigneCommandes1` et `LigneCommandes2`.

## 8. Scenarios de Fragmentation

Deux scenarios de fragmentation ont ete implementes.

### 8.1 Scenario 1

Le fichier concerne est:

```text
05_fragmentation_scenario1.sql
```

Regle du Site1:

```text
idcateg = 50 AND quantite > 100
```

Regle du Site2:

```text
idcateg = 35 AND quantite > 50
```

Dans le sujet, la condition parle de `idCategorie`. Dans notre modele relationnel normalise, la categorie est stockee dans la table `Produits`, sous le nom `idcateg`.

Il faut donc faire une jointure entre `LigneCommandes` et `Produits`.

Exemple:

```sql
SELECT lc.*
FROM LigneCommandes lc
JOIN Produits p ON p.idproduit = lc.idproduit
WHERE p.idcateg = 50
  AND lc.quantite > 100;
```

Resultat obtenu:

```text
SCENARIO 1 - SITE1 rows = 3
SCENARIO 1 - SITE2 rows = 3
```

### 8.2 Scenario 2

Le fichier concerne est:

```text
06_fragmentation_scenario2.sql
```

Regle du Site1:

```text
quantite >= 100
```

Regle du Site2:

```text
quantite < 100
```

Resultat obtenu:

```text
SCENARIO 2 - SITE1 rows = 4
SCENARIO 2 - SITE2 rows = 5
```

## 9. Table de Configuration de Fragmentation

La table suivante permet de connaitre le scenario actif:

```text
Fragmentation_Config
```

Elle contient notamment la colonne:

```text
scenario
```

Si `scenario = 1`, les triggers appliquent les regles du scenario 1.

Si `scenario = 2`, les triggers appliquent les regles du scenario 2.

Cette table permet de changer le comportement du systeme sans modifier le code des triggers.

## 10. Procedures Stockees PL/SQL

Une procedure stockee est un bloc de code enregistre dans Oracle. Elle permet d'executer plusieurs instructions SQL avec une seule commande.

Dans ce projet, les procedures sont regroupees dans deux packages:

```text
Site1
Site2
```

### 10.1 Package Site1

Le fichier concerne est:

```text
07_procedures_site1.sql
```

Le package `Site1` contient:

```text
Site1.insertligne
Site1.deleteligne
Site1.updateligne
```

### 10.2 Package Site2

Le fichier concerne est:

```text
08_procedures_site2.sql
```

Le package `Site2` contient:

```text
Site2.insertligne
Site2.deleteligne
Site2.updateligne
```

### 10.3 Procedure insertligne

La procedure `insertligne` insere une ligne de commande dans un site.

Avant l'insertion, elle verifie que les donnees necessaires existent dans le site:

- le client;
- la commande;
- le produit.

Si ces donnees n'existent pas encore dans le site, elles sont copiees depuis les tables globales.

Cela permet de respecter l'integrite referentielle locale.

### 10.4 Procedure deleteligne

La procedure `deleteligne` supprime une ligne de commande par son identifiant.

Apres la suppression, elle nettoie les donnees devenues orphelines dans le site, par exemple:

- une commande locale qui n'a plus de lignes;
- un client local qui n'a plus de commandes;
- un produit local qui n'est plus utilise.

### 10.5 Procedure updateligne

La procedure `updateligne` modifie:

```text
idproduit
quantite
remise
```

Elle est utile lorsqu'une ligne de commande change de produit, de quantite ou de remise.

## 11. Triggers Globaux

Un trigger est un programme PL/SQL execute automatiquement par Oracle lorsqu'un evenement se produit.

Dans ce projet, les triggers sont crees sur la table globale:

```text
LigneCommandes
```

Les triggers crees sont:

```text
SYC_INSERT_LIGNE
SYC_DELETE_LIGNE
SYC_UPDATE_LIGNE
```

### 11.1 Trigger SYC_INSERT_LIGNE

Ce trigger s'execute automatiquement apres une insertion dans `LigneCommandes`.

Il lit le scenario actif dans `Fragmentation_Config`, puis route la ligne vers le bon site.

Exemple:

Si le scenario actif est le scenario 2 et que:

```text
quantite = 160
```

alors la ligne est envoyee vers:

```text
Site1
```

### 11.2 Trigger SYC_DELETE_LIGNE

Ce trigger s'execute automatiquement apres une suppression dans `LigneCommandes`.

Il supprime la ligne correspondante dans les sites.

Il appelle:

```text
Site1.deleteligne
Site2.deleteligne
```

### 11.3 Trigger SYC_UPDATE_LIGNE

Ce trigger s'execute automatiquement apres une modification de:

```text
idproduit
quantite
remise
```

Une mise a jour peut changer le site de destination d'une ligne.

Par exemple, dans le scenario 2:

```text
quantite = 160
```

appartient a Site1.

Mais si la quantite devient:

```text
quantite = 20
```

la ligne doit aller vers Site2.

Le trigger supprime donc l'ancienne version dans les sites, puis insere la nouvelle version dans le bon site.

## 12. Optimisation de Requete

Le fichier concerne est:

```text
10_queries_optimization.sql
```

La requete demandee calcule le nombre de commandes par client en 2026.

```sql
SELECT
  c.idclient,
  c.codeclient,
  c.societe,
  COUNT(co.idcommande) AS nombre_commandes_2026
FROM Clients c
JOIN Commandes co ON co.idclient = c.idclient
WHERE co.datecommande >= DATE '2026-01-01'
  AND co.datecommande < DATE '2027-01-01'
GROUP BY c.idclient, c.codeclient, c.societe
ORDER BY nombre_commandes_2026 DESC, c.societe;
```

### 12.1 Plan d'Execution

Le plan d'execution est genere avec:

```sql
EXPLAIN PLAN FOR ...
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

Le plan d'execution montre comment Oracle execute la requete.

Operations possibles:

- `TABLE ACCESS FULL`: Oracle lit toute la table;
- `INDEX RANGE SCAN`: Oracle utilise un index;
- `HASH GROUP BY`: Oracle regroupe les resultats;
- `SORT ORDER BY`: Oracle trie les resultats;
- `JOIN`: Oracle combine deux tables.

### 12.2 Indexes Ajoutes

Deux indexes ont ete ajoutes:

```sql
CREATE INDEX idx_commandes_date_client
ON Commandes(datecommande, idclient);
```

Cet index aide la requete car elle filtre par `datecommande` et joint par `idclient`.

Deuxieme index:

```sql
CREATE INDEX idx_commandes_client
ON Commandes(idclient);
```

Cet index aide les jointures entre `Clients` et `Commandes`.

Apres l'ajout des indexes, le plan affiche:

```text
INDEX RANGE SCAN IDX_COMMANDES_DATE_CLIENT
```

Cela montre que l'index est utilise par Oracle.

## 13. Requete Distribuee

Le fichier concerne est:

```text
11_distributed_query.sql
```

L'objectif est de calculer le chiffre d'affaires total par categorie de produit en 2026.

Formule:

```text
revenue = quantite * prixunitaire * (1 - remise)
```

La requete lit les donnees de Site1 et Site2, puis les combine avec:

```sql
UNION ALL
```

`UNION ALL` est utilise car il ne supprime pas les doublons, donc il est plus performant que `UNION`.

Resultat obtenu:

```text
IDCATEG    CHIFFRE_AFFAIRES_2026
20         321300
35         132215
50         7342755
70         71600
```

## 14. Simulation des Database Links

Dans un vrai environnement distribue Oracle, les tables distantes seraient interrogees avec des database links:

```sql
LigneCommandes1@SITE1_LINK
LigneCommandes2@SITE2_LINK
```

Dans ce projet, pour faciliter l'execution sur une seule machine, les sites sont simules avec des tables locales:

```text
LigneCommandes1
LigneCommandes2
```

Le script contient aussi une version commentee avec la syntaxe `@SITE1_LINK` et `@SITE2_LINK`.

## 15. Dockerisation

Le fichier `docker-compose.yml` permet de lancer Oracle automatiquement.

Commande de lancement:

```powershell
docker compose up -d
```

Suivi des logs:

```powershell
docker logs -f eshop-oracle
```

Le message attendu est:

```text
DATABASE IS READY TO USE!
```

Connexion avec SQL*Plus:

```powershell
docker exec -it eshop-oracle sqlplus eshop/eshop@FREEPDB1
```

Connexion avec Oracle SQL Developer:

```text
Host: localhost
Port: 1523
Service name: FREEPDB1
Username: eshop
Password: eshop
```

## 16. Tests et Resultats

### 16.1 Verification des Tables Globales

Le script `12_demo_check.sql` affiche le nombre de lignes dans les tables globales.

Resultats attendus:

```text
Clients = 5
Commandes = 7
Produits = 6
LigneCommandes = 9
```

### 16.2 Verification des Scenarios

Scenario 1:

```text
Site1 = 3 lignes
Site2 = 3 lignes
```

Scenario 2:

```text
Site1 = 4 lignes
Site2 = 5 lignes
```

### 16.3 Verification des Triggers

Les triggers doivent etre valides:

```text
SYC_INSERT_LIGNE
SYC_DELETE_LIGNE
SYC_UPDATE_LIGNE
```

### 16.4 Verification de la Requete Distribuee

La requete distribuee retourne le chiffre d'affaires par categorie:

```text
20    321300
35    132215
50    7342755
70     71600
```

## 17. Comment Presenter le Projet

Pendant la presentation, il est possible de suivre cet ordre:

1. Montrer le schema global: `Clients`, `Commandes`, `Produits`, `LigneCommandes`.
2. Expliquer que Site1 et Site2 simulent deux sites distribues.
3. Executer le scenario 1.
4. Executer le scenario 2.
5. Montrer les procedures dans les packages `Site1` et `Site2`.
6. Montrer les triggers globaux.
7. Executer la requete d'optimisation avec `EXPLAIN PLAN`.
8. Montrer l'utilisation de l'index.
9. Executer la requete distribuee.
10. Conclure sur l'interet de la fragmentation et de la synchronisation.

## 18. Conclusion

Ce projet montre comment une base de donnees EShop peut etre organisee dans un contexte distribue avec Oracle.

La table globale `LigneCommandes` est fragmentee horizontalement selon deux scenarios. Les tables `LigneCommandes1` et `LigneCommandes2` representent les fragments stockes sur deux sites differents.

Les procedures stockees permettent de manipuler les donnees dans chaque site tout en respectant les contraintes d'integrite. Les triggers permettent de synchroniser automatiquement les operations effectuees sur la base globale avec les sites locaux.

Enfin, l'utilisation de `EXPLAIN PLAN`, des indexes et d'une requete distribuee montre comment analyser et optimiser les performances dans une base Oracle.

Le projet est dockerise, ce qui le rend facilement executable sur une autre machine.

## 19. Annexes: Commandes Utiles

Demarrer le projet:

```powershell
docker compose up -d
```

Voir les logs:

```powershell
docker logs -f eshop-oracle
```

Connexion SQL*Plus:

```powershell
docker exec -it eshop-oracle sqlplus eshop/eshop@FREEPDB1
```

Executer le scenario 1:

```sql
@/container-entrypoint-initdb.d/05_fragmentation_scenario1.sql
```

Executer le scenario 2:

```sql
@/container-entrypoint-initdb.d/06_fragmentation_scenario2.sql
```

Executer l'optimisation:

```sql
@/container-entrypoint-initdb.d/10_queries_optimization.sql
```

Executer la requete distribuee:

```sql
@/container-entrypoint-initdb.d/11_distributed_query.sql
```

Verification rapide:

```sql
@/container-entrypoint-initdb.d/12_demo_check.sql
```

Reinitialiser completement:

```powershell
docker compose down -v
docker compose up -d
```
