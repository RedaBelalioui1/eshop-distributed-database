-- ============================================================
-- 11_distributed_query.sql
-- Distributed query exercise: total revenue per product category in 2026.
-- This local Docker project simulates remote sites with Site1/Site2 tables.
-- In a real distributed Oracle deployment, the same blocks could read:
--   LigneCommandes1@SITE1_LINK, Commandes1@SITE1_LINK, Produits1@SITE1_LINK
--   LigneCommandes2@SITE2_LINK, Commandes2@SITE2_LINK, Produits2@SITE2_LINK
-- ============================================================

SET ECHO ON
SET LINESIZE 180
SET PAGESIZE 80

CONNECT eshop/eshop@FREEPDB1

-- Simulated distributed views.
CREATE OR REPLACE VIEW v_site1_revenue_2026 AS
SELECT
  p.idcateg,
  lc.quantite * p.prixunitaire * (1 - lc.remise) AS revenue
FROM LigneCommandes1 lc
JOIN Commandes1 co ON co.idcommande = lc.idcommande
JOIN Produits1 p ON p.idproduit = lc.idproduit
WHERE co.datecommande >= DATE '2026-01-01'
  AND co.datecommande < DATE '2027-01-01';

CREATE OR REPLACE VIEW v_site2_revenue_2026 AS
SELECT
  p.idcateg,
  lc.quantite * p.prixunitaire * (1 - lc.remise) AS revenue
FROM LigneCommandes2 lc
JOIN Commandes2 co ON co.idcommande = lc.idcommande
JOIN Produits2 p ON p.idproduit = lc.idproduit
WHERE co.datecommande >= DATE '2026-01-01'
  AND co.datecommande < DATE '2027-01-01';

-- Distributed-style query. UNION ALL avoids a duplicate-elimination sort.
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

-- Database-link style version for a real two-site deployment:
-- SELECT idcateg, ROUND(SUM(revenue), 2) AS chiffre_affaires_2026
-- FROM (
--   SELECT p.idcateg,
--          lc.quantite * p.prixunitaire * (1 - lc.remise) AS revenue
--   FROM LigneCommandes1@SITE1_LINK lc
--   JOIN Commandes1@SITE1_LINK co ON co.idcommande = lc.idcommande
--   JOIN Produits1@SITE1_LINK p ON p.idproduit = lc.idproduit
--   WHERE co.datecommande >= DATE '2026-01-01'
--     AND co.datecommande < DATE '2027-01-01'
--   UNION ALL
--   SELECT p.idcateg,
--          lc.quantite * p.prixunitaire * (1 - lc.remise) AS revenue
--   FROM LigneCommandes2@SITE2_LINK lc
--   JOIN Commandes2@SITE2_LINK co ON co.idcommande = lc.idcommande
--   JOIN Produits2@SITE2_LINK p ON p.idproduit = lc.idproduit
--   WHERE co.datecommande >= DATE '2026-01-01'
--     AND co.datecommande < DATE '2027-01-01'
-- )
-- GROUP BY idcateg
-- ORDER BY idcateg;
