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

## Résumé des Insights
Pour augmenter le nombre d’abonnés au service Divvy, une analyse comparative des comportements des usagers occasionnels et des membres abonnés a été menée. Les données disponibles ont permis d'examiner leurs profils d’utilisation sur différentes échelles temporelles (journée, semaine, année) et d’évaluer leurs comportements en termes de durée des trajets, types de trajets (aller simple ou aller-retour), et zones principales de concentration des déplacements.

### Principaux enseignements :

**Répartition des utilisateurs :** 
* Deux tiers des trajets sont effectués par des membres abonnés, reflétant leur engagement régulier avec le service.

**Saisonnalité marquée chez les usagers occasionnels :**
* Leur utilisation atteint un pic en été (42 % des trajets réalisés entre juin et septembre) et chute fortement en hiver (17 % des trajets en janvier), contrairement aux membres, dont l’usage est plus constant.

**Habitudes d’utilisation :** 
* Les membres utilisent davantage le service en semaine, avec des pics aux heures de pointe (8h et 17h), ce qui correspond à des trajets domicile-travail ou études.
* Les usagers occasionnels privilégient les week-ends, avec un pic unique en fin d’après-midi (vers 17h).

**Durée des trajets :**
* La durée moyenne des trajets est plus courte chez les membres (13 minutes) que chez les usagers occasionnels (25 minutes).
* La grande majorité des trajets, que ce soit pour les membres (98,54 %) ou les usagers occasionnels (90,84 %), ne dépasse pas les 45 minutes incluses dans la structure tarifaire.

**Voyages aller-retour :**
Les usagers occasionnels sont responsables de 65,88 % des trajets aller-retour, confirmant un usage majoritairement orienté vers les loisirs ou le tourisme.

### Profils identifiés :

**Membres abonnés :**
Des utilisateurs réguliers, principalement des résidents locaux, qui exploitent le service pour des trajets courts et fonctionnels, liés à des besoins quotidiens comme le travail ou les études.

**Usagers occasionnels :**
Des utilisateurs irréguliers, souvent touristiques ou orientés vers les loisirs, qui privilégient les week-ends, les trajets plus longs et les zones à forte attractivité culturelle ou touristique.

## Recommandations
Sur la base des insights obtenus, voici les recommandations stratégiques pour encourager la conversion des usagers occasionnels en membres abonnés :

### 1. Identifier et cibler le bon public

**Cible idéale :** Les usagers occasionnels qui adoptent déjà un comportement similaire à celui des membres abonnés. Cela inclut :
* Les trajets réalisés en semaine, hors périodes estivales et hors week-ends.
* Les trajets aux heures de pointe (8h et 17h).
* Les déplacements entre des stations fréquemment utilisées par les membres abonnés (dans les zones résidentielles ou d’affaires).

**Potentiel de conversion :** Ces utilisateurs ont enregistré plus de **10 000 trajets** au cours de l'année analysée, représentant une opportunité significative.

### 2. Transmettre le bon message

**Axe principal :** Souligner les bénéfices pratiques et financiers de l’abonnement pour un usage régulier.
**Arguments clés :**
* **Disponibilité et flexibilité :** Un réseau accessible 24/7, idéal pour éviter les bouchons, les grèves ou les interruptions de service.
* **Économies :** Comparer le coût d’un abonnement annuel à celui d’un usage ponctuel sur une année.
* **Simplicité et rapidité :** Pas de temps d’attente ou de réservations nécessaires.
* **Santé et bien-être :** Opportunité d’intégrer une activité physique dans un mode de vie quotidien.

### 3. Utiliser le bon moment et le bon canal

**Timing idéal :** Immédiatement après un trajet correspondant au profil d’un membre abonné, avant que l’usager occasionnel ne quitte l’application.

**Canal privilégié :** L’application mobile Divvy, avec une notification ou une bannière proposant un abonnement adapté à leurs habitudes d’utilisation.

**Message personnalisé :** Inclure des données sur leurs trajets récents pour illustrer les avantages potentiels de l’abonnement.

## Visualisation des Données

Un **dashboard interactif** a été développé avec **Tableau Public** pour analyser et comparer les profils d’utilisation du service de vélopartage par les **utilisateurs abonnés** et les **utilisateurs occasionnels**.

🔗 [Accéder au dashboard sur Tableau Public](https://public.tableau.com/views/BikeShareUserProfiles/Dashboard1?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

![Aperçu du dashboard interactif](./Member%20vs%20Casual%20Usage.png)

### Fonctionnalités clés :
- 📍 **Géographie des trajets** : carte interactive des stations les plus utilisées.
- 📊 **Analyse temporelle** : par mois, jour de la semaine et heure de la journée.
- 🚲 **Types de vélos et trajets** : répartition entre vélos classiques, électriques et types d’itinéraires (aller simple vs boucle).
- 🔄 **Filtrage dynamique** : visualisation personnalisée selon le type d’utilisateur.

## Exemple de Présentation
La présentation conçue pour l’équipe marketing détaille les insights et recommandations mentionnés ci-dessus. Elle est disponible [ici](https://docs.google.com/presentation/d/1fZtIF8Ym_7UWguF2RbKNNAYg1Ur8ai-JEzc3jjDwqP4/edit?usp=sharing). 
