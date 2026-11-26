---
paths: "**/*.rs"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), adapté de affaan-m/ecc (rules/rust, licence MIT, voir NOTICE.md). -->

* Formatage par rustfmt (cargo fmt) et lints par clippy sans avertissement (cargo clippy -- -D warnings) ; respecter rustfmt.toml et la configuration clippy du projet.
* Conventions : snake_case pour fonctions, variables, modules et crates ; PascalCase pour types, traits et énumérations ; MAJUSCULES_SOULIGNEES pour constantes et statiques ; durées de vie courtes ('a), descriptives si complexes.
* Immutabilité par défaut (let, let mut seulement si nécessaire) ; retourner une nouvelle valeur plutôt que muter ; Cow quand une allocation n'est pas toujours nécessaire.
* Emprunt par défaut (&T) ; propriété seulement pour stocker ou consommer ; paramètres &str et &[T] plutôt que String et Vec ; impl Into<String> dans les constructeurs. Jamais de clone pour contenter le vérificateur d'emprunt sans en comprendre la cause.
* Erreurs : Result et ? pour la propagation ; erreurs typées par thiserror dans une bibliothèque, anyhow avec contexte (with_context) dans une application ; jamais unwrap ni expect hors tests et états réellement inatteignables.
* Itérateurs pour les transformations, boucle pour un flot de contrôle complexe à retours anticipés.
* Visibilité privée par défaut, pub(crate) pour le partage interne, pub limité à l'API publique réexportée par lib.rs.
* unsafe évité ; tout bloc unsafe justifié par un commentaire // SAFETY: décrivant les invariants, jamais pour contourner le vérificateur d'emprunt. Respecter un éventuel forbid(unsafe_code) du projet.
* Vérifier après modification par cargo check (plus rapide que cargo build), puis clippy.
