-- ============================================================
-- 09_triggers_global.sql
-- Global synchronization triggers.
-- They route global LigneCommandes DML to Site1/Site2 according to
-- Fragmentation_Config.scenario.
-- ============================================================

SET ECHO ON
SET SERVEROUTPUT ON

CONNECT eshop/eshop@FREEPDB1

CREATE OR REPLACE TRIGGER SYC_INSERT_LIGNE
AFTER INSERT ON LigneCommandes
FOR EACH ROW
DECLARE
  v_scenario Fragmentation_Config.scenario%TYPE;
  v_idcateg Produits.idcateg%TYPE;
BEGIN
  SELECT scenario
  INTO v_scenario
  FROM Fragmentation_Config
  WHERE id_config = 1;

  SELECT idcateg
  INTO v_idcateg
  FROM Produits
  WHERE idproduit = :NEW.idproduit;

  IF v_scenario = 1 THEN
    IF v_idcateg = 50 AND :NEW.quantite > 100 THEN
      Site1.insertligne(:NEW.idlignecommande, :NEW.idcommande, :NEW.idproduit, :NEW.quantite, :NEW.remise);
    ELSIF v_idcateg = 35 AND :NEW.quantite > 50 THEN
      Site2.insertligne(:NEW.idlignecommande, :NEW.idcommande, :NEW.idproduit, :NEW.quantite, :NEW.remise);
    END IF;
  ELSIF v_scenario = 2 THEN
    IF :NEW.quantite >= 100 THEN
      Site1.insertligne(:NEW.idlignecommande, :NEW.idcommande, :NEW.idproduit, :NEW.quantite, :NEW.remise);
    ELSE
      Site2.insertligne(:NEW.idlignecommande, :NEW.idcommande, :NEW.idproduit, :NEW.quantite, :NEW.remise);
    END IF;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER SYC_DELETE_LIGNE
AFTER DELETE ON LigneCommandes
FOR EACH ROW
BEGIN
  -- The old row can exist on at most one site for the active scenario,
  -- but deleting from both sites keeps the trigger idempotent after scenario changes.
  Site1.deleteligne(:OLD.idlignecommande);
  Site2.deleteligne(:OLD.idlignecommande);
END;
/

CREATE OR REPLACE TRIGGER SYC_UPDATE_LIGNE
AFTER UPDATE OF idproduit, quantite, remise ON LigneCommandes
FOR EACH ROW
DECLARE
  v_scenario Fragmentation_Config.scenario%TYPE;
  v_idcateg Produits.idcateg%TYPE;
BEGIN
  -- Re-route the line because an update can move it between fragments.
  Site1.deleteligne(:OLD.idlignecommande);
  Site2.deleteligne(:OLD.idlignecommande);

  SELECT scenario
  INTO v_scenario
  FROM Fragmentation_Config
  WHERE id_config = 1;

  SELECT idcateg
  INTO v_idcateg
  FROM Produits
  WHERE idproduit = :NEW.idproduit;

  IF v_scenario = 1 THEN
    IF v_idcateg = 50 AND :NEW.quantite > 100 THEN
      Site1.insertligne(:NEW.idlignecommande, :NEW.idcommande, :NEW.idproduit, :NEW.quantite, :NEW.remise);
    ELSIF v_idcateg = 35 AND :NEW.quantite > 50 THEN
      Site2.insertligne(:NEW.idlignecommande, :NEW.idcommande, :NEW.idproduit, :NEW.quantite, :NEW.remise);
    END IF;
  ELSIF v_scenario = 2 THEN
    IF :NEW.quantite >= 100 THEN
      Site1.insertligne(:NEW.idlignecommande, :NEW.idcommande, :NEW.idproduit, :NEW.quantite, :NEW.remise);
    ELSE
      Site2.insertligne(:NEW.idlignecommande, :NEW.idcommande, :NEW.idproduit, :NEW.quantite, :NEW.remise);
    END IF;
  END IF;
END;
/

SHOW ERRORS TRIGGER SYC_INSERT_LIGNE
SHOW ERRORS TRIGGER SYC_DELETE_LIGNE
SHOW ERRORS TRIGGER SYC_UPDATE_LIGNE

-- Quick trigger smoke test. The inserted row is routed and then removed.
INSERT INTO Commandes VALUES (1999, 299, 1, DATE '2026-09-01', 'Test trigger', 'Casablanca', 'Maroc');
INSERT INTO LigneCommandes VALUES (5999, 1999, 10, 140, 0.0000);
SELECT 'After trigger insert - Site1' AS label, COUNT(*) AS nb FROM LigneCommandes1 WHERE idlignecommande = 5999;
DELETE FROM LigneCommandes WHERE idlignecommande = 5999;
DELETE FROM Commandes WHERE idcommande = 1999;
COMMIT;
