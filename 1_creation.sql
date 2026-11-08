-- =====================================================================
--  Mini-projet TI503N – Base de données de la LNB (basket professionnel)
--  Étape 3 – MPD : création des tables et contraintes d'intégrité
--  SGBD cible : MySQL 8.0 (moteur InnoDB, jeu de caractères utf8mb4)
-- =====================================================================
--  Politique des clés étrangères (suppression / modification sans erreur) :
--   * ON UPDATE CASCADE partout : si une clé primaire change, toutes les
--     lignes qui la référencent sont mises à jour automatiquement.
--   * ON DELETE CASCADE quand la ligne fille n'a pas de sens sans son parent
--     (contrat, match, période, statistiques, arbitrage, participation).
--   * ON DELETE SET NULL quand le lien est facultatif (salle d'un club,
--     club d'un entraîneur).
-- =====================================================================

DROP DATABASE IF EXISTS lnb_basket;
CREATE DATABASE lnb_basket CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE lnb_basket;

-- ---------------------------------------------------------------------
--  Tables issues des entités sans clé étrangère
-- ---------------------------------------------------------------------

CREATE TABLE SALLE (
    id_salle    INT          NOT NULL,
    nom_salle   VARCHAR(60)  NOT NULL,
    adresse     VARCHAR(120) NOT NULL,
    capacite    INT          NOT NULL,
    CONSTRAINT pk_salle PRIMARY KEY (id_salle)
) ENGINE = InnoDB;

CREATE TABLE SAISON (
    saison      CHAR(9)      NOT NULL,          -- ex. '2025-2026'
    CONSTRAINT pk_saison PRIMARY KEY (saison)
) ENGINE = InnoDB;

CREATE TABLE COMPETITION (
    nom_competition VARCHAR(40) NOT NULL,       -- ex. 'Betclic ÉLITE'
    CONSTRAINT pk_competition PRIMARY KEY (nom_competition)
) ENGINE = InnoDB;

CREATE TABLE JOUEUR (
    no_licence      CHAR(8)      NOT NULL,      -- n° de licence FFBB
    nom             VARCHAR(40)  NOT NULL,
    prenom          VARCHAR(40)  NOT NULL,
    date_naissance  DATE         NOT NULL,
    nationalite     VARCHAR(40)  NOT NULL,
    taille_cm       SMALLINT     NOT NULL,
    poste           VARCHAR(15)  NOT NULL,
    CONSTRAINT pk_joueur PRIMARY KEY (no_licence)
) ENGINE = InnoDB;

CREATE TABLE ARBITRE (
    id_arbitre  INT          NOT NULL,
    nom         VARCHAR(40)  NOT NULL,
    prenom      VARCHAR(40)  NOT NULL,
    CONSTRAINT pk_arbitre PRIMARY KEY (id_arbitre)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
--  CLUB  (association DOMICILE : un club joue dans 1 salle)
-- ---------------------------------------------------------------------

CREATE TABLE CLUB (
    id_club          INT          NOT NULL,
    nom_club         VARCHAR(60)  NOT NULL,
    ville            VARCHAR(50)  NOT NULL,
    annee_fondation  SMALLINT     NOT NULL,
    id_salle         INT          NULL,         -- DOMICILE
    CONSTRAINT pk_club PRIMARY KEY (id_club),
    CONSTRAINT fk_club_salle FOREIGN KEY (id_salle)
        REFERENCES SALLE (id_salle)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
--  CONTRAT  (CONCERNE un joueur, SIGNÉ AVEC un club, POUR une saison)
-- ---------------------------------------------------------------------

CREATE TABLE CONTRAT (
    id_contrat      INT          NOT NULL,
    date_debut      DATE         NOT NULL,
    date_fin        DATE         NOT NULL,
    numero_maillot  VARCHAR(2)   NOT NULL,      -- '0', '00', '1' … '99'
    no_licence      CHAR(8)      NOT NULL,      -- CONCERNE
    id_club         INT          NOT NULL,      -- SIGNÉ AVEC
    saison          CHAR(9)      NOT NULL,      -- POUR
    CONSTRAINT pk_contrat PRIMARY KEY (id_contrat),
    CONSTRAINT fk_contrat_joueur FOREIGN KEY (no_licence)
        REFERENCES JOUEUR (no_licence)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contrat_club FOREIGN KEY (id_club)
        REFERENCES CLUB (id_club)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contrat_saison FOREIGN KEY (saison)
        REFERENCES SAISON (saison)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
--  ENTRAINEUR  (AFFECTER à un club)
-- ---------------------------------------------------------------------

CREATE TABLE ENTRAINEUR (
    id_entraineur   INT          NOT NULL,
    nom             VARCHAR(40)  NOT NULL,
    prenom          VARCHAR(40)  NOT NULL,
    id_club         INT          NULL,          -- AFFECTER
    CONSTRAINT pk_entraineur PRIMARY KEY (id_entraineur),
    CONSTRAINT fk_entraineur_club FOREIGN KEY (id_club)
        REFERENCES CLUB (id_club)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
--  SUPERVISE  (association réflexive : un assistant est supervisé par
--              un entraîneur principal)
--  Elle est traduite par une table à part plutôt que par une clé
--  étrangère vers ENTRAINEUR dans ENTRAINEUR elle-même : MySQL ne sait
--  pas propager un ON UPDATE CASCADE vers la même table (erreur 1451).
--  La clé primaire id_assistant garantit qu'un assistant n'a qu'un seul
--  superviseur, ce qui respecte la cardinalité (0,1) du MCD.
-- ---------------------------------------------------------------------

CREATE TABLE SUPERVISE (
    id_assistant    INT  NOT NULL,
    id_superviseur  INT  NOT NULL,
    CONSTRAINT pk_supervise PRIMARY KEY (id_assistant),
    CONSTRAINT fk_supervise_assistant FOREIGN KEY (id_assistant)
        REFERENCES ENTRAINEUR (id_entraineur)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_supervise_superviseur FOREIGN KEY (id_superviseur)
        REFERENCES ENTRAINEUR (id_entraineur)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
--  MATCH_BASKET  (MATCH est un mot réservé en MySQL)
--  EN SAISON, SE JOUE DANS une compétition, REÇOIT (club recevant),
--  VISITEUR (club visiteur)
-- ---------------------------------------------------------------------

CREATE TABLE MATCH_BASKET (
    id_match           INT          NOT NULL,
    date_match         DATE         NOT NULL,
    heure_match        TIME         NOT NULL,
    spectateurs        INT          NOT NULL,
    saison             CHAR(9)      NOT NULL,   -- EN SAISON
    nom_competition    VARCHAR(40)  NOT NULL,   -- SE JOUE DANS
    id_club_recevant   INT          NOT NULL,   -- REÇOIT
    id_club_visiteur   INT          NOT NULL,   -- VISITEUR
    CONSTRAINT pk_match PRIMARY KEY (id_match),
    CONSTRAINT fk_match_saison FOREIGN KEY (saison)
        REFERENCES SAISON (saison)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_match_competition FOREIGN KEY (nom_competition)
        REFERENCES COMPETITION (nom_competition)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_match_recevant FOREIGN KEY (id_club_recevant)
        REFERENCES CLUB (id_club)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_match_visiteur FOREIGN KEY (id_club_visiteur)
        REFERENCES CLUB (id_club)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
--  PERIODE  (entité faible : identifiée par son match + son numéro)
-- ---------------------------------------------------------------------

CREATE TABLE PERIODE (
    id_match          INT       NOT NULL,       -- COMPREND
    numero_periode    TINYINT   NOT NULL,
    points_recevant   SMALLINT  NOT NULL,
    points_visiteur   SMALLINT  NOT NULL,
    CONSTRAINT pk_periode PRIMARY KEY (id_match, numero_periode),
    CONSTRAINT fk_periode_match FOREIGN KEY (id_match)
        REFERENCES MATCH_BASKET (id_match)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
--  Tables issues des associations (N,N) et ternaire
-- ---------------------------------------------------------------------

-- ARBITRER : un match est arbitré par plusieurs arbitres
CREATE TABLE ARBITRER (
    id_match    INT  NOT NULL,
    id_arbitre  INT  NOT NULL,
    CONSTRAINT pk_arbitrer PRIMARY KEY (id_match, id_arbitre),
    CONSTRAINT fk_arbitrer_match FOREIGN KEY (id_match)
        REFERENCES MATCH_BASKET (id_match)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_arbitrer_arbitre FOREIGN KEY (id_arbitre)
        REFERENCES ARBITRE (id_arbitre)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- STATISTIQUES : statistiques d'un joueur sur un match
CREATE TABLE STATISTIQUES (
    no_licence           CHAR(8)   NOT NULL,
    id_match             INT       NOT NULL,
    minutes_jouees       TINYINT   NOT NULL,
    points_marques       SMALLINT  NOT NULL,
    rebonds              SMALLINT  NOT NULL,
    passes_decisives     SMALLINT  NOT NULL,
    fautes_personnelles  TINYINT   NOT NULL,
    CONSTRAINT pk_statistiques PRIMARY KEY (no_licence, id_match),
    CONSTRAINT fk_stats_joueur FOREIGN KEY (no_licence)
        REFERENCES JOUEUR (no_licence)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_stats_match FOREIGN KEY (id_match)
        REFERENCES MATCH_BASKET (id_match)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

-- PARTICIPE : association ternaire CLUB – SAISON – COMPETITION
CREATE TABLE PARTICIPE (
    id_club          INT          NOT NULL,
    saison           CHAR(9)      NOT NULL,
    nom_competition  VARCHAR(40)  NOT NULL,
    CONSTRAINT pk_participe PRIMARY KEY (id_club, saison, nom_competition),
    CONSTRAINT fk_participe_club FOREIGN KEY (id_club)
        REFERENCES CLUB (id_club)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_participe_saison FOREIGN KEY (saison)
        REFERENCES SAISON (saison)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_participe_competition FOREIGN KEY (nom_competition)
        REFERENCES COMPETITION (nom_competition)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;
