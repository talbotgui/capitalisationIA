# Plan de mise en place du marketplace capitalisationIA

Document généré avec l'assistance de l'IA (Claude), à relire et valider avant toute mise en œuvre.

## Sommaire

* [Objectif](#objectif)
* [Décisions actées](#décisions-actées)
* [Architecture du dépôt](#architecture-du-dépôt)
* [Canaux stable et early access](#canaux-stable-et-early-access)
* [Identification d'un projet](#identification-dun-projet)
* [Versionnage et publication](#versionnage-et-publication)
* [Plugins prévus](#plugins-prévus)
* [Distribution sur les postes](#distribution-sur-les-postes)
* [Sécurité de la chaîne de livraison](#sécurité-de-la-chaîne-de-livraison)
* [Exploitation](#exploitation)
* [Intégration continue](#intégration-continue)
* [Phases](#phases)
* [Points ouverts](#points-ouverts)

## Objectif

Industrialiser la configuration de Claude Code sur une cinquantaine de projets hétérogènes, sans aucune trace de configuration Claude Code dans les dépôts de code des projets (ni fichier versionné, ni fichier non versionné dans l'arbre de travail).

## Décisions actées

* Dépôt unique et public talbotgui/capitalisationIA contenant tous les plugins, les règles des projets et deux catalogues.
* Deux marketplaces dès le départ : capitalisation-ia (stable) et capitalisation-ia-early (early access).
* Stacks pilotes : Stack1 Java + Spring Boot, Stack2 TypeScript + Angular, Stack3 Rust.
* Traçabilité : hook UserPromptSubmit sur le modèle de talbotgui/suiviProjets/.claude/hooks/journaliser-prompt.sh (pas de hook SessionEnd pour ce besoin), journal stocké hors des projets.
* Pas de garde-fous via des hooks PreToolUse.
* Distribution par script utilisateur (portée user), pas de managed settings à ce stade.
* Règles propres à chaque projet hors des dépôts de code : plugin unique regles-projets qui identifie le projet par son remote git ; les règles sont stockées dans ce dépôt (cadence de publication à surveiller).
* Environnement des postes : exclusivement Git Bash, jq installé.
* Publication stable par un workflow GitHub Actions à déclenchement manuel.
* Conventions de rédaction reprises de suiviProjets : français, mention d'origine IA en en-tête de fichier, un paragraphe par ligne, sommaire en tête des documents, aucun emoji.

## Architecture du dépôt

```
capitalisationIA/
├── .claude-plugin/marketplace.json                       catalogue stable « capitalisation-ia »
├── canaux/early-access/.claude-plugin/marketplace.json   catalogue « capitalisation-ia-early »
├── plugins/
│   ├── socle/                                 journal des prompts, conventions git, bibliothèque commune
│   │   └── CHANGELOG.md
│   ├── regles-projets/                        règles par projet chargées au SessionStart
│   │   ├── projets/mapping.json               remote normalisé vers dossier projet
│   │   ├── projets/<projet>/                  index.md, nommage.md, conception.md, securite.md, tests.md
│   │   └── CHANGELOG.md
│   ├── stack-java-spring/
│   ├── stack-ts-angular/
│   └── stack-rust/
├── outils/
│   ├── installer.sh                           script d'installation poste développeur
│   └── publier.sh                             logique de publication appelée par le workflow
├── tests/                                     tests bats et fixtures des scripts de hooks
├── .github/workflows/
│   ├── validation.yml                         contrôles sur PR et sur main
│   └── publication.yml                        publication stable (workflow_dispatch)
├── .gitattributes                             *.sh text eol=lf
├── CODEOWNERS
└── README.md
```

## Canaux stable et early access

Les deux catalogues référencent les mêmes dossiers plugins/<nom> via des sources git-subdir pointant sur ce dépôt ; seule la référence git diffère.

* Early access : "ref": "main", aucun champ version dans l'entrée. La version calculée est alors le SHA du commit : chaque fusion sur main est livrée aux utilisateurs early access.
* Stable : "ref": "<plugin>--v<version>" (tag git) et "version": "<version>" dans l'entrée. Les utilisateurs stables ne reçoivent que les versions explicitement publiées.

Conséquence : le champ version est absent des plugin.json (sinon il primerait sur l'entrée et figerait le canal early access). claude plugin validate émet alors un avertissement sur chaque plugin ; --strict est donc réservé à la validation des catalogues.

Le catalogue stable étant à l'emplacement par défaut, /plugin marketplace add talbotgui/capitalisationIA donne le canal stable. Le catalogue early access, hors emplacement par défaut, est déclaré par le script d'installation via extraKnownMarketplaces avec le champ path.

Exclusion mutuelle : un même plugin ne doit jamais être activé simultanément depuis les deux catalogues, sous peine d'exécuter chaque hook deux fois (double journalisation, double formatage). Trois protections :

* installer.sh désactive explicitement dans enabledPlugins toutes les entrées de l'autre canal ;
* chaque hook vérifie qu'il est l'instance du canal actif (comparaison de CLAUDE_PLUGIN_ROOT avec le canal déclaré dans les settings) et sort en code 0 sans rien faire sinon ;
* la bascule de canal fait l'objet d'un test automatisé.

Hypothèses à valider par prototype en phase 0, avant tout autre développement : comportement de git-subdir avec un tag en ref, version calculée depuis le SHA en l'absence de version, déclaration du catalogue early access via path dans extraKnownMarketplaces, résolution des dependencies avec les tags <plugin>--v<version> et catalogue dans lequel la dépendance d'un plugin de stack vers socle est recherchée.

## Identification d'un projet

Une fonction unique de normalisation du remote, livrée dans socle et utilisée par tous les plugins (journal et règles), produit un identifiant de la forme hote/proprietaire/depot :

* formes acceptées : git@hote:proprietaire/depot.git, ssh://git@hote/proprietaire/depot.git, https://hote/proprietaire/depot(.git) ;
* suppression du suffixe .git et de l'éventuelle barre finale, passage en minuscules.

Cas particuliers :

* pas de remote origin : projet inconnu pour regles-projets ; pour le journal, identifiant de repli sans-remote/<nom du dossier racine> ;
* fork : identifié par son propre remote ; mapping.json accepte plusieurs remotes pour un même dossier projet ;
* monorepo : un remote correspond à un seul projet, le découpage par sous-dossier est hors périmètre à ce stade.

La fonction est couverte par des tests bats sur l'ensemble de ces formes.

## Versionnage et publication

* Semver par plugin, tags <plugin>--v<version> (convention utilisée aussi pour résoudre les plages de versions des dependencies).
* Un CHANGELOG.md par plugin.
* Version minimale de Claude Code requise documentée dans le README, vérifiée par installer.sh et épinglée dans la CI (les fonctionnalités paths des skills, dependencies et git-subdir sont récentes).

Publication par le workflow .github/workflows/publication.yml, déclenchement manuel (workflow_dispatch) avec deux entrées : plugin et version. Étapes :

1. Contrôles : exécution sur main uniquement, plugin existant, version semver strictement supérieure au dernier tag du plugin, CHANGELOG.md du plugin contenant une section pour cette version, validation verte sur le commit courant.
2. Création et push du tag <plugin>--v<version> sur le commit courant de main.
3. Mise à jour de l'entrée du catalogue stable (ref et version), commit et push sur main.
4. Résumé dans le journal du workflow (tag, commit, entrée modifiée).

Le tag est poussé avant le commit du catalogue, de sorte que le catalogue ne pointe jamais vers un tag absent. L'identité utilisée par le workflow doit être autorisée à contourner la protection de main pour ce seul commit (règle de contournement dédiée ou application GitHub). La logique est portée par outils/publier.sh pour rester testable hors CI.

Retour arrière : relancer le workflow en mode retour arrière (entrée supplémentaire) qui repointe l'entrée stable sur un tag antérieur existant, sans créer de tag. Propagation au prochain démarrage de Claude Code sur les postes (autoUpdate).

Renommage ou retrait d'un plugin : table renames des deux catalogues, displayName pour un simple changement de libellé.

## Plugins prévus

### socle

* Hook UserPromptSubmit journaliser-prompt.sh, adapté du modèle suiviProjets : même format (horodatage ISO 8601, prompt, séparateur ---), sortie toujours en code 0. Le journal est écrit hors du projet, dans ~/.claude/capitalisation-ia/journaux/<identifiant-projet>/prompts.log (identifiant issu de la normalisation du remote), ce qui évite toute écriture dans l'arbre de travail et toute modification de .git/info/exclude. La racine projet vient de CLAUDE_PROJECT_DIR. Les sous-agents ne déclenchent pas cet événement, comme dans le modèle.
* Journal : fichier en mode 600, dossier en mode 700 ; avertissement dans le README qu'il peut contenir des secrets collés dans un prompt ; rétention de 90 jours avec purge automatique des entrées plus anciennes au SessionStart.
* Bibliothèque commune de scripts : normalisation du remote, contrôle du canal actif, coupe-circuit.
* Skills : conventions de commits et mention d'origine IA, rédaction Markdown.
* Agent : explorateur-code générique en lecture seule (modèle de suiviProjets).

### regles-projets

* Hook SessionStart (matcher startup|resume|clear|compact) : normalise remote.origin.url, cherche le projet dans projets/mapping.json, injecte index.md et la liste des fichiers de règles ; aucun effet sur un projet inconnu.
* Modèle de dossier projet : index.md, nommage.md, conception.md, securite.md, tests.md.
* Le dépôt étant public, les règles des projets sont visibles de tous : aucune information confidentielle ne doit y figurer (contrôlé en revue de PR).

### Plugins de stack

* Dépendance au plugin socle.
* Skills avec paths (ex. **/*.java, pom.xml, build.gradle* ; **/*.ts, angular.json ; **/*.rs, Cargo.toml).
* Hook PostToolUse de formatage et d'analyse sur le modèle de formater-et-analyser.sh de suiviProjets, qui sort immédiatement si l'extension du fichier ou le marqueur de stack ne correspond pas.
* Contraintes de performance du hook PostToolUse : timeout explicite déclaré dans hooks.json, traitement du seul fichier modifié, utilisation exclusive des outils déjà présents dans le projet ou sur le poste (aucune installation), sortie silencieuse si l'outil est absent.
* Pas de serveur MCP dans les plugins de stack ; un MCP éventuel fera l'objet d'un plugin séparé.

### Règles communes à tous les hooks

* Coupe-circuit : la variable d'environnement CAPIA_DESACTIVER=1 (ou CAPIA_DESACTIVER=<plugin>,<plugin>) fait sortir les hooks concernés immédiatement en code 0, sans modification du dépôt projet.
* Contrôle du canal actif (voir Canaux stable et early access).
* Scripts en fins de ligne LF (.gitattributes) et bit exécutable positionné dans git.

### Coexistence avec une configuration existante

Certains projets possèdent déjà un CLAUDE.md ou un .claude/settings.json versionné. Règle retenue : la configuration du projet prime ; les règles injectées par regles-projets le signalent en tête (« en cas de contradiction avec le CLAUDE.md du projet, ce dernier prévaut ») et les conflits détectés pendant le pilote sont remontés pour arbitrage.

## Distribution sur les postes

outils/installer.sh [stable|early] :

1. Vérifie les prérequis : Git Bash, claude (version minimale), git, jq.
2. Fusionne avec jq dans ~/.claude/settings.json les entrées extraKnownMarketplaces (avec autoUpdate: true) et enabledPlugins du canal choisi, désactive explicitement les plugins de l'autre canal, sans écraser le reste du fichier (sauvegarde préalable).
3. Lance claude plugin install <plugin>@<marketplace> --scope user pour chaque plugin.
4. Affiche la vérification à faire (/plugin dans une session).

Bascule de canal : relancer le script avec l'autre canal.

Le dépôt étant public, aucun jeton n'est nécessaire pour l'installation ni pour la mise à jour automatique.

## Sécurité de la chaîne de livraison

Toute fusion sur main exécute du code sur les postes early access, et toute publication sur les postes stables, sur une cinquantaine de projets.

* Protection de la branche main : PR obligatoire, revue obligatoire par CODEOWNERS, validation verte requise, pas de push direct (hors identité du workflow de publication).
* Tags protégés (création réservée au workflow de publication), signature des tags à étudier.
* Revue de sécurité de tout script de hook en PR (point de la checklist de revue).

## Exploitation

* Retour arrière : voir Versionnage et publication.
* Désactivation ponctuelle : coupe-circuit CAPIA_DESACTIVER.
* Journal des prompts : rétention 90 jours, purge automatique, analyse RGPD à mener si des postes non personnels sont concernés.
* Mesure pour le pilote : nombre de postes et de projets équipés, incidents remontés, temps passé dans les hooks (horodatage début et fin consigné par chaque hook dans un journal technique local), retours qualitatifs des utilisateurs.

## Intégration continue

GitHub Actions sur chaque PR et sur main (validation.yml) :

* Installation de Claude Code en version épinglée.
* claude plugin validate --strict sur les deux catalogues, claude plugin validate sur chaque plugin.
* shellcheck sur tous les scripts.
* Tests bats des hooks : injection de JSON d'événement sur des projets fixtures (Java, Angular, Rust, inconnu, sans remote, fork) et vérification des sorties et fichiers produits.
* Tests bats de la normalisation du remote, de la bascule de canal (exclusion mutuelle) et du coupe-circuit.
* Contrôle de cohérence : chaque entrée stable pointe vers un tag existant, chaque plugin a un CHANGELOG.md, aucun plugin.json ne porte de champ version.

## Phases

Chaque phase est relue dans un contexte isolé et validée explicitement avant de passer à la suivante, sur la base de critères de sortie vérifiables.

1. Phase 0 : fondations (arborescence, catalogues, README, .gitattributes, CI, CODEOWNERS, protection de main, workflow de publication, installer.sh) et prototype des deux canaux. Critères de sortie : sur un poste vierge, installation stable puis early access puis retour en stable réussie avec un plugin factice ; hypothèses de la section Canaux stable et early access confirmées ou plan amendé ; publication et retour arrière du plugin factice réussis via le workflow.
2. Phase 1 : plugin socle, publication socle--v1.0.0. Critères de sortie : tests bats verts, journal écrit hors projet avec les bons droits, purge vérifiée, aucun fichier créé dans les projets fixtures.
3. Phase 2 : plugin regles-projets et modèle de dossier projet. Critères de sortie : règles injectées sur un projet connu, aucun effet sur un projet inconnu ou sans remote, réinjection après compact vérifiée.
4. Phase 3 : stack-java-spring. Critères de sortie : formatage effectif sur un projet Java fixture, sortie silencieuse sur les autres stacks, durée du hook inférieure au timeout déclaré.
5. Phase 4 : pilote early access sur 2 à 3 projets Java. Critères de sortie : indicateurs de la section Exploitation collectés sur au moins deux semaines, incidents bloquants corrigés, décision de promotion en stable de socle, regles-projets et stack-java-spring.
6. Phase 5 : stack-ts-angular puis stack-rust, en intégrant les retours du pilote, chacun passant par une période early access avant promotion.
7. Phase 6 : généralisation progressive aux autres projets en stable.

## Points ouverts

* Accès en écriture de Claude au dépôt : installer l'application GitHub Claude sur talbotgui/capitalisationIA.
* Identité du workflow de publication autorisée à pousser sur main protégée : règle de contournement GitHub Actions ou application GitHub dédiée.
* Signature des tags de publication.
* Analyse RGPD du journal des prompts selon la nature des postes.
