---
paths:
  - "**/Cargo.toml"
  - "**/rust-toolchain.toml"
  - "**/deny.toml"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle de Rust (Rust API Guidelines, The Rust Programming Language) et affaan-m/ecc (rules/rust) ; voir NOTICE.md. -->

* Toute nouvelle crate est justifiée (besoin, maintenance, licence permissive, nombre de dépendances transitives) et soumise à l'utilisateur avant ajout ; fonctionnalités (features) limitées au nécessaire, default-features = false quand c'est pertinent ; noms de features sans mot de remplissage (pas de use-, with-).
* Dépendance critique prise depuis git : révision par empreinte (rev), à défaut par étiquette (tag), jamais par branche.
* Cargo.lock committé pour une application ; construction reproductible (cargo build --locked).
* Versions des dépendances partagées centralisées dans [workspace.dependencies] pour un espace de travail.
* Crate publié : métadonnées complètes (description, license, repository, documentation, keywords, categories) ; dépendances publiques d'un crate stable elles-mêmes stables.
* Ne pas modifier l'édition, la chaîne d'outils (rust-toolchain.toml), les lints ([lints]) ni la configuration cargo deny sans demande explicite ; maintenir rustc et les dépendances à jour pour leurs correctifs de sécurité.
* Contrôler l'arbre des dépendances après ajout (cargo tree -d pour les doublons) ; cargo audit et cargo deny check si configurés.
