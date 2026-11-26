---
paths: "**/*.rs"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle de Rust (Rust API Guidelines, The Rust Programming Language) et affaan-m/ecc (rules/rust) ; voir NOTICE.md. -->

* Formatage par rustfmt (cargo fmt) et lints par clippy sans avertissement (cargo clippy -- -D warnings) ; respecter rustfmt.toml, la configuration clippy et la section [lints] du projet.
* Casse conforme à la RFC 430 : snake_case pour fonctions, méthodes, variables, modules et crates ; UpperCamelCase pour types, traits et variantes ; SCREAMING_SNAKE_CASE pour constantes et statiques.
* Nommage des API : conversions as_ (emprunt, coût nul), to_ (coûteuse), into_ (consomme) ; accesseurs sans préfixe get_ (fn nom(&self)) ; itérateurs iter, iter_mut, into_iter ; ordre des mots cohérent dans tout le crate.
* Immutabilité par défaut (let, let mut seulement si nécessaire) ; retourner une nouvelle valeur plutôt que muter ; pas de paramètre de sortie (out-parameter) : retourner une valeur ou un tuple.
* Emprunt par défaut (&T) ; propriété seulement pour stocker ou consommer ; paramètres &str et &[T] plutôt que String et Vec, impl Into<String> ou AsRef dans les constructeurs ; l'appelant décide des copies. Jamais de clone pour contenter le vérificateur d'emprunt sans en comprendre la cause.
* Erreurs : Result et ? quand l'échec est une possibilité attendue ; panique réservée à un état incohérent inattendu dont la suite du code dépend. unwrap jamais hors tests ; expect seulement pour un invariant garanti par ailleurs, avec un message disant pourquoi il tient, sauf si le projet l'interdit (clippy::expect_used).
* Traits courants implémentés quand ils ont un sens (Debug sur tout type public, jamais vide ; Clone, PartialEq, Eq, Hash, Default, Display) ; conversions par From, TryFrom, AsRef plutôt que des méthodes ad hoc ; constructeurs en méthodes statiques inhérentes (new, with_...).
* Une fonction qui a un receveur naturel est une méthode ; Deref et DerefMut réservés aux pointeurs intelligents ; surcharges d'opérateurs sans surprise.
* Itérateurs pour les transformations, boucle pour un flot de contrôle complexe à retours anticipés.
* Visibilité privée par défaut, pub(crate) pour le partage interne, pub limité à l'API réexportée par lib.rs ; champs de structure privés dans une API publique.
* Documentation rustdoc des éléments publics, exemples utilisant ? (jamais unwrap), sections Errors, Panics et Safety quand elles s'appliquent.
* unsafe évité ; tout bloc unsafe justifié par un commentaire // SAFETY: décrivant les invariants, jamais pour contourner le vérificateur d'emprunt ; respecter un éventuel forbid(unsafe_code).
* Vérifier après modification par cargo check, puis clippy.
