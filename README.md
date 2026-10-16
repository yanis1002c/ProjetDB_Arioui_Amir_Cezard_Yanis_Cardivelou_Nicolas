# Projet BDD - Partie 1


# Mini-Projet Bases de Données - Partie 1

## 1. Analyse des besoins (Prompt RICARDO)
Voici le prompt utilisé pour définir les règles métier et le dictionnaire de données :

Partie à compléter	Valeur choisie
Domaine	Basket-ball professionnel
Type de structure	Organisation
Activité	Organiser et gérer les compétitions de basket professionnel masculin en France (calendrier, résultats, statistiques, suivi des clubs, joueurs, entraîneurs et arbitres)
Exemples	LNB, NBA, EuroLeague
Données collectées	Clubs et salles, joueurs et contrats, entraîneurs et assistants, saisons et compétitions, matchs et score par quart-temps, arbitres, statistiques des joueurs
Références	lnb.fr, ffbb.com, fiba.basketball

Tu travailles dans le domaine du basket-ball professionnel. Ton organisation a comme activité d'organiser et de gérer les compétitions de basket professionnel masculin en France (championnat Betclic ÉLITE, championnat ÉLITE 2 et Leaders Cup) : calendrier des matchs, enregistrement des résultats et des statistiques, suivi des clubs, des joueurs, des entraîneurs et des arbitres. C'est une organisation comme la Ligue Nationale de Basket (LNB) en France, la NBA aux États-Unis ou l'EuroLeague en Europe. Les données ont été collectées sur les clubs et les salles où ils jouent, les joueurs et leurs contrats avec les clubs, les entraîneurs et leurs assistants, les saisons et les compétitions, les matchs et leur score à chaque quart-temps, les arbitres de chaque match, ainsi que les statistiques des joueurs à chaque match. Inspire-toi des sites web suivants : https://www.lnb.fr (site officiel de la LNB : clubs, calendrier, résultats, statistiques), https://www.ffbb.com (Fédération Française de BasketBall : licences, arbitrage) et https://www.fiba.basketball (règles officielles du basket-ball).

Ton organisation veut appliquer MERISE pour concevoir un système d'information. Tu es chargé de la partie analyse, c'est-à-dire de collecter les besoins auprès de l'entreprise. Elle a fait appel à un étudiant en ingénierie informatique pour réaliser ce projet, tu dois lui fournir les informations nécessaires pour qu'il applique ensuite lui-même les étapes suivantes de conception et développement de la base de données.

D'abord, établis les règles de gestions des données de ton organisation, sous la forme d'une liste à puce. Elle doit correspondre aux informations que fournit quelqu'un qui connaît le fonctionnement de l'entreprise, mais pas comment se construit un système d'information.

Ensuite, à partir de ces règles, fournis un dictionnaire de données brutes avec les colonnes suivantes, regroupées dans un tableau : signification de la donnée, type, taille en nombre de caractères ou de chiffres. Il doit y avoir entre 25 et 35 données. Il sert à fournir des informations supplémentaires sur chaque donnée (taille et type) mais sans a priori sur comment les données vont être modélisées ensuite.

Fournis donc les règles de gestion et le dictionnaire de données.


## 2. Modèle Conceptuel de Données (MCD)
Voici le schéma conceptuel de la base de données :

![Modèle Conceptuel de Données](MCD_Yanis_Amir_Nicolas.PNG)