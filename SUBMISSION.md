# Instructions rapides pour tester le projet

## Prérequis

- Docker Desktop installé et démarré.
- Un terminal ouvert dans le dossier du projet.

## Démarrage

```powershell
docker compose up -d
docker logs -f eshop-oracle
```

Attendre le message:

```text
DATABASE IS READY TO USE!
```

## Connexion SQL*Plus

```powershell
docker exec -it eshop-oracle sqlplus eshop/eshop@FREEPDB1
```

## Scripts de démonstration

Dans SQL*Plus:

```sql
@/container-entrypoint-initdb.d/05_fragmentation_scenario1.sql
@/container-entrypoint-initdb.d/06_fragmentation_scenario2.sql
@/container-entrypoint-initdb.d/10_queries_optimization.sql
@/container-entrypoint-initdb.d/11_distributed_query.sql
@/container-entrypoint-initdb.d/12_demo_check.sql
```

## Connexion Oracle SQL Developer

- Host: `localhost`
- Port: `1523`
- Service name: `FREEPDB1`
- Username: `eshop`
- Password: `eshop`

Pour un guide détaillé SQL Developer, voir:

```text
SUBMISSION_SQL_DEVELOPER.md
```

## Réinitialisation complète

Si le professeur veut relancer l'initialisation depuis zéro:

```powershell
docker compose down -v
docker compose up -d
```

## Remarque port

Le projet expose Oracle sur le port local `1523`:

```yaml
1523:1521
```

Si ce port est occupé, changer uniquement la partie gauche, par exemple:

```yaml
1524:1521
```
