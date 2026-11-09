-- =====================================================================
-- Mini-projet TI503N – Base de données de la LNB (basket professionnel)
-- Étape 5 – Interrogation de la base de données (4_interrogation.sql)
-- SGBD cible : MySQL 8.0
-- =====================================================================

USE lnb_basket;

-- =====================================================================
-- 1. Projections et Sélections (au moins 5)
-- =====================================================================

-- Q1.1 : Liste des salles ayant une capacité supérieure à 5000 places, triées par capacité décroissante
SELECT nom_salle, capacite 
FROM SALLE 
WHERE capacite > 5000 
ORDER BY capacite DESC;

-- Q1.2 : Noms et prénoms des joueurs de nationalité française nés après 1990
SELECT nom, prenom, date_naissance 
FROM JOUEUR 
WHERE nationalite = 'Française' AND date_naissance > '1990-01-01';

-- Q1.3 : Liste des joueurs mesurant entre 190 cm et 200 cm (utilisation de BETWEEN)
SELECT no_licence, nom, prenom, taille_cm 
FROM JOUEUR 
WHERE taille_cm BETWEEN 190 AND 200;

-- Q1.4 : Liste distincte des postes occupés par des joueurs dont le nom commence par 'D' (données uniques + masque)
SELECT DISTINCT poste 
FROM JOUEUR 
WHERE nom LIKE 'D%';

-- Q1.5 : Liste des matchs se déroulant en Betclic ÉLITE ou Leaders Cup (utilisation de IN)
SELECT id_match, date_match, nom_competition 
FROM MATCH_BASKET 
WHERE nom_competition IN ('Betclic ÉLITE', 'Leaders Cup');


-- =====================================================================
-- 2. Agrégations, GROUP BY et HAVING (au moins 5)
-- =====================================================================

-- Q2.1 : Nombre total de joueurs inscrits par poste
SELECT poste, COUNT(*) AS nombre_joueurs 
FROM JOUEUR 
GROUP BY poste;

-- Q2.2 : Capacité moyenne et maximale des salles par ville
SELECT c.ville, AVG(s.capacite) AS capacite_moyenne, MAX(s.capacite) AS capacite_max 
FROM SALLE s 
JOIN CLUB c ON s.id_salle = c.id_salle 
GROUP BY c.ville;

-- Q2.3 : Total des points marqués et moyenne des minutes jouées par joueur ayant joué plus de 20 minutes au total
SELECT no_licence, SUM(points_marques) AS total_points, AVG(minutes_jouees) AS moyenne_minutes 
FROM STATISTIQUES 
GROUP BY no_licence 
HAVING SUM(minutes_jouees) > 20;

-- Q2.4 : Nombre de matchs arbitrés par arbitre ayant arbitré au moins 2 matchs
SELECT id_arbitre, COUNT(id_match) AS nombre_matchs 
FROM ARBITRER 
GROUP BY id_arbitre 
HAVING COUNT(id_match) >= 2;

-- Q2.5 : Moyenne des spectateurs par compétition pour la saison '2024-2025'
SELECT nom_competition, AVG(spectateurs) AS moyenne_spectateurs 
FROM MATCH_BASKET 
WHERE saison = '2024-2025' 
GROUP BY nom_competition;


-- =====================================================================
-- 3. Jointures (internes, externes, multiples) (au moins 5)
-- =====================================================================

-- Q3.1 : Jointure interne : Noms des clubs avec le nom et la capacité de leur salle résidente
SELECT c.nom_club, s.nom_salle, s.capacite 
FROM CLUB c 
INNER JOIN SALLE s ON c.id_salle = s.id_salle;

-- Q3.2 : Jointure multiple : Information des matchs avec le nom des clubs recevant et visiteur
SELECT m.id_match, m.date_match, cr.nom_club AS club_recevant, cv.nom_club AS club_visiteur 
FROM MATCH_BASKET m 
JOIN CLUB cr ON m.id_club_recevant = cr.id_club 
JOIN CLUB cv ON m.id_club_visiteur = cv.id_club;

-- Q3.3 : Jointure externe (LEFT JOIN) : Liste de tous les entraîneurs et le nom du club auquel ils sont affectés (s'ils en ont un)
SELECT e.nom, e.prenom, c.nom_club 
FROM ENTRAINEUR e 
LEFT JOIN CLUB c ON e.id_club = c.id_club;

-- Q3.4 : Auto-jointure (Self Join via SUPERVISE) : Entraîneurs assistants avec le nom et prénom de leur entraîneur principal (superviseur)
SELECT a.nom AS nom_assistant, a.prenom AS prenom_assistant, s.nom AS nom_superviseur, s.prenom AS prenom_superviseur 
FROM SUPERVISE sup 
JOIN ENTRAINEUR a ON sup.id_assistant = a.id_entraineur 
JOIN ENTRAINEUR s ON sup.id_superviseur = s.id_entraineur;

-- Q3.5 : Jointure multiple complète : Statistiques individuelles des joueurs avec leur nom, prénom et la date du match
SELECT j.nom, j.prenom, m.date_match, st.points_marques, st.rebonds, st.passes_decisives 
FROM STATISTIQUES st 
JOIN JOUEUR j ON st.no_licence = j.no_licence 
JOIN MATCH_BASKET m ON st.id_match = m.id_match;


-- =====================================================================
-- 4. Requêtes imbriquées (IN, NOT IN, EXISTS, ALL, ANY) (au moins 5)
-- =====================================================================

-- Q4.1 : Requête imbriquée (IN) : Joueurs ayant souscrit un contrat pour la saison '2024-2025'
SELECT nom, prenom, poste 
FROM JOUEUR 
WHERE no_licence IN (
    SELECT no_licence 
    FROM CONTRAT 
    WHERE saison = '2024-2025'
);

-- Q4.2 : Requête imbriquée (NOT IN) : Salles qui ne reçoivent aucun club (pas de club associé)
SELECT id_salle, nom_salle 
FROM SALLE 
WHERE id_salle NOT IN (
    SELECT id_salle 
    FROM CLUB 
    WHERE id_salle IS NOT NULL
);

-- Q4.3 : Requête imbriquée (EXISTS) : Arbitres ayant arbitré au moins un match joué à l'Astroballe
SELECT a.nom, a.prenom 
FROM ARBITRER arb 
JOIN ARBITRE a ON arb.id_arbitre = a.id_arbitre 
WHERE EXISTS (
    SELECT 1 
    FROM MATCH_BASKET m 
    JOIN CLUB c ON m.id_club_recevant = c.id_club 
    JOIN SALLE s ON c.id_salle = s.id_salle 
    WHERE m.id_match = arb.id_match AND s.nom_salle = 'Astroballe'
);

-- Q4.4 : Requête imbriquée (ALL) : Joueurs ayant marqué plus de points en un match que tous les joueurs français
SELECT j.nom, j.prenom, st.points_marques 
FROM STATISTIQUES st 
JOIN JOUEUR j ON st.no_licence = j.no_licence 
WHERE st.points_marques > ALL (
    SELECT st2.points_marques 
    FROM STATISTIQUES st2 
    JOIN JOUEUR j2 ON st2.no_licence = j2.no_licence 
    WHERE j2.nationalite = 'Française'
);

-- Q4.5 : Requête imbriquée (ANY) : Matchs ayant accueilli plus de spectateurs que n'importe quel match joué à Monaco
SELECT id_match, date_match, spectateurs 
FROM MATCH_BASKET 
WHERE spectateurs > ANY (
    SELECT m.spectateurs 
    FROM MATCH_BASKET m 
    JOIN CLUB c ON m.id_club_recevant = c.id_club 
    WHERE c.ville = 'Monaco'
);