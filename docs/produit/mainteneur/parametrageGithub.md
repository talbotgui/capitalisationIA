# Paramétrage GitHub du dépôt

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [Principe](#principe)
* [Étape 1 : application GitHub de publication](#étape-1--application-github-de-publication)
* [Étape 2 : environnement publication](#étape-2--environnement-publication)
* [Étape 3 : ruleset protection-main](#étape-3--ruleset-protection-main)
* [Étape 4 : ruleset tags-publication](#étape-4--ruleset-tags-publication)
* [Étape 5 : statut obligatoire de validation.yml](#étape-5--statut-obligatoire-de-validationyml)

Retour à l'[accueil de la documentation mainteneur](index.md).

## Principe

La branche main et les tags de version sont protégés par des rulesets. Le jeton par défaut des workflows (GITHUB_TOKEN) ne peut pas contourner ces protections ; le workflow de publication utilise donc le jeton d'une application GitHub dédiée, seule identité autorisée à pousser directement sur main et à créer les tags de version.

Les libellés de l'interface GitHub cités dans cette procédure sont ceux en vigueur au 19/11/2026 ; ils peuvent avoir évolué depuis.

## Étape 1 : application GitHub de publication

1. Ouvrir l'écran Settings > Developer settings > GitHub Apps du compte : https://github.com/settings/apps
2. Cliquer sur New GitHub App et renseigner :
   * GitHub App name : capitalisation-ia-publication ;
   * Homepage URL : https://github.com/talbotgui/capitalisationIA ;
   * Webhook : décocher Active ;
   * Repository permissions > Contents : Read and write, toutes les autres permissions restant à No access ;
   * Where can this GitHub App be installed? : Only on this account.
3. Cliquer sur Create GitHub App et noter l'App ID affiché.
4. Dans la section Private keys, cliquer sur Generate a private key : un fichier .pem est téléchargé.
5. Dans le menu Install App, installer l'application sur le compte en choisissant Only select repositories, puis le dépôt capitalisationIA.

## Étape 2 : environnement publication

1. Dans le dépôt : Settings > Environments > New environment, nom publication.
2. Deployment branches and tags : Selected branches and tags, ajouter la règle main.
3. Environment variables : ajouter PUBLICATION_APP_ID avec l'App ID noté à l'étape 1.
4. Environment secrets : ajouter PUBLICATION_APP_KEY avec le contenu complet du fichier .pem (lignes BEGIN et END comprises).
5. Supprimer le fichier .pem du poste.

La restriction à la branche main empêche un workflow lancé depuis une autre branche d'accéder à la clé.

## Étape 3 : ruleset protection-main

1. Dans le dépôt : Settings > Rules > Rulesets > New ruleset > New branch ruleset.
2. Ruleset name : protection-main ; Enforcement status : Active.
3. Target branches : Add target > Include default branch.
4. Bypass list :
   * l'application capitalisation-ia-publication, en Always allow ;
   * le rôle Repository admin, en For pull requests only (sans cela, un mainteneur seul ne peut pas fusionner ses propres PR, GitHub interdisant d'approuver sa propre PR).
5. Rules :
   * Restrict deletions ;
   * Block force pushes ;
   * Require a pull request before merging, avec Require review from Code Owners ;
   * Require status checks to pass : ne pas renseigner à ce stade, voir l'étape 5.
6. Vérifier dans Settings > Branches qu'aucune règle de protection classique ne s'applique à main ; la supprimer le cas échéant.

## Étape 4 : ruleset tags-publication

1. Dans le dépôt : Settings > Rules > Rulesets > New ruleset > New tag ruleset.
2. Ruleset name : tags-publication ; Enforcement status : Active.
3. Target tags : Add target > Include by pattern, motif *--v*.
4. Bypass list : l'application capitalisation-ia-publication, en Always allow.
5. Rules : Restrict creations, Restrict updates, Restrict deletions.

## Étape 5 : statut obligatoire de validation.yml

Le job du workflow .github/workflows/validation.yml n'existe pas tant que ce workflow n'a pas été fusionné sur main et exécuté au moins une fois : GitHub ne propose dans la liste des statuts que ceux qu'il a déjà vus. Cette étape est donc réalisée en fin de phase 0.

1. Fusionner la PR qui ajoute validation.yml et attendre la fin de son exécution sur main (onglet Actions).
2. Settings > Rules > Rulesets > protection-main.
3. Cocher Require status checks to pass, puis Add checks et sélectionner le job nommé validation (source GitHub Actions).
4. Cocher Require branches to be up to date before merging.
5. Enregistrer.
