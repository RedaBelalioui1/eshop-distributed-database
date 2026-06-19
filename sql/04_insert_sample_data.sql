-- ============================================================
-- 04_insert_sample_data.sql
-- Realistic EShop sample data, including several 2026 orders.
-- ============================================================

SET ECHO ON

CONNECT eshop/eshop@FREEPDB1

INSERT INTO Clients VALUES (1, 'CL001', 'Atlas Digital SARL', 'Nadia Amrani', 'Casablanca', 'Maroc', '+212522100001');
INSERT INTO Clients VALUES (2, 'CL002', 'Nord Market', 'Youssef Bennani', 'Rabat', 'Maroc', '+212537200002');
INSERT INTO Clients VALUES (3, 'CL003', 'MediTech Store', 'Samira El Fassi', 'Tanger', 'Maroc', '+212539300003');
INSERT INTO Clients VALUES (4, 'CL004', 'Sahara Retail', 'Karim El Mansouri', 'Marrakech', 'Maroc', '+212524400004');
INSERT INTO Clients VALUES (5, 'CL005', 'Blue Office', 'Leila Ziani', 'Fes', 'Maroc', '+212535500005');

INSERT INTO Produits VALUES (10, 50, 'Ordinateur portable Pro 14', 12500.00);
INSERT INTO Produits VALUES (11, 50, 'Station de travail graphique', 21900.00);
INSERT INTO Produits VALUES (12, 35, 'Clavier mecanique AZERTY', 850.00);
INSERT INTO Produits VALUES (13, 35, 'Souris ergonomique sans fil', 420.00);
INSERT INTO Produits VALUES (14, 20, 'Ecran 27 pouces QHD', 3150.00);
INSERT INTO Produits VALUES (15, 70, 'Routeur WiFi professionnel', 1790.00);

INSERT INTO Commandes VALUES (1001, 201, 1, DATE '2026-01-12', '12 Rue Anfa', 'Casablanca', 'Maroc');
INSERT INTO Commandes VALUES (1002, 202, 2, DATE '2026-02-03', '44 Avenue Hassan II', 'Rabat', 'Maroc');
INSERT INTO Commandes VALUES (1003, 203, 3, DATE '2026-03-18', '7 Zone Franche', 'Tanger', 'Maroc');
INSERT INTO Commandes VALUES (1004, 204, 1, DATE '2026-04-22', '12 Rue Anfa', 'Casablanca', 'Maroc');
INSERT INTO Commandes VALUES (1005, 205, 4, DATE '2026-05-09', '88 Gueliz', 'Marrakech', 'Maroc');
INSERT INTO Commandes VALUES (1006, 206, 5, DATE '2025-12-28', '19 Avenue Mohammed V', 'Fes', 'Maroc');
INSERT INTO Commandes VALUES (1007, 207, 2, DATE '2026-08-14', '44 Avenue Hassan II', 'Rabat', 'Maroc');

-- Lines cover both requested fragmentation scenarios.
-- 5001: categ 50, Site1 scenario 1, Site1 scenario 2.
INSERT INTO LigneCommandes VALUES (5001, 1001, 10, 150, 0.0500);
-- 5002: categ 35, Site2 scenario 1, Site2 scenario 2.
INSERT INTO LigneCommandes VALUES (5002, 1001, 12, 80, 0.1000);
-- 5003: no scenario 1 fragment, Site2 scenario 2.
INSERT INTO LigneCommandes VALUES (5003, 1002, 11, 95, 0.0700);
-- 5004: categ 35, Site2 scenario 1, Site2 scenario 2.
INSERT INTO LigneCommandes VALUES (5004, 1003, 13, 60, 0.0000);
-- 5005: no scenario 1 fragment, Site1 scenario 2.
INSERT INTO LigneCommandes VALUES (5005, 1004, 14, 120, 0.1500);
-- 5006: no scenario 1 fragment, Site2 scenario 2.
INSERT INTO LigneCommandes VALUES (5006, 1005, 15, 40, 0.0000);
-- 5007: previous year, useful for date filtering.
INSERT INTO LigneCommandes VALUES (5007, 1006, 10, 130, 0.0300);
-- 5008: categ 35, Site2 scenario 1, Site2 scenario 2.
INSERT INTO LigneCommandes VALUES (5008, 1007, 12, 55, 0.0200);
-- 5009: categ 50, Site1 scenario 1, Site1 scenario 2.
INSERT INTO LigneCommandes VALUES (5009, 1007, 11, 180, 0.0800);

COMMIT;
