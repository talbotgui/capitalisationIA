# Phase 0 : fondations

Document généré avec l'assistance de l'IA (Claude), à relire et valider avant toute mise en œuvre.

## Sommaire

* [Objectif](#objectif)
* [Contenu](#contenu)
* [Critères de sortie](#critères-de-sortie)
* [Rapport](#rapport)

Phase du [plan de démarrage](01_planDeDemarrage.md#phases).

## Objectif

Mettre en place le dépôt, les deux canaux, la publication et la CI, et valider par un prototype les hypothèses de la section [Canaux stable et early access](01_planDeDemarrage.md#canaux-stable-et-early-access).

## Contenu

* Arborescence, catalogues stable et early access, README, .gitattributes, CODEOWNERS.
* Paramétrage GitHub : application de publication, environnement, rulesets (voir [Sécurité de la chaîne de livraison](01_planDeDemarrage.md#sécurité-de-la-chaîne-de-livraison)).
* CI (validation.yml), workflow de publication (publication.yml) et outils/publier.sh.
* outils/installer.sh.
* Plugin de diagnostic temoin, support du prototype des deux canaux.
* [Documentation mainteneur](../produit/mainteneur/index.md) : paramétrage GitHub et publication.
* Ajout du statut obligatoire de validation.yml dans protection-main après sa première exécution sur main.

## Critères de sortie

* Sur un poste vierge, installation stable puis early access puis retour en stable réussie avec le plugin temoin.
* Hypothèses de la section [Canaux stable et early access](01_planDeDemarrage.md#canaux-stable-et-early-access) confirmées ou plan amendé.
* Publication et retour arrière du plugin temoin réussis via le workflow.
* Statut de validation.yml obligatoire dans protection-main.
* [Documentation mainteneur](../produit/mainteneur/index.md) couvrant le paramétrage GitHub et la publication.

## Rapport

[01_rapportDeDemarrage_00_fondation.md](01_rapportDeDemarrage_00_fondation.md)
