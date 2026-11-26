---
paths: "**/*.rs"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), adapté de affaan-m/ecc (rules/rust, licence MIT, voir NOTICE.md). -->

* Tests unitaires dans un module #[cfg(test)] du fichier testé ; tests d'intégration dans tests/ (un binaire par fichier, utilitaires dans tests/common/) ; bancs d'essai dans benches/.
* Outils déjà présents dans le projet d'abord ; à défaut rstest (cas paramétrés, fixtures), proptest (propriétés), mockall (doublures de traits), #[tokio::test] pour l'asynchrone.
* Noms décrivant le scénario (rejette_commande_si_stock_insuffisant) ; un comportement par test ; vérifier les cas d'erreur (is_err, contenu du message).
* Aucune dépendance au réseau, à l'heure courante ou à l'ordre d'exécution ; données fixes et fictives ; fichiers temporaires dans un répertoire dédié (tempfile).
* Couverture selon le seuil du projet, à défaut 80 % des lignes (cargo llvm-cov) en priorité sur la logique métier.
* Lancer les tests concernés après modification (cargo test nom_du_test, cargo test --lib) et rapporter le résultat réel.
