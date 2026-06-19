# Tester le projet avec Oracle SQL Developer

Ce guide explique comment tester le projet dans Oracle SQL Developer après avoir démarré le conteneur Docker.

## 1. Démarrer Oracle avec Docker

Dans le dossier du projet:

```powershell
docker compose up -d
docker logs -f eshop-oracle
```

Attendre le message:

```text
DATABASE IS READY TO USE!
```

## 2. Créer la connexion SQL Developer

Ouvrir Oracle SQL Developer, puis créer une nouvelle connexion avec:

```text
Name: EShop
Username: eshop
Password: eshop
Hostname: localhost
Port: 1523
Service name: FREEPDB1
```

Cliquer sur `Test`.

Si le test affiche `Success`, cliquer sur `Connect`.

## 3. Visualiser les tables

Dans le panneau de gauche:

```text
Connections
└── EShop
    └── Tables
```

Les tables principales sont:

```text
CLIENTS
COMMANDES
PRODUITS
LIGNECOMMANDES
```

Les fragments du Site1 sont:

```text
CLIENTS1
COMMANDES1
PRODUITS1
LIGNECOMMANDES1
```

Les fragments du Site2 sont:

```text
CLIENTS2
COMMANDES2
PRODUITS2
LIGNECOMMANDES2
```

Pour voir les données, cliquer sur une table puis ouvrir l'onglet `Data`.

## 4. Exécuter les scripts dans SQL Developer

Ouvrir un fichier SQL depuis:

```text
sql/
```

Puis l'exécuter avec:

```text
F5
```

Important: utiliser `F5` ou le bouton `Run Script`, pas seulement `Ctrl+Enter`.

## 5. Scripts à tester

### Scénario 1

Ouvrir:

```text
sql/05_fragmentation_scenario1.sql
```

Exécuter avec `F5`.

Résultat attendu:

```text
SCENARIO 1 - SITE1 rows    3
SCENARIO 1 - SITE2 rows    3
```

### Scénario 2

Ouvrir:

```text
sql/06_fragmentation_scenario2.sql
```

Exécuter avec `F5`.

Résultat attendu:

```text
SCENARIO 2 - SITE1 rows    4
SCENARIO 2 - SITE2 rows    5
```

### Optimisation

Ouvrir:

```text
sql/10_queries_optimization.sql
```

Exécuter avec `F5`.

Le plan d'exécution doit afficher l'utilisation de l'index:

```text
INDEX RANGE SCAN IDX_COMMANDES_DATE_CLIENT
```

### Requête distribuée

Ouvrir:

```text
sql/11_distributed_query.sql
```

Exécuter avec `F5`.

Résultat attendu:

```text
IDCATEG    CHIFFRE_AFFAIRES_2026
20         321300
35         132215
50         7342755
70         71600
```

### Vérification rapide

Ouvrir:

```text
sql/12_demo_check.sql
```

Exécuter avec `F5`.

Ce script affiche:

- le nombre de lignes dans les tables globales
- le scénario actif
- le nombre de lignes dans les fragments
- l'état des triggers
- l'état des packages PL/SQL
- le chiffre d'affaires distribué par catégorie

## 6. Visualiser le modèle relationnel

Dans Oracle SQL Developer:

1. Aller dans `View`
2. Ouvrir `Data Modeler`
3. Choisir `Import`
4. Choisir `Data Dictionary`
5. Sélectionner la connexion `EShop`
6. Sélectionner le schéma `ESHOP`
7. Importer les tables du projet

SQL Developer affiche alors un diagramme avec les tables, les clés primaires et les clés étrangères.

## 7. Afficher un plan d'exécution visuel

Dans un SQL Worksheet, coller:

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

Puis cliquer sur `Explain Plan` ou appuyer sur:

```text
F10
```

SQL Developer affichera le plan d'exécution sous forme visuelle.

## 8. Erreurs fréquentes

Si la connexion échoue, vérifier que Docker est démarré et que le conteneur est prêt:

```powershell
docker ps
docker logs eshop-oracle
```

Si le port `1523` est occupé, modifier `docker-compose.yml`:

```yaml
1524:1521
```

Puis utiliser le port `1524` dans SQL Developer.

Si les scripts ont déjà été exécutés, certaines données peuvent déjà exister. Pour repartir de zéro:

```powershell
docker compose down -v
docker compose up -d
```
