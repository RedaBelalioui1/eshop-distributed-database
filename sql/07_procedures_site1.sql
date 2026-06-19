-- ============================================================
-- 07_procedures_site1.sql
-- Site1 PL/SQL API. Procedures keep local referential integrity by
-- copying the required Client, Commande and Produit tuples from global tables.
-- ============================================================

SET ECHO ON
SET SERVEROUTPUT ON

CONNECT eshop/eshop@FREEPDB1

CREATE OR REPLACE PACKAGE Site1 AS
  PROCEDURE insertligne(
    p_idlignecommande IN NUMBER,
    p_idcommande IN NUMBER,
    p_idproduit IN NUMBER,
    p_quantite IN NUMBER,
    p_remise IN NUMBER
  );

  PROCEDURE deleteligne(
    p_idlignecommande IN NUMBER
  );

  PROCEDURE updateligne(
    p_idlignecommande IN NUMBER,
    p_idproduit IN NUMBER,
    p_quantite IN NUMBER,
    p_remise IN NUMBER
  );
END Site1;
/

CREATE OR REPLACE PACKAGE BODY Site1 AS
  PROCEDURE ensure_references(
    p_idcommande IN NUMBER,
    p_idproduit IN NUMBER
  ) IS
  BEGIN
    INSERT INTO Clients1
    SELECT c.*
    FROM Clients c
    JOIN Commandes co ON co.idclient = c.idclient
    WHERE co.idcommande = p_idcommande
      AND NOT EXISTS (
        SELECT 1 FROM Clients1 c1 WHERE c1.idclient = c.idclient
      );

    INSERT INTO Produits1
    SELECT p.*
    FROM Produits p
    WHERE p.idproduit = p_idproduit
      AND NOT EXISTS (
        SELECT 1 FROM Produits1 p1 WHERE p1.idproduit = p.idproduit
      );

    INSERT INTO Commandes1
    SELECT co.*
    FROM Commandes co
    WHERE co.idcommande = p_idcommande
      AND NOT EXISTS (
        SELECT 1 FROM Commandes1 co1 WHERE co1.idcommande = co.idcommande
      );
  END ensure_references;

  PROCEDURE insertligne(
    p_idlignecommande IN NUMBER,
    p_idcommande IN NUMBER,
    p_idproduit IN NUMBER,
    p_quantite IN NUMBER,
    p_remise IN NUMBER
  ) IS
  BEGIN
    ensure_references(p_idcommande, p_idproduit);

    INSERT INTO LigneCommandes1 (
      idlignecommande, idcommande, idproduit, quantite, remise
    ) VALUES (
      p_idlignecommande, p_idcommande, p_idproduit, p_quantite, p_remise
    );
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      updateligne(p_idlignecommande, p_idproduit, p_quantite, p_remise);
  END insertligne;

  PROCEDURE deleteligne(
    p_idlignecommande IN NUMBER
  ) IS
    v_idcommande Commandes1.idcommande%TYPE;
    v_idclient Clients1.idclient%TYPE;
    v_idproduit Produits1.idproduit%TYPE;
  BEGIN
    SELECT lc.idcommande, co.idclient, lc.idproduit
    INTO v_idcommande, v_idclient, v_idproduit
    FROM LigneCommandes1 lc
    JOIN Commandes1 co ON co.idcommande = lc.idcommande
    WHERE lc.idlignecommande = p_idlignecommande;

    DELETE FROM LigneCommandes1
    WHERE idlignecommande = p_idlignecommande;

    -- Remove local orphan tuples generated only for this fragment.
    DELETE FROM Commandes1 co
    WHERE co.idcommande = v_idcommande
      AND NOT EXISTS (
        SELECT 1 FROM LigneCommandes1 lc WHERE lc.idcommande = co.idcommande
      );

    DELETE FROM Clients1 c
    WHERE c.idclient = v_idclient
      AND NOT EXISTS (
        SELECT 1 FROM Commandes1 co WHERE co.idclient = c.idclient
      );

    DELETE FROM Produits1 p
    WHERE p.idproduit = v_idproduit
      AND NOT EXISTS (
        SELECT 1 FROM LigneCommandes1 lc WHERE lc.idproduit = p.idproduit
      );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END deleteligne;

  PROCEDURE updateligne(
    p_idlignecommande IN NUMBER,
    p_idproduit IN NUMBER,
    p_quantite IN NUMBER,
    p_remise IN NUMBER
  ) IS
    v_idcommande LigneCommandes1.idcommande%TYPE;
  BEGIN
    SELECT idcommande
    INTO v_idcommande
    FROM LigneCommandes1
    WHERE idlignecommande = p_idlignecommande;

    ensure_references(v_idcommande, p_idproduit);

    UPDATE LigneCommandes1
    SET idproduit = p_idproduit,
        quantite = p_quantite,
        remise = p_remise
    WHERE idlignecommande = p_idlignecommande;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END updateligne;
END Site1;
/

SHOW ERRORS PACKAGE Site1
SHOW ERRORS PACKAGE BODY Site1
