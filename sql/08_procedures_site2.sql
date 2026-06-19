-- ============================================================
-- 08_procedures_site2.sql
-- Site2 PL/SQL API. Procedure names match Site1 inside package Site2.
-- ============================================================

SET ECHO ON
SET SERVEROUTPUT ON

CONNECT eshop/eshop@FREEPDB1

CREATE OR REPLACE PACKAGE Site2 AS
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
END Site2;
/

CREATE OR REPLACE PACKAGE BODY Site2 AS
  PROCEDURE ensure_references(
    p_idcommande IN NUMBER,
    p_idproduit IN NUMBER
  ) IS
  BEGIN
    INSERT INTO Clients2
    SELECT c.*
    FROM Clients c
    JOIN Commandes co ON co.idclient = c.idclient
    WHERE co.idcommande = p_idcommande
      AND NOT EXISTS (
        SELECT 1 FROM Clients2 c2 WHERE c2.idclient = c.idclient
      );

    INSERT INTO Produits2
    SELECT p.*
    FROM Produits p
    WHERE p.idproduit = p_idproduit
      AND NOT EXISTS (
        SELECT 1 FROM Produits2 p2 WHERE p2.idproduit = p.idproduit
      );

    INSERT INTO Commandes2
    SELECT co.*
    FROM Commandes co
    WHERE co.idcommande = p_idcommande
      AND NOT EXISTS (
        SELECT 1 FROM Commandes2 co2 WHERE co2.idcommande = co.idcommande
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

    INSERT INTO LigneCommandes2 (
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
    v_idcommande Commandes2.idcommande%TYPE;
    v_idclient Clients2.idclient%TYPE;
    v_idproduit Produits2.idproduit%TYPE;
  BEGIN
    SELECT lc.idcommande, co.idclient, lc.idproduit
    INTO v_idcommande, v_idclient, v_idproduit
    FROM LigneCommandes2 lc
    JOIN Commandes2 co ON co.idcommande = lc.idcommande
    WHERE lc.idlignecommande = p_idlignecommande;

    DELETE FROM LigneCommandes2
    WHERE idlignecommande = p_idlignecommande;

    -- Remove local orphan tuples generated only for this fragment.
    DELETE FROM Commandes2 co
    WHERE co.idcommande = v_idcommande
      AND NOT EXISTS (
        SELECT 1 FROM LigneCommandes2 lc WHERE lc.idcommande = co.idcommande
      );

    DELETE FROM Clients2 c
    WHERE c.idclient = v_idclient
      AND NOT EXISTS (
        SELECT 1 FROM Commandes2 co WHERE co.idclient = c.idclient
      );

    DELETE FROM Produits2 p
    WHERE p.idproduit = v_idproduit
      AND NOT EXISTS (
        SELECT 1 FROM LigneCommandes2 lc WHERE lc.idproduit = p.idproduit
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
    v_idcommande LigneCommandes2.idcommande%TYPE;
  BEGIN
    SELECT idcommande
    INTO v_idcommande
    FROM LigneCommandes2
    WHERE idlignecommande = p_idlignecommande;

    ensure_references(v_idcommande, p_idproduit);

    UPDATE LigneCommandes2
    SET idproduit = p_idproduit,
        quantite = p_quantite,
        remise = p_remise
    WHERE idlignecommande = p_idlignecommande;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END updateligne;
END Site2;
/

SHOW ERRORS PACKAGE Site2
SHOW ERRORS PACKAGE BODY Site2
