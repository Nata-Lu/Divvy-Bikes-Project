# Divvy Bikes Project : Comment une société de vélos en libre-service peut-elle encourager les utilisateurs occasionnels à adopter une adhésion annuelle ?
## Contexte du Projet
**À propos de l'entreprise** : Divvy est le système de partage de vélos de la région de Chicago et d'Evanston, offrant aux résidents et aux visiteurs un moyen de transport pratique, ludique et abordable pour explorer la ville. Les vélos peuvent être empruntés à partir de n’importe quelle station et restitués à une autre station du réseau. Les utilisateurs se servent de Divvy pour diverses activités : explorer Chicago, se rendre au travail ou à l’école, faire des courses, aller à des rendez-vous ou participer à des activités sociales, et bien plus encore. Disponible 24 heures sur 24, 7 jours sur 7 et toute l’année, le service permet un accès complet aux vélos et aux stations du système. Les utilisateurs peuvent payer à la course, acheter un pass de 24 heures ou souscrire un abonnement annuel.

**Objectif du projet** : Analyser et comparer les comportements d’utilisation des vélos entre les utilisateurs occasionnels et les abonnés annuels de Divvy. L'objectif est de dégager des tendances et des insights afin d'identifier des opportunités de conversion et de proposer des recommandations basées sur les données pour développer une stratégie marketing ciblée, encourageant les utilisateurs occasionnels à adopter une adhésion annuelle.

**Points Clés :**
* **Segmentation et comparaison :** Analyser les différences d’utilisation entre les deux segments d’utilisateurs pour identifier des patterns d'usage.
* **Identification d’opportunités :** Repérer des comportements récurrents qui pourraient révéler des opportunités de conversion.
* **Recommandations d’adhésion :** Proposer des actions concrètes et basées sur les données pour renforcer la stratégie marketing de Divvy et favoriser l’adhésion annuelle.

**Accès aux ressources du projet :**
* Les requêtes SQL utilisées pour le nettoyage, l'organisation et la préparation des données sont accessibles [ici](DataCleaning.sql).
* Les requêtes SQL utilisées pour l'exploration et l'analyse des données sont accessibles [ici](Divvy-Bikes-Project/EDA.sql).
* Les tableaux de bord interactifs sont accessibles sur mon profile Tableau Public [ici](https://public.tableau.com/app/profile/natalial/vizzes).

## Structure et Préparation des Données
Dans le cadre de son engagement à promouvoir le vélo comme mode de transport alternatif, la ville de Chicago rend certaines données publiques du système Divvy disponibles sous cette [licence](https://divvybikes.com/data-license-agreement). 

Les données analysées couvrent une période de 12 mois, du 1er octobre 2023 au 30 septembre 2024, et sont organisées en fichiers mensuels, représentant un total de plus de 5 millions de lignes.

Pour compléter cette analyse, j'utilise également les données des stations du réseau Divvy, également accessibles au public. Ce fichier contient 1 020 lignes et fournit des informations détaillées sur chaque station du réseau.

![Divvy data structure](https://github.com/user-attachments/assets/94e0f03f-f2bb-472e-9fda-5b7bd3506342)

Plusieurs opérations de nettoyage et de vérification des données ont été effectuées avant de passer à l'analyse. Les requêtes SQL utilisées pour le nettoyage et la manipulation des données sont accessibles [ici](DataCleaning.sql).
