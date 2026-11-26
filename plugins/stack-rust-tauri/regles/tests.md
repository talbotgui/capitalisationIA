---
paths: "**/*.rs"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle de Rust (Rust API Guidelines, The Rust Programming Language) et affaan-m/ecc (rules/rust) ; voir NOTICE.md. -->

* Tests unitaires dans un module tests annoté #[cfg(test)] du fichier testé (ils peuvent tester les fonctions privées) ; tests d'intégration dans tests/ à la racine du crate (un binaire par fichier, utilitaires partagés dans tests/common/mod.rs), possibles seulement sur un crate bibliothèque ; bancs d'essai dans benches/.
* Outils déjà présents dans le projet d'abord ; à défaut rstest (cas paramétrés, fixtures), proptest (propriétés), mockall (doublures de traits), #[tokio::test] pour l'asynchrone.
* Noms décrivant le scénario (rejette_commande_si_stock_insuffisant) ; un comportement par test ; cas d'erreur vérifiés (is_err, contenu du message), paniques attendues par #[should_panic(expected = ...)].
* Exemples de la documentation compilés et exécutés comme tests (cargo test --doc).
* Aucune dépendance au réseau, à l'heure courante ou à l'ordre d'exécution ; données fixes et fictives ; fichiers temporaires dans un répertoire dédié (tempfile).
* Couverture selon le seuil du projet, à défaut 80 % des lignes (cargo llvm-cov) en priorité sur la logique métier.
* Lancer les tests concernés après modification (cargo test nom_du_test, cargo test --lib) et rapporter le résultat réel.
