---
paths: "**/src/**/*.rs"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle de Rust (Rust API Guidelines, The Rust Programming Language) et affaan-m/ecc (rules/rust) ; voir NOTICE.md. -->

* Modules organisés par domaine fonctionnel, l'infrastructure à part (persistance, connecteurs), en respectant l'organisation existante ; pour un exécutable, main.rs minimal et logique dans lib.rs (testable, y compris par des tests d'intégration).
* Accès aux données derrière un trait (Send + Sync si partagé, utilisable comme objet de trait si utile) ; implémentations concrètes séparées, en mémoire pour les tests ; logique métier dans des services dont les dépendances sont injectées au constructeur.
* Sécurité par les types : newtypes pour distinguer statiquement les valeurs et masquer l'implémentation ; arguments porteurs de sens par des types dédiés plutôt que bool ou Option ; bitflags pour un ensemble d'options ; builder pour une construction complexe ; « parser plutôt que valider » à la frontière.
* États modélisés par des énumérations rendant les états illégaux non représentables ; match exhaustif, sans joker _ sur une énumération métier.
* Fonctions qui valident leurs arguments ; destructeurs (Drop) qui n'échouent jamais et ne bloquent pas sans alternative explicite.
* Types d'erreur significatifs : implémentent std::error::Error, Display et Debug, Send + Sync + 'static, une variante par cause exploitable par l'appelant (thiserror).
* Types Send et Sync quand c'est possible ; Serialize et Deserialize (serde) sur les structures de données échangées.
* Trait scellé (module privé) pour interdire les implémentations externes ; bornes de traits dérivés non dupliquées sur les structures.
* Concurrence : Mutex de la bibliothèque standard par défaut, y compris en asynchrone ; Mutex asynchrone (tokio) seulement si le verrou doit être conservé à travers un .await ; aucune opération bloquante dans une tâche asynchrone (spawn_blocking).
