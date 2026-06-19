-- ============================================================
-- 03_create_site2_schema.sql
-- Site2 local fragment tables.
-- ============================================================

SET ECHO ON

CONNECT eshop/eshop@FREEPDB1

CREATE TABLE Clients2 (
  idclient NUMBER NOT NULL,
  codeclient VARCHAR2(20) NOT NULL,
  societe VARCHAR2(120) NOT NULL,
  contact VARCHAR2(120),
  ville VARCHAR2(80),
  pays VARCHAR2(80),
  telephone VARCHAR2(30),
  CONSTRAINT pk_clients2 PRIMARY KEY (idclient),
  CONSTRAINT uk_clients2_code UNIQUE (codeclient)
);

CREATE TABLE Produits2 (
  idproduit NUMBER NOT NULL,
  idcateg NUMBER NOT NULL,
  designation VARCHAR2(160) NOT NULL,
  prixunitaire NUMBER(10, 2) NOT NULL,
  CONSTRAINT pk_produits2 PRIMARY KEY (idproduit),
  CONSTRAINT ck_produits2_prix CHECK (prixunitaire >= 0)
);

CREATE TABLE Commandes2 (
  idcommande NUMBER NOT NULL,
  idemploye NUMBER NOT NULL,
  idclient NUMBER NOT NULL,
  datecommande DATE NOT NULL,
  adresse_livraison VARCHAR2(200),
  ville_livraison VARCHAR2(80),
  pays_livraison VARCHAR2(80),
  CONSTRAINT pk_commandes2 PRIMARY KEY (idcommande),
  CONSTRAINT fk_commandes2_clients2 FOREIGN KEY (idclient)
    REFERENCES Clients2 (idclient)
);

CREATE TABLE LigneCommandes2 (
  idlignecommande NUMBER NOT NULL,
  idcommande NUMBER NOT NULL,
  idproduit NUMBER NOT NULL,
  quantite NUMBER NOT NULL,
  remise NUMBER(5, 4) DEFAULT 0 NOT NULL,
  CONSTRAINT pk_lignecommandes2 PRIMARY KEY (idlignecommande),
  CONSTRAINT fk_ligne2_commandes2 FOREIGN KEY (idcommande)
    REFERENCES Commandes2 (idcommande),
  CONSTRAINT fk_ligne2_produits2 FOREIGN KEY (idproduit)
    REFERENCES Produits2 (idproduit),
  CONSTRAINT ck_ligne2_quantite CHECK (quantite > 0),
  CONSTRAINT ck_ligne2_remise CHECK (remise >= 0 AND remise < 1)
);

COMMIT;
