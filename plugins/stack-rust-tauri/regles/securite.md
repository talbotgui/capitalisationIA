---
paths: "**/src/**/*.rs"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), adapté de affaan-m/ecc (rules/rust, licence MIT, voir NOTICE.md). -->

* Aucun secret dans le code : variables d'environnement lues et contrôlées au démarrage (échec immédiat si absentes), trousseau du système ou gestionnaire de secrets sinon ; fichiers .env exclus du dépôt.
* Requêtes SQL paramétrées (bind de sqlx, diesel, sea-orm) ; jamais de format! avec une entrée dans une requête.
* Toute entrée validée à la frontière du système, invariants portés par les types (newtypes), refus explicite d'une entrée invalide.
* Chemins de fichiers reçus canonicalisés et confinés au répertoire autorisé (pas de traversée par ..).
* Messages d'erreur génériques côté client : ni chemin interne, ni trace, ni erreur de base ; détail journalisé par tracing ou log, sans secret ni donnée personnelle.
* Dépendances : nombre minimal, toute nouvelle crate évaluée (maintenance, licence) et soumise à l'utilisateur ; cargo audit et cargo deny check si configurés.
