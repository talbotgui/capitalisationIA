# Phase 3 : stack Java Spring

Document généré avec l'assistance de l'IA (Claude), à relire et valider avant toute mise en œuvre.

## Sommaire

* [Objectif](#objectif)
* [Contenu](#contenu)
* [Critères de sortie](#critères-de-sortie)
* [Rapport](#rapport)

Phase du [plan de démarrage](01_planDeDemarrage.md#phases).

## Objectif

Livrer le plugin stack-java-spring (voir [Plugins de stack](01_planDeDemarrage.md#plugins-de-stack)).

## Contenu

* Prototype en début de phase : comportement de paths des skills sur la version épinglée de Claude Code (activation limitée aux fichiers correspondants, contexte consommé).
* Règles Java/Spring en skills avec paths, une par thème : développement, conception, tests, Maven/Gradle (voir [Organisation des règles](01_planDeDemarrage.md#organisation-des-règles)).
* Hook PostToolUse de formatage et d'analyse.

## Critères de sortie

* Formatage effectif sur un projet Java fixture.
* Sortie silencieuse sur les autres stacks.
* Skills activées sur un projet Java fixture, non activées sur un projet d'une autre stack.
* Durée du hook inférieure au timeout déclaré.

## Rapport

[01_rapportDeDemarrage_03_stackJavaSpring.md](01_rapportDeDemarrage_03_stackJavaSpring.md)
