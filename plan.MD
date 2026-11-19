# Plan de mise en place du marketplace capitalisationIA

Document généré avec l'assistance de l'IA (Claude), à relire et valider avant toute mise en œuvre.
Sommaire

* Objectif
* Décisions actées
* Architecture du dépôt
* Canaux stable et early access
* Versionnage et publication
* Plugins prévus
* Distribution sur les postes
* Intégration continue
* Phases
* Points ouverts

Objectif
Industrialiser la configuration de Claude Code sur une cinquantaine de projets hétérogènes, sans aucune trace de configuration Claude Code dans les dépôts de code des projets.
Décisions actées

* Dépôt unique talbotgui/capitalisationIA contenant tous les plugins et deux catalogues.
* Deux marketplaces dès le départ : capitalisation-ia (stable) et capitalisation-ia-early (early access).
* Stacks pilotes : Stack1 Java + Spring Boot, Stack2 TypeScript + Angular, Stack3 Rust.
* Traçabilité : hook UserPromptSubmit sur le modèle de talbotgui/suiviProjets/.claude/hooks/journaliser-prompt.sh (pas de hook SessionEnd pour ce besoin).
* Distribution par script utilisateur (portée user), pas de managed settings à ce stade.
* Règles propres à chaque projet hors des dépôts de code : plugin unique regles-projets qui identifie le projet par son remote git.
* Conventions de rédaction reprises de suiviProjets : français, mention d'origine IA en en-tête de fichier, un paragraphe par ligne, sommaire en tête des documents, aucun emoji.

Architecture du dépôt
capitalisationIA/
├── .claude-plugin/marketplace.json            catalogue stable « capitalisation-ia »
├── canaux/early-access/.claude-plugin/marketplace.json   catalogue « capitalisation-ia-early »
├── plugins/
│   ├── socle/                                 garde-fous, journal des prompts, conventions git
│   ├── regles-projets/                        règles par projet chargées au SessionStart
│   ├── stack-java-spring/
│   ├── stack-ts-angular/
│   └── stack-rust/
├── outils/
│   ├── installer.sh                           script d'installation poste développeur
│   └── publier.sh                             publication d'une version stable d'un plugin
├── tests/                                     fixtures et tests des scripts de hooks
├── .github/workflows/validation.yml
├── CODEOWNERS
├── CHANGELOG.md
└── README.md

Canaux stable et early access
Les deux catalogues référencent les mêmes dossiers plugins/<nom> via des sources git-subdir pointant sur ce dépôt ; seule la référence git diffère.

* Early access : "ref": "main", aucun champ version dans l'entrée. La version calculée est alors le SHA du commit : chaque fusion sur main est livrée aux utilisateurs early access.
* Stable : "ref": "<plugin>--v<version>" (tag git) et "version": "<version>" dans l'entrée. Les utilisateurs stables ne reçoivent que les versions explicitement publiées.

Conséquence : le champ version est absent des plugin.json (sinon il primerait sur l'entrée et figerait le canal early access). claude plugin validate émet alors un avertissement sur chaque plugin ; --strict est donc réservé à la validation des catalogues.
Le catalogue stable étant à l'emplacement par défaut, /plugin marketplace add talbotgui/capitalisationIA donne le canal stable. Le catalogue early access, hors emplacement par défaut, est déclaré par le script d'installation via extraKnownMarketplaces avec le champ path.
Versionnage et publication

* Semver par plugin, tags <plugin>--v<version> (convention utilisée aussi pour résoudre les plages de versions des dependencies).
* outils/publier.sh <plugin> <version> : vérifie un arbre propre sur main, crée le tag, met à jour l'entrée du catalogue stable (ref et version), complète CHANGELOG.md, committe. Le git push (commit et tag) reste une action humaine.
* Renommage ou retrait d'un plugin : table renames des deux catalogues, displayName pour un simple changement de libellé.

Plugins prévus
socle

* Hook UserPromptSubmit journaliser-prompt.sh, adapté du modèle suiviProjets : même format (horodatage ISO 8601, prompt, séparateur ---), journal dans <projet>/.claude/logs/prompts.log, sortie toujours en code 0. Adaptation nécessaire : le projet n'ayant pas de .gitignore adapté, le script ajoute .claude/logs/ à .git/info/exclude (exclusion locale jamais versionnée) ; la racine projet vient de CLAUDE_PROJECT_DIR et non du chemin du script. Les sous-agents ne déclenchent pas cet événement, comme dans le modèle.
* Hook PreToolUse de garde-fous : lecture de .pem, .key, .env, commandes rm -rf, curl, wget, nc, ssh, git push (complète l'absence de garde-fou technique sur git push constatée dans suiviProjets).
* Skills : conventions de commits et mention d'origine IA, rédaction Markdown.
* Agent : explorateur-code générique en lecture seule (modèle de suiviProjets).

regles-projets

* Hook SessionStart (matcher startup|resume|clear|compact) : lit remote.origin.url, cherche le projet dans projets/mapping.json, injecte index.md et la liste des fichiers de règles ; aucun effet sur un projet inconnu.
* Modèle de dossier projet : index.md, nommage.md, conception.md, securite.md, tests.md.

Plugins de stack (défensifs)

* Dépendance au plugin socle.
* Skills avec paths (ex. **/*.java, pom.xml, build.gradle* ; **/*.ts, angular.json ; **/*.rs, Cargo.toml).
* Hook PostToolUse de formatage et d'analyse sur le modèle de formater-et-analyser.sh de suiviProjets, qui sort immédiatement si l'extension du fichier ou le marqueur de stack ne correspond pas.
* Pas de serveur MCP dans les plugins de stack ; un MCP éventuel fera l'objet d'un plugin séparé.

Distribution sur les postes
outils/installer.sh [stable|early] :

1. Vérifie les prérequis : claude, git, jq, accès git non interactif au dépôt (clé SSH chargée ou credential helper renseigné).
2. Fusionne avec jq dans ~/.claude/settings.json les entrées extraKnownMarketplaces (avec autoUpdate: true) et enabledPlugins du canal choisi, sans écraser le reste du fichier (sauvegarde préalable).
3. Lance claude plugin install <plugin>@<marketplace> --scope user pour chaque plugin.
4. Affiche la vérification à faire (/plugin dans une session).

Bascule de canal : relancer le script avec l'autre canal, qui désactive les plugins de l'ancien.
Intégration continue
GitHub Actions sur chaque PR et sur main :

* claude plugin validate --strict sur les deux catalogues, claude plugin validate sur chaque plugin.
* shellcheck sur tous les scripts.
* Tests des hooks : injection de JSON d'événement sur des projets fixtures (Java, Angular, Rust, inconnu) et vérification des sorties et fichiers produits.
* Contrôle de cohérence : chaque entrée stable pointe vers un tag existant.

Phases

1. Phase 0 : fondations (arborescence, catalogues, README, CI, CODEOWNERS, CHANGELOG, publier.sh, installer.sh).
2. Phase 1 : plugin socle, publication socle--v1.0.0.
3. Phase 2 : plugin regles-projets et modèle de dossier projet.
4. Phase 3 : stack-java-spring, puis stack-ts-angular, puis stack-rust.
5. Phase 4 : pilote sur 3 à 5 projets en early access, retours, promotion en stable.

Chaque phase est relue dans un contexte isolé et validée explicitement avant de passer à la suivante.
Points ouverts

* Accès en écriture de Claude au dépôt : installer l'application GitHub Claude sur talbotgui/capitalisationIA.
* Confidentialité des règles projets : le dépôt est-il privé ? Toutes les règles y sont visibles par tous les utilisateurs du marketplace.
* Rétention et purge du journal des prompts.
* Systèmes d'exploitation des postes : scripts Bash supposés ; Windows natif sans Git Bash à confirmer.
