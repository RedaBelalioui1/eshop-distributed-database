-- ============================================================
-- 06_fragmentation_scenario2_sqldeveloper.sql
-- Version Oracle SQL Developer.
-- Important: connectez-vous d'abord avec la connexion EShop,
-- puis executez ce fichier avec F5. Il ne contient pas CONNECT.
-- ============================================================

SET ECHO ON

UPDATE Fragmentation_Config
SET scenario = 2,
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

-- Site1: quantite >= 100.
INSERT INTO Clients1
SELECT DISTINCT c.*
FROM Clients c
JOIN Commandes co ON co.idclient = c.idclient
JOIN LigneCommandes lc ON lc.idcommande = co.idcommande
WHERE lc.quantite >= 100;

INSERT INTO Produits1
SELECT DISTINCT p.*
FROM Produits p
JOIN LigneCommandes lc ON lc.idproduit = p.idproduit
WHERE lc.quantite >= 100;

INSERT INTO Commandes1
SELECT DISTINCT co.*
FROM Commandes co
JOIN LigneCommandes lc ON lc.idcommande = co.idcommande
WHERE lc.quantite >= 100;

INSERT INTO LigneCommandes1
SELECT *
FROM LigneCommandes
WHERE quantite >= 100;

-- Site2: quantite < 100.
INSERT INTO Clients2
SELECT DISTINCT c.*
FROM Clients c
JOIN Commandes co ON co.idclient = c.idclient
JOIN LigneCommandes lc ON lc.idcommande = co.idcommande
WHERE lc.quantite < 100;

INSERT INTO Produits2
SELECT DISTINCT p.*
FROM Produits p
JOIN LigneCommandes lc ON lc.idproduit = p.idproduit
WHERE lc.quantite < 100;

INSERT INTO Commandes2
SELECT DISTINCT co.*
FROM Commandes co
JOIN LigneCommandes lc ON lc.idcommande = co.idcommande
WHERE lc.quantite < 100;

INSERT INTO LigneCommandes2
SELECT *
FROM LigneCommandes
WHERE quantite < 100;

COMMIT;

SELECT 'SCENARIO 2 - SITE1 rows' AS label, COUNT(*) AS nb_lignes FROM LigneCommandes1;
SELECT 'SCENARIO 2 - SITE2 rows' AS label, COUNT(*) AS nb_lignes FROM LigneCommandes2;
