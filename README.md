# EShop Distributed Database Project

Projet Oracle PL/SQL pour une base de données EShop distribuée. Il montre une fragmentation horizontale sur deux sites, des procédures stockées, des triggers de synchronisation globale, des plans d'exécution, des indexes d'optimisation et une requête distribuée simulée.

## Références Docker Oracle

Le projet utilise `gvenzl/oracle-free:23-slim`, une image Oracle Database Free compatible avec un usage local simple. Oracle publie aussi des images officielles Oracle Database Free sur son Container Registry, avec un service `FREE` et une PDB `FREEPDB1` écoutant sur le port `1521`.

Sources à citer dans le rapport:

- [Oracle Database Free - Container Registry](https://container-registry.oracle.com/ords/ocr/ba/database/free)
- [Tutoriel Oracle: Get Started with Oracle Database Free](https://docs.oracle.com/en/learn/ol-db-free/)
- [Docker Hub: gvenzl/oracle-free](https://hub.docker.com/r/gvenzl/oracle-free)

## Structure

```text
.
├── docker-compose.yml
├── README.md
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

## Lancement avec Docker

```bash
docker compose up -d
```

Au premier démarrage, les scripts dans `sql/` sont exécutés dans l'ordre par le conteneur. Les données Oracle sont gardées dans le volume `oracle-data`.

Pour suivre l'initialisation:

```bash
docker logs -f eshop-oracle
```

## Connexion à Oracle

Depuis le conteneur:

```bash
docker exec -it eshop-oracle sqlplus eshop/eshop@FREEPDB1
```

Depuis SQL Developer, DBeaver ou DataGrip:

- Host: `localhost`
- Port: `1523`
- Service name: `FREEPDB1`
- User: `eshop`
- Password: `eshop`

Le compte administrateur de l'image est disponible avec le mot de passe `oracle`.

## Exécuter les scripts manuellement

Si le volume existe déjà, les scripts d'initialisation ne sont pas rejoués automatiquement. Pour repartir de zéro:

```bash
docker compose down -v
docker compose up -d
```

Pour exécuter un script précis:

```bash
docker exec -it eshop-oracle sqlplus eshop/eshop@FREEPDB1 @/container-entrypoint-initdb.d/05_fragmentation_scenario1.sql
```

Pour vérifier rapidement le projet après démarrage:

```bash
docker exec -it eshop-oracle sqlplus eshop/eshop@FREEPDB1 @/container-entrypoint-initdb.d/12_demo_check.sql
```

Pour tester avec Oracle SQL Developer, voir aussi:

```text
SUBMISSION_SQL_DEVELOPER.md
```

## Modèle de données

La base globale contient:

- `Clients(idclient, codeclient, societe, contact, ville, pays, telephone)`
- `Commandes(idcommande, idemploye, idclient, datecommande, adresse_livraison, ville_livraison, pays_livraison)`
- `Produits(idproduit, idcateg, designation, prixunitaire)`
- `LigneCommandes(idlignecommande, idcommande, idproduit, quantite, remise)`

Les sites locaux contiennent les mêmes tuples référencés, avec suffixes `1` et `2`: `Clients1`, `Commandes1`, `Produits1`, `LigneCommandes1`, puis `Clients2`, `Commandes2`, `Produits2`, `LigneCommandes2`.

Toutes les colonnes `id...` principales ont une clé primaire. `Commandes` référence `Clients`, et `LigneCommandes` référence `Commandes` et `Produits`.

## Fragmentation horizontale

Le scénario actif est stocké dans `Fragmentation_Config`.

Scénario 1:

- Site1: lignes dont le produit est en catégorie `50` et `quantite > 100`
- Site2: lignes dont le produit est en catégorie `35` et `quantite > 50`

Le PDF parle de `idCategorie` sur `LigneCommandes`; dans ce modèle normalisé, la catégorie est portée par `Produits.idcateg`.

Scénario 2:

- Site1: `quantite >= 100`
- Site2: `quantite < 100`

Pour activer un scénario:

```sql
@/container-entrypoint-initdb.d/05_fragmentation_scenario1.sql
-- ou
@/container-entrypoint-initdb.d/06_fragmentation_scenario2.sql
```

## Procédures stockées

Les procédures demandées existent dans deux packages PL/SQL:

- `Site1.insertligne`, `Site1.deleteligne`, `Site1.updateligne`
- `Site2.insertligne`, `Site2.deleteligne`, `Site2.updateligne`

`insertligne` copie d'abord les tuples référencés nécessaires depuis les tables globales vers le site local, puis insère la ligne. `deleteligne` supprime la ligne et nettoie les commandes/clients locaux orphelins. `updateligne` modifie `idproduit`, `quantite` et `remise`.

## Triggers globaux

Les triggers sont créés sur `LigneCommandes`:

- `SYC_INSERT_LIGNE`
- `SYC_DELETE_LIGNE`
- `SYC_UPDATE_LIGNE`

Ils lisent `Fragmentation_Config.scenario` et routent les insertions, suppressions et mises à jour vers `Site1` ou `Site2`. Une mise à jour peut déplacer une ligne d'un fragment à l'autre.

## Optimisation

La requête demandée calcule le nombre de commandes par client en 2026:

```sql
SELECT c.idclient, c.codeclient, c.societe, COUNT(co.idcommande) AS nombre_commandes_2026
FROM Clients c
JOIN Commandes co ON co.idclient = c.idclient
WHERE co.datecommande >= DATE '2026-01-01'
  AND co.datecommande < DATE '2027-01-01'
GROUP BY c.idclient, c.codeclient, c.societe
ORDER BY nombre_commandes_2026 DESC, c.societe;
```

Le script `10_queries_optimization.sql` lance:

```sql
EXPLAIN PLAN FOR ...
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

Indexes ajoutés:

- `idx_commandes_date_client(datecommande, idclient)`: réduit le coût du filtre temporel sur 2026 et prépare la jointure par client.
- `idx_commandes_client(idclient)`: utile pour les jointures fréquentes depuis `Clients` vers `Commandes`.

Les opérations coûteuses attendues avant optimisation sont les scans complets, les jointures et les tris `GROUP BY`/`ORDER BY`.

## Requête distribuée

Le script `11_distributed_query.sql` calcule le chiffre d'affaires par catégorie en 2026:

```sql
revenue = quantite * prixunitaire * (1 - remise)
```

La version locale utilise `v_site1_revenue_2026` et `v_site2_revenue_2026`, puis fait un `UNION ALL`. Le script contient aussi la version commentée avec une syntaxe de type:

```sql
LigneCommandes1@SITE1_LINK
LigneCommandes2@SITE2_LINK
```

## Résultats attendus

Emplacements pour captures d'écran dans le rapport:

- Capture 1: `docker compose up -d` puis conteneur `eshop-oracle` healthy.
- Capture 2: résultat de `SELECT COUNT(*) FROM LigneCommandes1` et `LigneCommandes2` après scénario 1.
- Capture 3: résultat après scénario 2.
- Capture 4: sortie `DBMS_XPLAN.DISPLAY` avant et après indexes.
- Capture 5: chiffre d'affaires par catégorie via la requête distribuée.

## Erreurs fréquentes

`ORA-01017: invalid username/password`: vérifier `eshop/eshop@FREEPDB1` et attendre que le conteneur soit healthy.

`ORA-12514` ou service introuvable: attendre la fin de l'initialisation, puis réessayer avec le service `FREEPDB1`.

Les scripts ne se relancent pas au redémarrage: supprimer le volume avec `docker compose down -v`.

Port déjà utilisé: le projet expose déjà Oracle sur le port local `1523` avec `"1523:1521"` dans `docker-compose.yml`. Si `1523` est aussi occupé, utiliser par exemple `"1524:1521"`, puis se connecter sur ce nouveau port local.

Image non téléchargée: vérifier l'accès Internet Docker. Une alternative officielle est `container-registry.oracle.com/database/free:latest-lite`.
