-- ============================================================
-- 12_demo_check.sql
-- Quick verification script for the professor.
-- It shows global data, active fragmentation, triggers, and revenue.
-- ============================================================

SET ECHO ON
SET LINESIZE 180
SET PAGESIZE 100

CONNECT eshop/eshop@FREEPDB1

PROMPT === Global table counts ===
SELECT 'Clients' AS table_name, COUNT(*) AS rows_count FROM Clients
UNION ALL
SELECT 'Commandes', COUNT(*) FROM Commandes
UNION ALL
SELECT 'Produits', COUNT(*) FROM Produits
UNION ALL
SELECT 'LigneCommandes', COUNT(*) FROM LigneCommandes;

PROMPT === Active fragmentation scenario ===
SELECT scenario, updated_at FROM Fragmentation_Config WHERE id_config = 1;

PROMPT === Site fragment counts ===
SELECT 'LigneCommandes1' AS fragment, COUNT(*) AS rows_count FROM LigneCommandes1
UNION ALL
SELECT 'LigneCommandes2', COUNT(*) FROM LigneCommandes2;

PROMPT === Trigger status ===
SELECT trigger_name, status
FROM user_triggers
WHERE trigger_name IN ('SYC_INSERT_LIGNE', 'SYC_DELETE_LIGNE', 'SYC_UPDATE_LIGNE')
ORDER BY trigger_name;

PROMPT === Stored package status ===
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('SITE1', 'SITE2')
ORDER BY object_name, object_type;

PROMPT === Distributed revenue per product category in 2026 ===
SELECT
  idcateg,
  ROUND(SUM(revenue), 2) AS chiffre_affaires_2026
FROM (
  SELECT idcateg, revenue FROM v_site1_revenue_2026
  UNION ALL
  SELECT idcateg, revenue FROM v_site2_revenue_2026
)
GROUP BY idcateg
ORDER BY idcateg;
