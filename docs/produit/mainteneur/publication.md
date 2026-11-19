# Publication d'une version stable

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [Procédure](#procédure)
* [Fonctionnement du workflow](#fonctionnement-du-workflow)
* [Retour arrière](#retour-arrière)

Retour à l'[accueil de la documentation mainteneur](index.md).

## Procédure

La publication passe exclusivement par le workflow .github/workflows/publication.yml, qui s'appuie sur outils/publier.sh. Aucun paramétrage GitHub supplémentaire n'est nécessaire au-delà des étapes 1 à 4 du [paramétrage GitHub](parametrageGithub.md).

1. Ajouter dans plugins/<plugin>/CHANGELOG.md une section « ## <version> » décrivant les changements, par PR fusionnée sur main.
2. Onglet Actions > publication > Run workflow, branche main.
3. Renseigner mode (publication), plugin (nom du dossier dans plugins/) et version (semver x.y.z, sans préfixe v).
4. Lancer, puis vérifier dans le résumé de l'exécution le tag créé et l'entrée du catalogue stable.

## Fonctionnement du workflow

Étapes :

1. Job validation : rejoue validation.yml sur le commit de main ayant déclenché la publication.
2. Job publier (environnement publication) : obtient un jeton de l'application grâce à PUBLICATION_APP_ID et PUBLICATION_APP_KEY, vérifie que main n'a pas évolué depuis le déclenchement, puis exécute outils/publier.sh.
3. outils/publier.sh contrôle les entrées (branche main, arbre propre, plugin existant, version semver strictement supérieure à la dernière publiée, section présente dans le CHANGELOG, absence de version dans plugin.json), crée et pousse le tag annoté <plugin>--v<version>, puis met à jour (ou crée) l'entrée du catalogue stable, committe et pousse sur main.
4. Ce push, effectué avec le jeton de l'application, déclenche validation.yml sur main.

Le tag est poussé avant le commit du catalogue : le catalogue stable ne pointe jamais vers un tag absent.

## Retour arrière

Retour arrière : même workflow avec le mode retour-arriere et la version antérieure visée. L'entrée du catalogue stable est repointée sur le tag existant, aucun tag n'est créé. Les postes reçoivent la version au démarrage suivant de Claude Code.
