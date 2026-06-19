-- ============================================================
-- 10_queries_optimization.sql
-- Query optimization exercise: orders per client in 2026.
-- Includes initial plan, index creation, and improved plan.
-- ============================================================

SET ECHO ON
SET LINESIZE 180
SET PAGESIZE 80

CONNECT eshop/eshop@FREEPDB1

-- Make this script repeatable for demonstrations.
BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX idx_commandes_date_client';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1418 THEN
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX idx_commandes_client';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1418 THEN
      RAISE;
    END IF;
END;
/

-- Query: number of orders per client made in 2026.
-- Date filtering uses a half-open interval so Oracle can use an index on datecommande.
EXPLAIN PLAN FOR
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

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Expected costly operations before indexes:
-- 1) TABLE ACCESS FULL on COMMANDES can appear because the optimizer has no selective date index.
-- 2) HASH JOIN or NESTED LOOPS may join CLIENTS and COMMANDES depending on statistics.
-- 3) SORT GROUP BY and SORT ORDER BY are expected because the query aggregates then orders.

-- Useful indexes and justifications:
-- IDX_COMMANDES_DATE_CLIENT helps the 2026 date range filter and then joins/grouping by idclient.
-- IDX_COMMANDES_CLIENT helps joins from Clients to Commandes in other access paths.
-- The primary key on Clients(idclient) already supports lookup of client rows.
CREATE INDEX idx_commandes_date_client
  ON Commandes (datecommande, idclient);

CREATE INDEX idx_commandes_client
  ON Commandes (idclient);

-- Gather fresh statistics so the execution plan can choose the new indexes.
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'CLIENTS');
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'COMMANDES');
END;
/

EXPLAIN PLAN FOR
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

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Final result set for screenshots.
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
