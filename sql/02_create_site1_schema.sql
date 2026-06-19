-- ============================================================
-- 02_create_site1_schema.sql
-- Site1 local fragment tables.
-- ============================================================

SET ECHO ON

CONNECT eshop/eshop@FREEPDB1

CREATE TABLE Clients1 (
  idclient NUMBER NOT NULL,
  codeclient VARCHAR2(20) NOT NULL,
  societe VARCHAR2(120) NOT NULL,
  contact VARCHAR2(120),
  ville VARCHAR2(80),
  pays VARCHAR2(80),
  telephone VARCHAR2(30),
  CONSTRAINT pk_clients1 PRIMARY KEY (idclient),
  CONSTRAINT uk_clients1_code UNIQUE (codeclient)
);

CREATE TABLE Produits1 (
  idproduit NUMBER NOT NULL,
  idcateg NUMBER NOT NULL,
  designation VARCHAR2(160) NOT NULL,
  prixunitaire NUMBER(10, 2) NOT NULL,
  CONSTRAINT pk_produits1 PRIMARY KEY (idproduit),
  CONSTRAINT ck_produits1_prix CHECK (prixunitaire >= 0)
);

CREATE TABLE Commandes1 (
  idcommande NUMBER NOT NULL,
  idemploye NUMBER NOT NULL,
  idclient NUMBER NOT NULL,
  datecommande DATE NOT NULL,
  adresse_livraison VARCHAR2(200),
  ville_livraison VARCHAR2(80),
  pays_livraison VARCHAR2(80),
  CONSTRAINT pk_commandes1 PRIMARY KEY (idcommande),
  CONSTRAINT fk_commandes1_clients1 FOREIGN KEY (idclient)
    REFERENCES Clients1 (idclient)
);

CREATE TABLE LigneCommandes1 (
  idlignecommande NUMBER NOT NULL,
  idcommande NUMBER NOT NULL,
  idproduit NUMBER NOT NULL,
  quantite NUMBER NOT NULL,
  remise NUMBER(5, 4) DEFAULT 0 NOT NULL,
  CONSTRAINT pk_lignecommandes1 PRIMARY KEY (idlignecommande),
  CONSTRAINT fk_ligne1_commandes1 FOREIGN KEY (idcommande)
    REFERENCES Commandes1 (idcommande),
  CONSTRAINT fk_ligne1_produits1 FOREIGN KEY (idproduit)
    REFERENCES Produits1 (idproduit),
  CONSTRAINT ck_ligne1_quantite CHECK (quantite > 0),
  CONSTRAINT ck_ligne1_remise CHECK (remise >= 0 AND remise < 1)
);

COMMIT;
