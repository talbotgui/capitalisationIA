---
paths:
  - "**/Cargo.toml"
  - "**/rust-toolchain.toml"
  - "**/deny.toml"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), adapté de affaan-m/ecc (rules/rust, licence MIT, voir NOTICE.md). -->

* Toute nouvelle crate est justifiée (besoin, maintenance, licence, nombre de dépendances transitives) et soumise à l'utilisateur avant ajout ; fonctionnalités (features) limitées au nécessaire, default-features = false quand c'est pertinent.
* Cargo.lock committé pour une application ; construction reproductible (cargo build --locked).
* Versions des dépendances partagées centralisées dans [workspace.dependencies] pour un espace de travail.
* Ne pas modifier l'édition, la chaîne d'outils (rust-toolchain.toml), les lints ([lints]) ni la configuration cargo deny sans demande explicite.
* Contrôler l'arbre des dépendances après ajout (cargo tree -d pour les doublons).
