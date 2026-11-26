# Phase 5 : stacks Angular et Rust

Document généré avec l'assistance de l'IA (Claude), à relire et valider avant toute mise en œuvre.

## Sommaire

* [Objectif](#objectif)
* [Contenu](#contenu)
* [Critères de sortie](#critères-de-sortie)
* [Rapport](#rapport)

Phase du [plan de démarrage](01_planDeDemarrage.md#phases).

## Objectif

Livrer stack-ts-angular puis stack-rust-tauri en intégrant les retours du pilote.

## Contenu

* stack-ts-angular et stack-rust-tauri : règles livrées par anticipation en phase 3 (26/11/2026, à la demande du mainteneur, voir le [rapport de la phase 3](01_rapportDeDemarrage_03_stackJavaSpring.md#enrichissement-et-nouvelles-stacks)) ; reste le hook PostToolUse de formatage (Prettier et ESLint pour TypeScript et Angular, rustfmt pour Rust) et la relecture des règles au vu du pilote.
* Règles de langage par thème, injectées par motif de fichier, selon le modèle de la [phase 3](01_planDeDemarrage_03_stackJavaSpring.md#contenu).
* Réduction de l'index de suiviprojets dans regles-projets aux seules spécificités du projet, les règles Angular et Rust étant portées par les plugins de stack.

## Critères de sortie

* Mêmes critères que la [phase 3](01_planDeDemarrage_03_stackJavaSpring.md#critères-de-sortie), pour chaque stack.
* Période early access avant promotion en stable.

## Rapport

À rédiger à la fin de la phase, dans le fichier 01_rapportDeDemarrage_05_stacksAngularRust.md.
