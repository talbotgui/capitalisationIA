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
* [Documentation](#documentation)
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
* Distribution par plugin (portée user) : commandes natives /plugin, puis skill /temoin:canal pour le choix du canal ; pas de managed settings à ce stade.
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
│   ├── temoin/                                diagnostic (canal et version actifs) et skill /temoin:canal
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
│   ├── publier.sh                             logique de publication appelée par le workflow
│   └── verifier-coherence.sh                  contrôles de cohérence des catalogues et plugins (CI)
├── .claude/rules/collaboration.md             règles de collaboration avec Claude sur ce dépôt
├── docs/
│   ├── produit/
│   │   ├── mainteneur/                        documentation du mainteneur (accueil index.md et pages)
│   │   └── utilisateur.md                     documentation de l'utilisateur du marketplace et des plugins
│   └── projet/                                plans, phases et rapports
├── tests/                                     tests bats et fixtures des scripts de hooks
├── .github/workflows/
│   ├── validation.yml                         contrôles sur PR et sur main
│   └── publication.yml                        publication stable (workflow_dispatch)
├── .gitattributes                             *.sh text eol=lf
├── CODEOWNERS
└── README.md                                  présentation courte et liens vers docs/
```

## Canaux stable et early access

Les deux catalogues référencent les mêmes dossiers plugins/<nom> via des sources git-subdir pointant sur ce dépôt ; seule la référence git diffère.

* Early access : "ref": "main", aucun champ version dans l'entrée. La version calculée est alors le SHA du commit : chaque fusion sur main est livrée aux utilisateurs early access.
* Stable : "ref": "<plugin>--v<version>" (tag git) et "version": "<version>" dans l'entrée. Les utilisateurs stables ne reçoivent que les versions explicitement publiées.

Conséquence : le champ version est absent des plugin.json (sinon il primerait sur l'entrée et figerait le canal early access). claude plugin validate émet alors un avertissement sur chaque plugin ; --strict est donc réservé à la validation des catalogues.

Le catalogue stable étant à l'emplacement par défaut, /plugin marketplace add talbotgui/capitalisationIA donne le canal stable. Le catalogue early access, hors emplacement par défaut, est déclaré par son URL brute (source url : https://raw.githubusercontent.com/talbotgui/capitalisationIA/main/canaux/early-access/.claude-plugin/marketplace.json) ; c'est possible parce que toutes ses entrées sont des sources git-subdir absolues. La déclaration via le champ path d'une source git dans extraKnownMarketplaces, envisagée initialement, n'est pas prise en compte par la CLI (prototype). La mise à jour automatique est activée par le champ autoUpdate de l'entrée extraKnownMarketplaces du marketplace.

Exclusion mutuelle : un même plugin ne doit jamais être activé simultanément depuis les deux catalogues, sous peine d'exécuter chaque hook deux fois (double journalisation, double formatage). Trois protections :

* la skill /temoin:canal désactive toutes les entrées de l'autre canal ;
* chaque hook vérifie qu'il est l'instance du canal actif (comparaison de CLAUDE_PLUGIN_ROOT avec le canal déclaré dans les settings) et sort en code 0 sans rien faire sinon ;
* la bascule de canal fait l'objet d'un test automatisé.

Les résultats du prototype de phase 0 sont consignés dans le [rapport de la phase 0](01_rapportDeDemarrage_00_fondation.md#résultats-du-prototype).

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

* Semver par plugin, tags <plugin>--v<version> (convention de Claude Code). La commande claude plugin tag n'est pas utilisée car elle exige une version dans plugin.json ; les tags sont créés par outils/publier.sh.
* Un CHANGELOG.md par plugin.
* Version minimale de Claude Code requise documentée dans le README, vérifiée par la skill /temoin:canal et épinglée dans la CI (les fonctionnalités paths des skills, dependencies et git-subdir sont récentes).

Publication par le workflow .github/workflows/publication.yml, déclenchement manuel (workflow_dispatch) avec deux entrées : plugin et version. Étapes :

1. Contrôles : exécution sur main uniquement, plugin existant, version semver strictement supérieure au dernier tag du plugin, CHANGELOG.md du plugin contenant une section pour cette version, validation verte sur le commit courant.
2. Création et push du tag <plugin>--v<version> sur le commit courant de main.
3. Mise à jour de l'entrée du catalogue stable (ref et version), commit et push sur main.
4. Résumé dans le journal du workflow (tag, commit, entrée modifiée).

Le tag est poussé avant le commit du catalogue, de sorte que le catalogue ne pointe jamais vers un tag absent. Le workflow pousse avec le jeton de l'application GitHub capitalisation-ia-publication, seule identité autorisée à contourner les rulesets (voir [Sécurité de la chaîne de livraison](#sécurité-de-la-chaîne-de-livraison)). La logique est portée par outils/publier.sh pour rester testable hors CI.

Retour arrière : relancer le workflow en mode retour arrière (entrée supplémentaire) qui repointe l'entrée stable sur un tag antérieur existant, sans créer de tag. Propagation au prochain démarrage de Claude Code sur les postes (autoUpdate).

Renommage ou retrait d'un plugin : table renames des deux catalogues, displayName pour un simple changement de libellé.

## Plugins prévus

### temoin

* Plugin de diagnostic livré en phase 0 pour le prototype, conservé ensuite : hook SessionStart (startup) qui affiche à l'utilisateur le canal et la version chargés, et signale une activation simultanée dans les deux canaux, sans écrire de fichier.
* Skill /temoin:canal stable|early, réservée à l'invocation par l'utilisateur : configuration du canal sur le poste (voir [Distribution sur les postes](#distribution-sur-les-postes)).

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

* Dépendance au plugin socle, déclarée par nom seul (sans plage de versions).
* Skills avec paths (ex. **/*.java, pom.xml, build.gradle* ; **/*.ts, angular.json ; **/*.rs, Cargo.toml).
* Hook PostToolUse de formatage et d'analyse sur le modèle de formater-et-analyser.sh de suiviProjets, qui sort immédiatement si l'extension du fichier ou le marqueur de stack ne correspond pas.
* Contraintes de performance du hook PostToolUse : timeout explicite déclaré dans hooks.json, traitement du seul fichier modifié, utilisation exclusive des outils déjà présents dans le projet ou sur le poste (aucune installation), sortie silencieuse si l'outil est absent.
* Pas de serveur MCP dans les plugins de stack ; un MCP éventuel fera l'objet d'un plugin séparé.

### Règles communes à tous les hooks

* Coupe-circuit : la variable d'environnement CAPIA_DESACTIVER=1 (ou CAPIA_DESACTIVER=<plugin>,<plugin>) fait sortir les hooks concernés immédiatement en code 0, sans modification du dépôt projet.
* Contrôle du canal actif (voir [Canaux stable et early access](#canaux-stable-et-early-access)).
* Scripts en fins de ligne LF (.gitattributes) et bit exécutable positionné dans git.

### Coexistence avec une configuration existante

Certains projets possèdent déjà un CLAUDE.md ou un .claude/settings.json versionné. Règle retenue : la configuration du projet prime ; les règles injectées par regles-projets le signalent en tête (« en cas de contradiction avec le CLAUDE.md du projet, ce dernier prévaut ») et les conflits détectés pendant le pilote sont remontés pour arbitrage.

## Distribution sur les postes

Installation entièrement dans Claude Code, sans clone ni script :

1. /plugin marketplace add talbotgui/capitalisationIA puis /plugin install temoin@capitalisation-ia (commandes natives).
2. Après redémarrage, /temoin:canal stable|early (skill du plugin temoin, script plugins/temoin/skills/canal/configurer-canal.sh) :
   * vérifie les prérequis : claude (version minimale), git, jq ;
   * sauvegarde ~/.claude/settings.json ;
   * déclare ou met à jour le marketplace du canal choisi et active son autoUpdate ;
   * désactive les plugins de l'autre canal ;
   * installe ou réactive tous les plugins du canal choisi, en portée user (claude plugin …).
3. Redémarrage de Claude Code pour appliquer.

Bascule de canal : /temoin:canal avec l'autre canal. Un plugin ne peut pas déclarer le marketplace qui le contient : la première étape reste donc manuelle.

Le dépôt étant public, aucun jeton n'est nécessaire pour l'installation ni pour la mise à jour automatique.

## Sécurité de la chaîne de livraison

Toute fusion sur main exécute du code sur les postes early access, et toute publication sur les postes stables, sur une cinquantaine de projets.

* Application GitHub capitalisation-ia-publication : permission Contents en lecture et écriture uniquement, installée sur ce seul dépôt ; App ID et clé privée stockés dans l'environnement GitHub publication, restreint à la branche main.
* Ruleset de branche protection-main sur la branche par défaut : suppression et force push interdits, PR obligatoire avec revue des CODEOWNERS, statut du job de validation.yml obligatoire ; contournement autorisé pour l'application (toujours) et pour le rôle Repository admin (PR uniquement, pour permettre au mainteneur seul de fusionner ses propres PR).
* Le statut obligatoire de validation.yml ne peut être sélectionné dans protection-main qu'après une première exécution du workflow : il est ajouté au ruleset en fin de phase 0, une fois validation.yml fusionné et exécuté sur main.
* Ruleset de tags tags-publication sur le motif *--v* : création, modification et suppression interdites, contournement autorisé pour la seule application ; signature des tags à étudier.
* Aucune protection de branche classique sur main en parallèle des rulesets.
* Revue de sécurité de tout script de hook en PR (point de la checklist de revue).

La procédure détaillée de paramétrage est décrite dans le [paramétrage GitHub du dépôt](../produit/mainteneur/parametrageGithub.md).

## Documentation

Deux documentations distinctes, rédigées selon les conventions du dépôt et tenues à jour à chaque phase (une PR qui modifie un comportement visible met à jour la documentation concernée).

[Documentation mainteneur](../produit/mainteneur/index.md) (répertoire docs/produit/mainteneur/, une page d'accueil et une page par thème), à destination d'un mainteneur de ce dépôt :

* paramétrage GitHub (application de publication, environnement, rulesets, ajout du statut obligatoire de validation.yml) ;
* organisation du dépôt et conventions (rédaction, nommage des tags, CHANGELOG par plugin, absence de version dans les plugin.json) ;
* ajout d'un plugin, ajout ou modification des règles d'un projet, normalisation du remote ;
* exécution locale des tests et de shellcheck, lecture des résultats de la CI ;
* publication d'une version stable et retour arrière via le workflow publication ;
* renommage ou retrait d'un plugin ;
* checklist de revue de PR (sécurité des hooks, absence d'information confidentielle dans les règles projets).

[Documentation utilisateur](../produit/utilisateur.md), à destination d'un utilisateur du marketplace et de ses plugins :

* prérequis du poste (Git Bash, jq, version minimale de Claude Code) ;
* installation par /plugin et /temoin:canal, choix et bascule de canal stable ou early access, vérification avec /plugin, désinstallation ;
* description de chaque plugin : ce qu'il fait, quand ses hooks se déclenchent, ce qu'il écrit et où ;
* journal des prompts : emplacement, droits, rétention, avertissement sur les secrets collés dans un prompt ;
* coupe-circuit CAPIA_DESACTIVER ;
* demande d'ajout ou de modification des règles de son projet ;
* dépannage et remontée d'incident.

## Exploitation

* Retour arrière : voir [Versionnage et publication](#versionnage-et-publication).
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

Chaque phase est relue dans un contexte isolé et validée explicitement avant de passer à la suivante, sur la base de critères de sortie vérifiables. Chaque phase fait l'objet d'un fichier dédié ; ses rapports sont des fichiers séparés.

| Phase | Plan | Rapport |
|---|---|---|
| 0 : fondations | [01_planDeDemarrage_00_fondation.md](01_planDeDemarrage_00_fondation.md) | [01_rapportDeDemarrage_00_fondation.md](01_rapportDeDemarrage_00_fondation.md) |
| 1 : socle | [01_planDeDemarrage_01_socle.md](01_planDeDemarrage_01_socle.md) | à venir |
| 2 : règles projets | [01_planDeDemarrage_02_reglesProjets.md](01_planDeDemarrage_02_reglesProjets.md) | à venir |
| 3 : stack Java Spring | [01_planDeDemarrage_03_stackJavaSpring.md](01_planDeDemarrage_03_stackJavaSpring.md) | à venir |
| 4 : pilote | [01_planDeDemarrage_04_pilote.md](01_planDeDemarrage_04_pilote.md) | à venir |
| 5 : stacks Angular et Rust | [01_planDeDemarrage_05_stacksAngularRust.md](01_planDeDemarrage_05_stacksAngularRust.md) | à venir |
| 6 : généralisation | [01_planDeDemarrage_06_generalisation.md](01_planDeDemarrage_06_generalisation.md) | à venir |

## Points ouverts

* Accès en écriture de Claude au dépôt : installer l'application GitHub Claude sur talbotgui/capitalisationIA.
* Signature des tags de publication.
* Analyse RGPD du journal des prompts selon la nature des postes.
