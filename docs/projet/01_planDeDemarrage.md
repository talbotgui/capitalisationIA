# Plan de mise en place du marketplace capitalisationIA

Document généré avec l'assistance de l'IA (Claude), à relire et valider avant toute mise en œuvre.

## Sommaire

* [Objectif](#objectif)
* [Décisions actées](#décisions-actées)
* [Architecture du dépôt](#architecture-du-dépôt)
* [Canaux stable et early access](#canaux-stable-et-early-access)
* [Identification d'un projet](#identification-dun-projet)
* [Versionnage et publication](#versionnage-et-publication)
* [Organisation des règles](#organisation-des-règles)
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
* Pas de garde-fous via des hooks PreToolUse : un hook PreToolUse ne bloque jamais un outil. Seule exception admise (décision du 26/11/2026) : l'injection non bloquante de contexte (règles par motif de fichier).
* Distribution par plugin (portée user) : commandes natives /plugin, puis skill /temoin:canal pour le choix du canal ; pas de managed settings à ce stade.
* Règles propres à chaque projet hors des dépôts de code : plugin unique regles-projets qui identifie le projet par son remote git ; les règles sont stockées dans ce dépôt (cadence de publication à surveiller).
* Règles organisées en trois niveaux chargés au plus juste pour limiter la consommation de tokens : commun (socle), langage ou stack (règles des plugins de stack injectées par motif de fichier), projet (index court et dérogations dans regles-projets). Voir [Organisation des règles](#organisation-des-règles).
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
│   └── stack-rust-tauri/
├── outils/
│   ├── publier.sh                             logique de publication appelée par le workflow
│   └── verifier-coherence.sh                  contrôles de cohérence des catalogues et plugins (CI)
├── .claude/rules/                             règles de Claude sur ce dépôt (collaboration, développement des plugins)
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
* chaque hook vérifie qu'il est l'instance du canal actif (si le plugin est activé dans les deux canaux, seule l'instance stable s'exécute, d'après CLAUDE_PLUGIN_ROOT et enabledPlugins des settings) et sort en code 0 sans rien faire sinon ;
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
* Version minimale de Claude Code requise documentée dans le README, vérifiée par la skill /temoin:canal et épinglée dans la CI (les fonctionnalités dependencies, git-subdir et additionalContext des hooks PreToolUse sont récentes).

Publication par le workflow .github/workflows/publication.yml, déclenchement manuel (workflow_dispatch) avec deux entrées : plugin et version. Étapes :

1. Contrôles : exécution sur main uniquement, plugin existant, version semver strictement supérieure au dernier tag du plugin, CHANGELOG.md du plugin contenant une section pour cette version, validation verte sur le commit courant.
2. Création et push du tag <plugin>--v<version> sur le commit courant de main.
3. Mise à jour de l'entrée du catalogue stable (ref et version), commit et push sur main.
4. Résumé dans le journal du workflow (tag, commit, entrée modifiée).

Le tag est poussé avant le commit du catalogue, de sorte que le catalogue ne pointe jamais vers un tag absent. Le workflow pousse avec le jeton de l'application GitHub capitalisation-ia-publication, seule identité autorisée à contourner les rulesets (voir [Sécurité de la chaîne de livraison](#sécurité-de-la-chaîne-de-livraison)). La logique est portée par outils/publier.sh pour rester testable hors CI.

Retour arrière : relancer le workflow en mode retour arrière (entrée supplémentaire) qui repointe l'entrée stable sur un tag antérieur existant, sans créer de tag. Propagation au prochain démarrage de Claude Code sur les postes (autoUpdate).

Renommage ou retrait d'un plugin : table renames des deux catalogues, displayName pour un simple changement de libellé.

## Organisation des règles

Le mécanisme paths des fichiers .claude/rules (chargement d'une règle selon le motif du fichier travaillé) n'est pas disponible pour un plugin : il suppose des fichiers dans le projet, exclus par l'objectif, ou dans ~/.claude/rules, communs à tous les projets du poste. Les skills de plugin ne le remplacent pas : le prototype de début de phase 3 a montré que leur champ paths n'a aucun effet mesurable et que leur activation reste à la discrétion du modèle (voir le [rapport de la phase 3](01_rapportDeDemarrage_03_stackJavaSpring.md#prototype-de-chargement-des-règles-de-langage)). Le marketplace reproduit donc ce mécanisme par un hook, et répartit les règles en trois niveaux, chacun chargé au moment utile :

| Niveau | Contenu | Porté par | Chargement |
|---|---|---|---|
| Commun | conventions de commits, rédaction, journal | socle | skills chargées à la demande |
| Langage ou stack | développement, conception, tests propres à un langage ou un framework | plugins de stack | fichiers regles/*.md à en-tête paths, injectés par hook à la première manipulation d'un fichier correspondant ; rien sur les autres stacks |
| Projet | écarts et spécificités du projet uniquement | regles-projets | index court injecté au démarrage et après compactage ; fichiers à en-tête paths injectés par motif comme les règles de stack |

* Une règle de langage n'est rédigée qu'une fois, dans le plugin de stack, et partagée par tous les projets de cette stack ; elle n'est jamais recopiée dans les règles d'un projet.
* L'index d'un projet indique sa stack, renvoie au plugin de stack et liste les seules dérogations (par exemple « stack Java Spring ; exception : JUnit 4 »). Cible : quelques lignes, quelques centaines de tokens au plus.
* Mécanisme d'injection (moteur capia_injecter_regles de la bibliothèque commune) : hook PreToolUse non bloquant sur Read, Edit, MultiEdit et Write ; chaque fichier de règle porte un en-tête paths (syntaxe des .claude/rules : chaîne à virgules ou liste, motifs **, *, ?, {a,b} relatifs à la racine du projet) ; une règle est injectée une seule fois par session (état sous ~/.claude/capitalisation-ia/sessions/, remis à zéro après /clear ou compactage par socle, purgé après 7 jours).
* Le contexte injecté accompagne le résultat de l'outil : sur une lecture, la règle arrive avant toute modification ; sur la création directe d'un fichier (Write sans lecture préalable), elle arrive après la première écriture.
* Chaque injection rappelle que le CLAUDE.md, les règles versionnées du projet et les règles de regles-projets prévalent.

## Plugins prévus

### temoin

* Plugin de diagnostic livré en phase 0 pour le prototype, conservé ensuite : hook SessionStart (startup) qui affiche à l'utilisateur le canal et la version chargés, et signale une activation simultanée dans les deux canaux, sans écrire de fichier.
* Message aussi transmis à Claude (additionalContext) et skill /temoin:version pour l'afficher à la demande, l'extension VS Code n'affichant pas le message de démarrage.
* Skill /temoin:canal stable|early, réservée à l'invocation par l'utilisateur : configuration du canal sur le poste (voir [Distribution sur les postes](#distribution-sur-les-postes)).

### socle

* Hook UserPromptSubmit journaliser-prompt.sh, adapté du modèle suiviProjets : même format (horodatage ISO 8601, prompt, séparateur ---), sortie toujours en code 0. Le journal est écrit hors du projet, dans ~/.claude/capitalisation-ia/journaux/<identifiant-projet>/prompts.log (identifiant issu de la normalisation du remote), ce qui évite toute écriture dans l'arbre de travail et toute modification de .git/info/exclude. La racine projet vient de CLAUDE_PROJECT_DIR. Les sous-agents ne déclenchent pas cet événement, comme dans le modèle.
* Journal : fichier en mode 600, dossier en mode 700 ; avertissement dans le README qu'il peut contenir des secrets collés dans un prompt ; rétention de 90 jours avec purge automatique des entrées plus anciennes au SessionStart.
* Bibliothèque commune de scripts : normalisation du remote, contrôle du canal actif, coupe-circuit, moteur d'injection des règles par motif de fichier. Chaque plugin qui l'utilise en embarque une copie identique, contrôlée par outils/verifier-coherence.sh.
* Hook SessionStart (clear, compact) : remise à zéro de l'état des règles injectées de la session.
* Skills : conventions de commits et mention d'origine IA, rédaction Markdown.
* Agent : explorateur-code générique en lecture seule (modèle de suiviProjets).

### regles-projets

* Hook SessionStart (matcher startup|resume|clear|compact) : normalise remote.origin.url, cherche le projet dans projets/mapping.json, injecte index.md et la liste des fichiers de règles sans en-tête paths ; aucun effet sur un projet inconnu.
* Hook PreToolUse non bloquant : fichiers de règles du projet à en-tête paths injectés par motif (voir [Organisation des règles](#organisation-des-règles)).
* index.md court : stack du projet, renvoi au plugin de stack, dérogations ; aucune règle de langage (voir [Organisation des règles](#organisation-des-règles)).
* Modèle de dossier projet : index.md, et fichiers thématiques (nommage.md, conception.md, securite.md, tests.md) réservés aux spécificités du projet.
* Le dépôt étant public, les règles des projets sont visibles de tous : aucune information confidentielle ne doit y figurer (contrôlé en revue de PR).

### Plugins de stack

* Dépendance au plugin socle, déclarée par nom seul (sans plage de versions).
* Règles de développement, conception et tests du langage, un fichier regles/<thème>.md par thème avec en-tête paths (ex. conception sur **/src/main/java/**/*.java, tests sur **/src/test/**/*.java, maven sur **/pom.xml ; **/*.ts, angular.json ; **/*.rs, Cargo.toml), injecté par le hook PreToolUse du plugin ; contenu court et actionnable. outils/verifier-coherence.sh contrôle la présence de l'en-tête.
* Hook PostToolUse de formatage et d'analyse sur le modèle de formater-et-analyser.sh de suiviProjets, qui sort immédiatement si l'extension du fichier ou le marqueur de stack ne correspond pas.
* Contraintes de performance du hook PostToolUse : timeout explicite déclaré dans hooks.json, traitement du seul fichier modifié, utilisation exclusive des outils déjà présents dans le projet ou sur le poste (aucune installation), sortie silencieuse si l'outil est absent.
* Sources des règles : règles de affaan-m/ecc (dossier rules/, licence MIT) adaptées en français et condensées, sans exemple de code pour limiter le contexte ; notice de licence NOTICE.md dans chaque plugin qui en reprend. Règles alignées sur les documentations officielles, qui prévalent sur ecc : Spring Boot (Apache 2.0) et JUnit (EPL 2.0), Angular (angular.dev, CC BY 4.0), Rust (Rust API Guidelines et The Rust Programming Language, MIT ou Apache 2.0) et Tauri 2 (tauri-docs, MIT), lues dans leurs dépôts sources faute d'accès aux sites depuis l'environnement de développement.
* Pas de serveur MCP dans les plugins de stack ; un MCP éventuel fera l'objet d'un plugin séparé.

### Règles communes à tous les hooks

* Aucun hook ne bloque un outil (sortie toujours en code 0, aucune décision de permission).
* Coupe-circuit : la variable d'environnement CAPIA_DESACTIVER=1 (ou CAPIA_DESACTIVER=<plugin>,<plugin>), hors temoin qui n'écrit rien, fait sortir les hooks concernés immédiatement en code 0, sans modification du dépôt projet.
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
| 1 : socle | [01_planDeDemarrage_01_socle.md](01_planDeDemarrage_01_socle.md) | [01_rapportDeDemarrage_01_socle.md](01_rapportDeDemarrage_01_socle.md) |
| 2 : règles projets | [01_planDeDemarrage_02_reglesProjets.md](01_planDeDemarrage_02_reglesProjets.md) | [01_rapportDeDemarrage_02_reglesProjets.md](01_rapportDeDemarrage_02_reglesProjets.md) |
| 3 : stack Java Spring | [01_planDeDemarrage_03_stackJavaSpring.md](01_planDeDemarrage_03_stackJavaSpring.md) | [01_rapportDeDemarrage_03_stackJavaSpring.md](01_rapportDeDemarrage_03_stackJavaSpring.md) |
| 4 : pilote | [01_planDeDemarrage_04_pilote.md](01_planDeDemarrage_04_pilote.md) | à venir |
| 5 : stacks Angular et Rust | [01_planDeDemarrage_05_stacksAngularRust.md](01_planDeDemarrage_05_stacksAngularRust.md) | à venir |
| 6 : généralisation | [01_planDeDemarrage_06_generalisation.md](01_planDeDemarrage_06_generalisation.md) | à venir |

## Points ouverts

* Accès en écriture de Claude au dépôt : installer l'application GitHub Claude sur talbotgui/capitalisationIA.
* Signature des tags de publication.
* Analyse RGPD du journal des prompts selon la nature des postes.
* Mesure pendant le pilote du volume de contexte injecté par session (index projet, règles injectées par motif).
* Skill redaction-markdown de socle : son champ paths est sans effet ; conversion éventuelle en règle injectée par motif à décider au vu du pilote.
* Analyse statique Java par fichier dans le hook PostToolUse : aucun outil rapide au fichier près ; l'analyse reste portée par la CI des projets.
