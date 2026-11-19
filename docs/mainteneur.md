# Documentation du mainteneur

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [Objet](#objet)
* [Paramétrage GitHub du dépôt](#paramétrage-github-du-dépôt)
  * [Étape 1 : application GitHub de publication](#étape-1--application-github-de-publication)
  * [Étape 2 : environnement publication](#étape-2--environnement-publication)
  * [Étape 3 : ruleset protection-main](#étape-3--ruleset-protection-main)
  * [Étape 4 : ruleset tags-publication](#étape-4--ruleset-tags-publication)
  * [Étape 5 : statut obligatoire de validation.yml](#étape-5--statut-obligatoire-de-validationyml)
* [Publication d'une version stable](#publication-dune-version-stable)
* [Organisation du dépôt et conventions](#organisation-du-dépôt-et-conventions)
* [Ajout d'un plugin](#ajout-dun-plugin)
* [Tests et contrôles en local](#tests-et-contrôles-en-local)
* [Sections à compléter](#sections-à-compléter)

## Objet

Ce document s'adresse au mainteneur du dépôt talbotgui/capitalisationIA. Il décrit le paramétrage GitHub et les procédures de maintenance du marketplace. La documentation des utilisateurs du marketplace est dans docs/utilisateur.md.

## Paramétrage GitHub du dépôt

Principe : la branche main et les tags de version sont protégés par des rulesets. Le jeton par défaut des workflows (GITHUB_TOKEN) ne peut pas contourner ces protections ; le workflow de publication utilise donc le jeton d'une application GitHub dédiée, seule identité autorisée à pousser directement sur main et à créer les tags de version.

Les libellés de l'interface GitHub évoluent régulièrement ; ils peuvent différer légèrement de ceux indiqués ici.

### Étape 1 : application GitHub de publication

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

### Étape 2 : environnement publication

1. Dans le dépôt : Settings > Environments > New environment, nom publication.
2. Deployment branches and tags : Selected branches and tags, ajouter la règle main.
3. Environment variables : ajouter PUBLICATION_APP_ID avec l'App ID noté à l'étape 1.
4. Environment secrets : ajouter PUBLICATION_APP_KEY avec le contenu complet du fichier .pem (lignes BEGIN et END comprises).
5. Supprimer le fichier .pem du poste.

La restriction à la branche main empêche un workflow lancé depuis une autre branche d'accéder à la clé.

### Étape 3 : ruleset protection-main

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

### Étape 4 : ruleset tags-publication

1. Dans le dépôt : Settings > Rules > Rulesets > New ruleset > New tag ruleset.
2. Ruleset name : tags-publication ; Enforcement status : Active.
3. Target tags : Add target > Include by pattern, motif *--v*.
4. Bypass list : l'application capitalisation-ia-publication, en Always allow.
5. Rules : Restrict creations, Restrict updates, Restrict deletions.

### Étape 5 : statut obligatoire de validation.yml

Le job du workflow .github/workflows/validation.yml n'existe pas tant que ce workflow n'a pas été fusionné sur main et exécuté au moins une fois : GitHub ne propose dans la liste des statuts que ceux qu'il a déjà vus. Cette étape est donc réalisée en fin de phase 0.

1. Fusionner la PR qui ajoute validation.yml et attendre la fin de son exécution sur main (onglet Actions).
2. Settings > Rules > Rulesets > protection-main.
3. Cocher Require status checks to pass, puis Add checks et sélectionner le job nommé validation (source GitHub Actions).
4. Cocher Require branches to be up to date before merging.
5. Enregistrer.

## Publication d'une version stable

La publication passe exclusivement par le workflow .github/workflows/publication.yml, qui s'appuie sur outils/publier.sh. Aucun paramétrage GitHub supplémentaire n'est nécessaire au-delà des étapes 1 à 4.

1. Ajouter dans plugins/<plugin>/CHANGELOG.md une section « ## <version> » décrivant les changements, par PR fusionnée sur main.
2. Onglet Actions > publication > Run workflow, branche main.
3. Renseigner mode (publication), plugin (nom du dossier dans plugins/) et version (semver x.y.z, sans préfixe v).
4. Lancer, puis vérifier dans le résumé de l'exécution le tag créé et l'entrée du catalogue stable.

Fonctionnement du workflow :

1. Job validation : rejoue validation.yml sur le commit de main ayant déclenché la publication.
2. Job publier (environnement publication) : obtient un jeton de l'application grâce à PUBLICATION_APP_ID et PUBLICATION_APP_KEY, vérifie que main n'a pas évolué depuis le déclenchement, puis exécute outils/publier.sh.
3. outils/publier.sh contrôle les entrées (branche main, arbre propre, plugin existant, version semver strictement supérieure à la dernière publiée, section présente dans le CHANGELOG, absence de version dans plugin.json), crée et pousse le tag annoté <plugin>--v<version>, puis met à jour (ou crée) l'entrée du catalogue stable, committe et pousse sur main.
4. Ce push, effectué avec le jeton de l'application, déclenche validation.yml sur main.

Le tag est poussé avant le commit du catalogue : le catalogue stable ne pointe jamais vers un tag absent.

Retour arrière : même workflow avec le mode retour-arriere et la version antérieure visée. L'entrée du catalogue stable est repointée sur le tag existant, aucun tag n'est créé. Les postes reçoivent la version au démarrage suivant de Claude Code.

## Organisation du dépôt et conventions

* Chaque plugin est un dossier plugins/<nom> contenant .claude-plugin/plugin.json, README.md et CHANGELOG.md.
* plugin.json ne contient jamais de champ version : la version du canal early access est calculée à partir du commit, celle du canal stable est portée par l'entrée du catalogue stable. outils/verifier-coherence.sh le contrôle.
* Conséquence : la commande claude plugin tag, qui exige une version dans plugin.json, n'est pas utilisée ; les tags sont créés par outils/publier.sh.
* Les dépendances entre plugins (champ dependencies) sont déclarées par nom seul, sans plage de versions : une plage exige une version dans plugin.json au commit du tag. Le nom est résolu dans le catalogue du plugin qui déclare la dépendance, donc dans le même canal.
* Toutes les entrées des catalogues sont des sources git-subdir vers https://github.com/talbotgui/capitalisationIA.git, chemin plugins/<nom> ; ref main dans le catalogue early access, ref <plugin>--v<version> et champ version dans le catalogue stable.
* Le catalogue stable n'est modifié que par le workflow de publication.
* Le catalogue early access est déclaré sur les postes par son URL brute (https://raw.githubusercontent.com/talbotgui/capitalisationIA/main/canaux/early-access/.claude-plugin/marketplace.json), la CLI ne permettant pas de déclarer un catalogue situé hors de .claude-plugin/ à la racine d'un dépôt.
* Scripts : Bash, fins de ligne LF (.gitattributes), bit exécutable positionné dans git, conformes à shellcheck.
* Rédaction : français, mention d'origine IA en en-tête de fichier, un paragraphe par ligne, sommaire en tête des documents, aucun emoji.

## Ajout d'un plugin

1. Créer plugins/<nom>/.claude-plugin/plugin.json (name, description, author ; pas de version), README.md et CHANGELOG.md.
2. Ajouter l'entrée du plugin dans le catalogue early access (source git-subdir, ref main, sans version).
3. Ajouter les tests bats dans tests/.
4. Ouvrir une PR ; après fusion, le plugin est livré au canal early access.
5. Publier la première version stable avec le workflow publication : l'entrée du catalogue stable est créée automatiquement.

## Tests et contrôles en local

Prérequis : bats, shellcheck, jq et la CLI claude.

* shellcheck : git ls-files -z '*.sh' | xargs -0 shellcheck
* catalogues : claude plugin validate --strict canaux/early-access et claude plugin validate --strict . (sans --strict tant que le catalogue stable est vide)
* plugins : claude plugin validate plugins/<nom>
* cohérence : outils/verifier-coherence.sh
* tests : bats tests/

Les tests de outils/installer.sh s'exécutent sur une copie locale du dépôt et une configuration Claude Code isolée (CLAUDE_CONFIG_DIR) : ils ne touchent pas la configuration du poste et n'accèdent pas au réseau. Ils sont ignorés si la CLI claude est absente.

La version de Claude Code utilisée par la CI (CLAUDE_CODE_VERSION dans validation.yml) doit être égale à VERSION_MIN_CLAUDE de outils/installer.sh ; la CI le contrôle.

## Sections à compléter

Sections prévues par le plan, rédigées au fil des phases :

* ajout ou modification des règles d'un projet, normalisation du remote ;
* lecture des résultats de la CI ;
* renommage ou retrait d'un plugin ;
* checklist de revue de PR.
