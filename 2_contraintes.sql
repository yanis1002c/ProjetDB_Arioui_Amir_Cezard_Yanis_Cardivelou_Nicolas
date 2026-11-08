-- =====================================================================
--  Mini-projet TI503N – Base de données de la LNB
--  Étape 3 – Contraintes de validation (règles métier)
--  À exécuter APRÈS 1_creation.sql   –   SGBD : MySQL 8.0
-- =====================================================================
--  Types de contraintes couverts :
--    1. DEFAULT          (valeur par défaut)
--    2. UNIQUE           (unicité simple et composée)
--    3. CHECK domaine    (intervalle de valeurs, BETWEEN)
--    4. CHECK liste      (IN)
--    5. CHECK format     (masque / expression régulière)
--    6. CHECK multi-colonnes (comparaison entre deux colonnes d'une ligne)
--    7. TRIGGERS         (règles impossibles à écrire avec un CHECK)
-- =====================================================================

USE lnb_basket;

-- ---------------------------------------------------------------------
--  1. Valeurs par défaut
-- ---------------------------------------------------------------------

ALTER TABLE MATCH_BASKET  ALTER spectateurs         SET DEFAULT 0;
ALTER TABLE PERIODE       ALTER points_recevant     SET DEFAULT 0;
ALTER TABLE PERIODE       ALTER points_visiteur     SET DEFAULT 0;
ALTER TABLE STATISTIQUES  ALTER minutes_jouees      SET DEFAULT 0;
ALTER TABLE STATISTIQUES  ALTER points_marques      SET DEFAULT 0;
ALTER TABLE STATISTIQUES  ALTER rebonds             SET DEFAULT 0;
ALTER TABLE STATISTIQUES  ALTER passes_decisives    SET DEFAULT 0;
ALTER TABLE STATISTIQUES  ALTER fautes_personnelles SET DEFAULT 0;

-- ---------------------------------------------------------------------
--  2. Unicité
-- ---------------------------------------------------------------------

-- Deux clubs ne peuvent pas porter le même nom
ALTER TABLE CLUB  ADD CONSTRAINT uq_club_nom  UNIQUE (nom_club);

-- Une salle est identifiée de façon unique par son nom et son adresse
ALTER TABLE SALLE ADD CONSTRAINT uq_salle_nom_adresse UNIQUE (nom_salle, adresse);

-- Règle métier : un numéro de maillot est unique par club et par saison
ALTER TABLE CONTRAT ADD CONSTRAINT uq_maillot_club_saison
    UNIQUE (id_club, saison, numero_maillot);

-- Un club ne peut pas jouer deux matchs à la même date et heure à domicile
ALTER TABLE MATCH_BASKET ADD CONSTRAINT uq_match_recevant_date
    UNIQUE (id_club_recevant, date_match, heure_match);

-- ---------------------------------------------------------------------
--  3. Domaines de valeurs (intervalles)
-- ---------------------------------------------------------------------

ALTER TABLE SALLE ADD CONSTRAINT ck_salle_capacite
    CHECK (capacite BETWEEN 500 AND 30000);

ALTER TABLE CLUB ADD CONSTRAINT ck_club_annee_fondation
    CHECK (annee_fondation BETWEEN 1890 AND 2026);   -- le basket est inventé en 1891

ALTER TABLE JOUEUR ADD CONSTRAINT ck_joueur_taille
    CHECK (taille_cm BETWEEN 150 AND 240);

ALTER TABLE JOUEUR ADD CONSTRAINT ck_joueur_naissance
    CHECK (date_naissance BETWEEN '1970-01-01' AND '2012-12-31');

ALTER TABLE MATCH_BASKET ADD CONSTRAINT ck_match_spectateurs
    CHECK (spectateurs >= 0);

ALTER TABLE MATCH_BASKET ADD CONSTRAINT ck_match_heure
    CHECK (heure_match BETWEEN '12:00:00' AND '22:00:00');

-- Règle métier : 4 périodes de 10 min, puis prolongations de 5 min si égalité
-- (numéros 1 à 4 = quart-temps, 5 et plus = prolongations ; on en autorise 6)
ALTER TABLE PERIODE ADD CONSTRAINT ck_periode_numero
    CHECK (numero_periode BETWEEN 1 AND 10);

ALTER TABLE PERIODE ADD CONSTRAINT ck_periode_points
    CHECK (points_recevant >= 0 AND points_visiteur >= 0);

-- Statistiques : un match dure 40 min + prolongations, 5 fautes = exclusion (FIBA)
ALTER TABLE STATISTIQUES ADD CONSTRAINT ck_stats_minutes
    CHECK (minutes_jouees BETWEEN 0 AND 70);

ALTER TABLE STATISTIQUES ADD CONSTRAINT ck_stats_fautes
    CHECK (fautes_personnelles BETWEEN 0 AND 5);

ALTER TABLE STATISTIQUES ADD CONSTRAINT ck_stats_positifs
    CHECK (points_marques >= 0 AND rebonds >= 0 AND passes_decisives >= 0);

-- ---------------------------------------------------------------------
--  4. Listes de valeurs autorisées (IN)
-- ---------------------------------------------------------------------

ALTER TABLE JOUEUR ADD CONSTRAINT ck_joueur_poste
    CHECK (poste IN ('Meneur', 'Arrière', 'Ailier', 'Ailier fort', 'Pivot'));

ALTER TABLE COMPETITION ADD CONSTRAINT ck_competition_nom
    CHECK (nom_competition IN ('Betclic ÉLITE', 'ÉLITE 2', 'Leaders Cup'));

-- ---------------------------------------------------------------------
--  5. Formats (masques / expressions régulières)
-- ---------------------------------------------------------------------

-- Saison au format AAAA-AAAA, la 2e année suivant directement la 1re
ALTER TABLE SAISON ADD CONSTRAINT ck_saison_format
    CHECK (REGEXP_LIKE(saison, '^[0-9]{4}-[0-9]{4}$')
           AND CAST(SUBSTRING(saison, 6, 4) AS UNSIGNED)
             = CAST(SUBSTRING(saison, 1, 4) AS UNSIGNED) + 1);

-- N° de licence FFBB : 2 lettres majuscules suivies de 6 chiffres (ex. VT123456)
ALTER TABLE JOUEUR ADD CONSTRAINT ck_joueur_licence
    CHECK (REGEXP_LIKE(no_licence, '^[A-Z]{2}[0-9]{6}$', 'c'));

-- Règle métier : numéro de maillot 0, 00 ou de 1 à 99
ALTER TABLE CONTRAT ADD CONSTRAINT ck_contrat_maillot
    CHECK (REGEXP_LIKE(numero_maillot, '^(0|00|[1-9][0-9]?)$'));

-- Noms et prénoms : pas de chiffres
ALTER TABLE JOUEUR ADD CONSTRAINT ck_joueur_nom
    CHECK (NOT REGEXP_LIKE(CONCAT(nom, prenom), '[0-9]'));
ALTER TABLE ENTRAINEUR ADD CONSTRAINT ck_entraineur_nom
    CHECK (NOT REGEXP_LIKE(CONCAT(nom, prenom), '[0-9]'));
ALTER TABLE ARBITRE ADD CONSTRAINT ck_arbitre_nom
    CHECK (NOT REGEXP_LIKE(CONCAT(nom, prenom), '[0-9]'));

-- ---------------------------------------------------------------------
--  6. Comparaison entre colonnes d'une même ligne
-- ---------------------------------------------------------------------

-- Un contrat se termine après avoir commencé
ALTER TABLE CONTRAT ADD CONSTRAINT ck_contrat_dates
    CHECK (date_fin > date_debut);

-- =====================================================================
--  7. Triggers
--  MySQL interdit un CHECK sur une colonne de clé étrangère qui possède
--  une action ON UPDATE / ON DELETE (CASCADE, SET NULL). Les règles
--  portant sur ces colonnes, ou sur plusieurs lignes / plusieurs tables,
--  sont donc vérifiées par des triggers qui lèvent une erreur (SIGNAL).
-- =====================================================================

DELIMITER //

-- Règle métier : le club recevant est différent du club visiteur
CREATE TRIGGER trg_match_clubs_bi BEFORE INSERT ON MATCH_BASKET
FOR EACH ROW
BEGIN
    IF NEW.id_club_recevant = NEW.id_club_visiteur THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Le club recevant doit être différent du club visiteur';
    END IF;
END//

CREATE TRIGGER trg_match_clubs_bu BEFORE UPDATE ON MATCH_BASKET
FOR EACH ROW
BEGIN
    IF NEW.id_club_recevant = NEW.id_club_visiteur THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Le club recevant doit être différent du club visiteur';
    END IF;
END//

-- Règle métier : les spectateurs ne dépassent pas la capacité de la salle
-- du club recevant
CREATE TRIGGER trg_match_capacite_bi BEFORE INSERT ON MATCH_BASKET
FOR EACH ROW
BEGIN
    DECLARE cap INT;
    SELECT s.capacite INTO cap
    FROM CLUB c JOIN SALLE s ON s.id_salle = c.id_salle
    WHERE c.id_club = NEW.id_club_recevant;
    IF cap IS NOT NULL AND NEW.spectateurs > cap THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Le nombre de spectateurs dépasse la capacité de la salle';
    END IF;
END//

-- Un entraîneur ne peut pas se superviser lui-même
CREATE TRIGGER trg_supervise_soi_meme_bi BEFORE INSERT ON SUPERVISE
FOR EACH ROW
BEGIN
    IF NEW.id_superviseur = NEW.id_assistant THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un entraîneur ne peut pas se superviser lui-même';
    END IF;
END//

-- Règle métier : 3 arbitres par match au maximum (1 principal, 2 assistants)
CREATE TRIGGER trg_arbitrer_max3_bi BEFORE INSERT ON ARBITRER
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM ARBITRER WHERE id_match = NEW.id_match) >= 3 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un match ne peut pas avoir plus de 3 arbitres';
    END IF;
END//

-- Règle métier : les contrats d'un joueur ne se chevauchent pas
CREATE TRIGGER trg_contrat_chevauchement_bi BEFORE INSERT ON CONTRAT
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM CONTRAT
               WHERE no_licence = NEW.no_licence
                 AND NEW.date_debut < date_fin
                 AND NEW.date_fin   > date_debut) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ce joueur a déjà un contrat sur cette période';
    END IF;
END//

DELIMITER ;
