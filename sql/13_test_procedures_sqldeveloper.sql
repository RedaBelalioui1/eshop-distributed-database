-- ============================================================
-- 13_test_procedures_sqldeveloper.sql
-- Test des procedures stockees Site1 et Site2 dans SQL Developer.
-- Important: connectez-vous d'abord avec la connexion EShop,
-- puis executez ce fichier avec F5. Il ne contient pas CONNECT.
-- ============================================================

SET ECHO ON
SET SERVEROUTPUT ON
SET LINESIZE 180
SET PAGESIZE 100

PROMPT === Verification des packages PL/SQL ===
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('SITE1', 'SITE2')
ORDER BY object_name, object_type;

PROMPT === Nettoyage des anciennes lignes de test ===
BEGIN
  Site1.deleteligne(7001);
  Site2.deleteligne(7002);
END;
/

COMMIT;

PROMPT === Test Site1.insertligne ===
BEGIN
  Site1.insertligne(
    p_idlignecommande => 7001,
    p_idcommande      => 1001,
    p_idproduit       => 10,
    p_quantite        => 150,
    p_remise          => 0.0500
  );
END;
/

SELECT idlignecommande, idcommande, idproduit, quantite, remise
FROM LigneCommandes1
WHERE idlignecommande = 7001;

PROMPT === Test Site1.updateligne ===
BEGIN
  Site1.updateligne(
    p_idlignecommande => 7001,
    p_idproduit       => 12,
    p_quantite        => 180,
    p_remise          => 0.1000
  );
END;
/

SELECT idlignecommande, idcommande, idproduit, quantite, remise
FROM LigneCommandes1
WHERE idlignecommande = 7001;

PROMPT === Test Site1.deleteligne ===
BEGIN
  Site1.deleteligne(7001);
END;
/

SELECT COUNT(*) AS site1_ligne_7001_restante
FROM LigneCommandes1
WHERE idlignecommande = 7001;

PROMPT === Test Site2.insertligne ===
BEGIN
  Site2.insertligne(
    p_idlignecommande => 7002,
    p_idcommande      => 1002,
    p_idproduit       => 11,
    p_quantite        => 80,
    p_remise          => 0.0700
  );
END;
/

SELECT idlignecommande, idcommande, idproduit, quantite, remise
FROM LigneCommandes2
WHERE idlignecommande = 7002;

PROMPT === Test Site2.updateligne ===
BEGIN
  Site2.updateligne(
    p_idlignecommande => 7002,
    p_idproduit       => 13,
    p_quantite        => 45,
    p_remise          => 0.0200
  );
END;
/

SELECT idlignecommande, idcommande, idproduit, quantite, remise
FROM LigneCommandes2
WHERE idlignecommande = 7002;

PROMPT === Test Site2.deleteligne ===
BEGIN
  Site2.deleteligne(7002);
END;
/

SELECT COUNT(*) AS site2_ligne_7002_restante
FROM LigneCommandes2
WHERE idlignecommande = 7002;

COMMIT;

PROMPT === Fin du test des procedures ===
