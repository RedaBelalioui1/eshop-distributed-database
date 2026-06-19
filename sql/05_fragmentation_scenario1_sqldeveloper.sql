-- ============================================================
-- 05_fragmentation_scenario1_sqldeveloper.sql
-- Version Oracle SQL Developer.
-- Important: connectez-vous d'abord avec la connexion EShop,
-- puis executez ce fichier avec F5. Il ne contient pas CONNECT.
-- ============================================================

SET ECHO ON

UPDATE Fragmentation_Config
SET scenario = 1,
    updated_at = SYSTIMESTAMP
WHERE id_config = 1;

DELETE FROM LigneCommandes1;
DELETE FROM Commandes1;
DELETE FROM Produits1;
DELETE FROM Clients1;

DELETE FROM LigneCommandes2;
DELETE FROM Commandes2;
DELETE FROM Produits2;
DELETE FROM Clients2;

-- Site1: categorie 50 et quantite > 100.
INSERT INTO Clients1
SELECT DISTINCT c.*
FROM Clients c
JOIN Commandes co ON co.idclient = c.idclient
JOIN LigneCommandes lc ON lc.idcommande = co.idcommande
JOIN Produits p ON p.idproduit = lc.idproduit
WHERE p.idcateg = 50
  AND lc.quantite > 100;

INSERT INTO Produits1
SELECT DISTINCT p.*
FROM Produits p
JOIN LigneCommandes lc ON lc.idproduit = p.idproduit
WHERE p.idcateg = 50
  AND lc.quantite > 100;

INSERT INTO Commandes1
SELECT DISTINCT co.*
FROM Commandes co
JOIN LigneCommandes lc ON lc.idcommande = co.idcommande
JOIN Produits p ON p.idproduit = lc.idproduit
WHERE p.idcateg = 50
  AND lc.quantite > 100;

INSERT INTO LigneCommandes1
SELECT lc.*
FROM LigneCommandes lc
JOIN Produits p ON p.idproduit = lc.idproduit
WHERE p.idcateg = 50
  AND lc.quantite > 100;

-- Site2: categorie 35 et quantite > 50.
INSERT INTO Clients2
SELECT DISTINCT c.*
FROM Clients c
JOIN Commandes co ON co.idclient = c.idclient
JOIN LigneCommandes lc ON lc.idcommande = co.idcommande
JOIN Produits p ON p.idproduit = lc.idproduit
WHERE p.idcateg = 35
  AND lc.quantite > 50;

INSERT INTO Produits2
SELECT DISTINCT p.*
FROM Produits p
JOIN LigneCommandes lc ON lc.idproduit = p.idproduit
WHERE p.idcateg = 35
  AND lc.quantite > 50;

INSERT INTO Commandes2
SELECT DISTINCT co.*
FROM Commandes co
JOIN LigneCommandes lc ON lc.idcommande = co.idcommande
JOIN Produits p ON p.idproduit = lc.idproduit
WHERE p.idcateg = 35
  AND lc.quantite > 50;

INSERT INTO LigneCommandes2
SELECT lc.*
FROM LigneCommandes lc
JOIN Produits p ON p.idproduit = lc.idproduit
WHERE p.idcateg = 35
  AND lc.quantite > 50;

COMMIT;

SELECT 'SCENARIO 1 - SITE1 rows' AS label, COUNT(*) AS nb_lignes FROM LigneCommandes1;
SELECT 'SCENARIO 1 - SITE2 rows' AS label, COUNT(*) AS nb_lignes FROM LigneCommandes2;
