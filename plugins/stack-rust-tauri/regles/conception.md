---
paths: "**/src/**/*.rs"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), adapté de affaan-m/ecc (rules/rust, licence MIT, voir NOTICE.md). -->

* Modules organisés par domaine fonctionnel (auth/, commandes/), l'infrastructure à part (db/, persistance/), en respectant l'organisation existante du projet.
* Accès aux données derrière un trait (Send + Sync si partagé) ; implémentations concrètes séparées, en mémoire pour les tests.
* Logique métier dans des structures de service dont les dépendances sont injectées au constructeur.
* Newtypes (struct UserId(u64)) pour éviter la confusion d'arguments et porter les invariants ; « parser plutôt que valider » : convertir les données non structurées en types valides à la frontière.
* États modélisés par des énumérations rendant les états illégaux non représentables ; match exhaustif, sans joker _ sur une énumération métier.
* Builder pour les structures à nombreux paramètres optionnels ; trait scellé (module privé) pour interdire les implémentations externes quand c'est voulu.
* Concurrence : jamais de verrou std::sync::Mutex conservé à travers un .await (tokio::sync::Mutex ou portée réduite) ; aucune opération bloquante dans une tâche asynchrone (spawn_blocking).
