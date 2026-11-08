-- =====================================================================
-- Mini-projet TI503N – Base de données de la LNB (basket professionnel)
-- Étape 4 – Script d'insertion de données de test (3_insertion.sql)
-- SGBD cible : MySQL 8.0
-- =====================================================================

USE lnb_basket;

-- Désactivation temporaire des vérifications de clés étrangères
SET FOREIGN_KEY_CHECKS = 0;

-- Nettoyage des tables avant insertion
TRUNCATE TABLE PARTICIPE;
TRUNCATE TABLE STATISTIQUES;
TRUNCATE TABLE ARBITRER;
TRUNCATE TABLE PERIODE;
TRUNCATE TABLE MATCH_BASKET;
TRUNCATE TABLE SUPERVISE;
TRUNCATE TABLE ENTRAINEUR;
TRUNCATE TABLE CONTRAT;
TRUNCATE TABLE CLUB;
TRUNCATE TABLE ARBITRE;
TRUNCATE TABLE JOUEUR;
TRUNCATE TABLE COMPETITION;
TRUNCATE TABLE SAISON;
TRUNCATE TABLE SALLE;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- 1. SALLE
-- ---------------------------------------------------------------------
INSERT INTO SALLE (id_salle, nom_salle, adresse, capacite) VALUES
(1, 'Astroballe', '44 Avenue Marcel Cerdan, Villeurbanne', 5560),
(2, 'Palais des Sports Marcel-Cerdan', '141 Rue Danton, Levallois-Perret', 4000),
(3, 'Rhenus Sport', 'Boulevard de la Marne, Strasbourg', 6166),
(4, 'Palais des Sports de Beaublanc', 'Boulevard de Beaublanc, Limoges', 5516),
(5, 'Salle Gaston Médecin', '7 Avenue des Castelans, Monaco', 4600),
(6, 'Le Colisée', 'Rue de la Guerche, Chalon-sur-Saône', 4948);

-- ---------------------------------------------------------------------
-- 2. SAISON
-- ---------------------------------------------------------------------
INSERT INTO SAISON (saison) VALUES
('2024-2025'),
('2025-2026');

-- ---------------------------------------------------------------------
-- 3. COMPETITION
-- ---------------------------------------------------------------------
INSERT INTO COMPETITION (nom_competition) VALUES
('Betclic ÉLITE'),
('ÉLITE 2'),
('Leaders Cup');

-- ---------------------------------------------------------------------
-- 4. JOUEUR
-- ---------------------------------------------------------------------
INSERT INTO JOUEUR (no_licence, nom, prenom, date_naissance, nationalite, taille_cm, poste) VALUES
('FR102938', 'De Colo', 'Nando', '1987-06-23', 'Française', 196, 'Arrière'),
('FR493021', 'Lauvergne', 'Joffrey', '1991-09-30', 'Française', 211, 'Pivot'),
('US839201', 'James', 'Mike', '1990-08-18', 'Américaine', 185, 'Meneur'),
('FR204938', 'Okobo', 'Élie', '1997-10-23', 'Française', 191, 'Meneur'),
('FR940321', 'Lang', 'Nicolas', '1990-05-01', 'Française', 198, 'Ailier'),
('US102948', 'Blossomgame', 'Jaron', '1993-09-16', 'Américaine', 198, 'Ailier fort'),
('FR392019', 'Diallo', 'Alpha', '1997-06-29', 'Américaine', 201, 'Ailier'),
('FR583920', 'Tarpey', 'Terry', '1994-03-02', 'Française', 196, 'Ailier');

-- ---------------------------------------------------------------------
-- 5. ARBITRE
-- ---------------------------------------------------------------------
INSERT INTO ARBITRE (id_arbitre, nom, prenom) VALUES
(1, 'Bissang', 'Joseph'),
(2, 'Rosario', 'Yohan'),
(3, 'Diffallah', 'Mehdi'),
(4, 'Thepenier', 'Hugues');

-- ---------------------------------------------------------------------
-- 6. CLUB
-- ---------------------------------------------------------------------
INSERT INTO CLUB (id_club, nom_club, ville, annee_fondation, id_salle) VALUES
(1, 'ASVEL Lyon-Villeurbanne', 'Villeurbanne', 1948, 1),
(2, 'AS Monaco Basket', 'Monaco', 1924, 5),
(3, 'SIG Strasbourg', 'Strasbourg', 1928, 3),
(4, 'Limoges CSP', 'Limoges', 1929, 4),
(5, 'Élan Chalon', 'Chalon-sur-Saône', 1955, 6);

-- ---------------------------------------------------------------------
-- 7. CONTRAT
-- ---------------------------------------------------------------------
INSERT INTO CONTRAT (id_contrat, date_debut, date_fin, numero_maillot, no_licence, id_club, saison) VALUES
(1, '2024-07-01', '2025-06-30', '12', 'FR102938', 1, '2024-2025'),
(2, '2024-07-01', '2025-06-30', '7', 'FR493021', 1, '2024-2025'),
(3, '2024-07-01', '2025-06-30', '55', 'US839201', 2, '2024-2025'),
(4, '2024-07-01', '2025-06-30', '0', 'FR204938', 2, '2024-2025'),
(5, '2024-07-01', '2025-06-30', '9', 'FR940321', 4, '2024-2025'),
(6, '2025-07-01', '2026-06-30', '12', 'FR102938', 1, '2025-2026'),
(7, '2025-07-01', '2026-06-30', '55', 'US839201', 2, '2025-2026');

-- ---------------------------------------------------------------------
-- 8. ENTRAINEUR
-- ---------------------------------------------------------------------
INSERT INTO ENTRAINEUR (id_entraineur, nom, prenom, id_club) VALUES
(1, 'Poupet', 'Pierric', 1),
(2, 'Obradovic', 'Sasa', 2),
(3, 'Vila', 'Lassi', 3),
(4, 'Masson', 'Edo', 1),    -- Assistant ASVEL
(5, 'Serb', 'Manuchar', 2);  -- Assistant Monaco

-- ---------------------------------------------------------------------
-- 9. SUPERVISE
-- ---------------------------------------------------------------------
INSERT INTO SUPERVISE (id_assistant, id_superviseur) VALUES
(4, 1),
(5, 2);

-- ---------------------------------------------------------------------
-- 10. MATCH_BASKET
-- ---------------------------------------------------------------------
INSERT INTO MATCH_BASKET (id_match, date_match, heure_match, spectateurs, saison, nom_competition, id_club_recevant, id_club_visiteur) VALUES
(101, '2024-10-12', '20:00:00', 5200, '2024-2025', 'Betclic ÉLITE', 1, 2),
(102, '2024-11-05', '19:00:00', 4100, '2024-2025', 'Betclic ÉLITE', 2, 4),
(103, '2025-02-16', '17:00:00', 4500, '2024-2025', 'Leaders Cup', 3, 1);

-- ---------------------------------------------------------------------
-- 11. PERIODE
-- ---------------------------------------------------------------------
INSERT INTO PERIODE (id_match, numero_periode, points_recevant, points_visiteur) VALUES
(101, 1, 22, 19),
(101, 2, 18, 25),
(101, 3, 20, 21),
(101, 4, 25, 20),
(102, 1, 28, 14),
(102, 2, 22, 18),
(102, 3, 24, 20),
(102, 4, 19, 16);

-- ---------------------------------------------------------------------
-- 12. ARBITRER
-- ---------------------------------------------------------------------
INSERT INTO ARBITRER (id_match, id_arbitre) VALUES
(101, 1),
(101, 2),
(101, 3),
(102, 1),
(102, 4);

-- ---------------------------------------------------------------------
-- 13. STATISTIQUES
-- ---------------------------------------------------------------------
INSERT INTO STATISTIQUES (no_licence, id_match, minutes_jouees, points_marques, rebonds, passes_decisives, fautes_personnelles) VALUES
('FR102938', 101, 28, 18, 3, 6, 2),
('FR493021', 101, 22, 12, 8, 1, 4),
('US839201', 101, 34, 24, 4, 7, 3),
('FR204938', 101, 25, 14, 2, 4, 1),
('US839201', 102, 26, 20, 3, 8, 2),
('FR940321', 102, 31, 15, 4, 2, 3);

-- ---------------------------------------------------------------------
-- 14. PARTICIPE
-- ---------------------------------------------------------------------
INSERT INTO PARTICIPE (id_club, saison, nom_competition) VALUES
(1, '2024-2025', 'Betclic ÉLITE'),
(2, '2024-2025', 'Betclic ÉLITE'),
(3, '2024-2025', 'Betclic ÉLITE'),
(4, '2024-2025', 'Betclic ÉLITE'),
(5, '2024-2025', 'Betclic ÉLITE'),
(1, '2024-2025', 'Leaders Cup'),
(2, '2024-2025', 'Leaders Cup');