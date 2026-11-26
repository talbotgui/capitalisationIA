# Organisation du dépôt et conventions

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [Organisation du dépôt](#organisation-du-dépôt)
* [Ajout d'un plugin](#ajout-dun-plugin)
* [Bibliothèque commune des hooks](#bibliothèque-commune-des-hooks)
* [Règles injectées par motif de fichier](#règles-injectées-par-motif-de-fichier)

Retour à l'[accueil de la documentation mainteneur](index.md).

## Organisation du dépôt

* Chaque plugin est un dossier plugins/<nom> contenant .claude-plugin/plugin.json, README.md et CHANGELOG.md.
* plugin.json ne contient jamais de champ version : la version du canal early access est calculée à partir du commit, celle du canal stable est portée par l'entrée du catalogue stable. outils/verifier-coherence.sh le contrôle.
* Conséquence : la commande claude plugin tag, qui exige une version dans plugin.json, n'est pas utilisée ; les tags sont créés par outils/publier.sh.
* Les dépendances entre plugins (champ dependencies) sont déclarées par nom seul, sans plage de versions : une plage exige une version dans plugin.json au commit du tag. Le nom est résolu dans le catalogue du plugin qui déclare la dépendance, donc dans le même canal.
* Toutes les entrées des catalogues sont des sources git-subdir vers https://github.com/talbotgui/capitalisationIA.git, chemin plugins/<nom> ; ref main dans le catalogue early access, ref <plugin>--v<version> et champ version dans le catalogue stable.
* Le catalogue stable n'est modifié que par le workflow de publication.
* Le catalogue early access est déclaré sur les postes par son URL brute (https://raw.githubusercontent.com/talbotgui/capitalisationIA/main/canaux/early-access/.claude-plugin/marketplace.json), la CLI ne permettant pas de déclarer un catalogue situé hors de .claude-plugin/ à la racine d'un dépôt.
* Scripts : Bash, fins de ligne LF (.gitattributes), bit exécutable positionné dans git, conformes à shellcheck.
* Fin de développement d'un sujet : contrôles décrits dans la règle [pluginClaudeCode.md](../../../.claude/rules/pluginClaudeCode.md), dont l'enrichissement du CHANGELOG de chaque plugin modifié, indispensable à la publication.
* Rédaction : français, mention d'origine IA en en-tête de fichier, un paragraphe par ligne, sommaire en tête des documents, aucun emoji.

## Ajout d'un plugin

1. Créer plugins/<nom>/.claude-plugin/plugin.json (name, description, author ; pas de version), README.md et CHANGELOG.md.
2. Ajouter l'entrée du plugin dans le catalogue early access (source git-subdir, ref main, sans version).
3. Ajouter les tests bats dans tests/.
4. Ouvrir une PR ; après fusion, le plugin est livré au canal early access.
5. Publier la première version stable avec le [workflow de publication](publication.md) : l'entrée du catalogue stable est créée automatiquement.

## Bibliothèque commune des hooks

plugins/socle/lib/commun.sh, à sourcer par les scripts de hooks. Un plugin qui en a besoin en embarque une copie identique dans son propre dossier lib/ (le chemin de socle n'est pas connu des autres plugins) ; outils/verifier-coherence.sh contrôle que chaque copie est identique à celle de socle. Toute modification se fait dans socle puis est recopiée, et enrichit le CHANGELOG de chaque plugin concerné (tests dans [tests/socle.bats](../../../tests/socle.bats)) :

* capia_normaliser_remote : identifiant hote/proprietaire/depot d'un remote git, en minuscules, sans suffixe .git ni barre finale. Formes acceptées : git@hote:proprietaire/depot.git, ssh://git@hote[:port]/proprietaire/depot.git, https://[identifiants@]hote[:port]/proprietaire/depot(.git). Les identifiants et le port sont supprimés ; toute autre forme (chemin local, plus de deux segments, segment . ou ..) donne un résultat vide.
* capia_identifiant_projet : remote origin normalisé, sinon sans-remote/<nom du dossier racine>.
* capia_desactive <plugin> : coupe-circuit CAPIA_DESACTIVER (1, all ou liste de plugins séparés par des virgules).
* capia_chemin_unix : chemin à séparateurs / (cygpath sous Git Bash), pour comparer les chemins Windows transmis par Claude Code.
* capia_injecter_regles <plugin> <dossier> [préfixe] : moteur des hooks PreToolUse d'injection de règles (voir [Règles injectées par motif de fichier](#règles-injectées-par-motif-de-fichier)).
* capia_instance_active <plugin> : faux pour l'instance early access d'un plugin également activé dans le canal stable (seule l'instance stable s'exécute) ; vrai hors installation par un marketplace du dépôt.

Chaque script de hook commence par le coupe-circuit puis le contrôle d'instance, et sort toujours en code 0. Les données locales du marketplace sont écrites sous ~/.claude/capitalisation-ia/ (CLAUDE_CONFIG_DIR si défini), jamais dans le projet.

## Règles injectées par motif de fichier

Les skills de plugin ne permettent pas de charger une règle selon le fichier manipulé (voir l'[organisation des règles](../../projet/01_planDeDemarrage.md#organisation-des-règles)) ; les plugins de stack et regles-projets utilisent donc un hook PreToolUse non bloquant (Read, Edit, MultiEdit, Write) qui appelle capia_injecter_regles.

* Un fichier de règle par thème, dans plugins/<stack>/regles/<thème>.md (ou plugins/regles-projets/projets/<projet>/<thème>.md), commençant par un en-tête paths :

```
---
paths:
  - "**/src/test/**/*.java"
  - "**/*Test.java"
---
* Règle actionnable.
```

* Forme courte acceptée : paths: "**/pom.xml, **/build.gradle". Motifs relatifs à la racine du projet : ** (dossiers quelconques, y compris aucun), * et ? (hors /), {a,b} (alternative).
* Seul le corps du fichier (sans l'en-tête) est injecté, une fois par règle et par session ; l'état est écrit sous ~/.claude/capitalisation-ia/sessions/<session>/, remis à zéro par socle après /clear ou compactage et purgé après 7 jours.
* Contenu court : chaque règle injectée consomme du contexte ; viser une dizaine de puces au plus par fichier.
* outils/verifier-coherence.sh refuse un fichier regles/*.md sans en-tête paths.
* Un hook ne bloque jamais un outil : sortie toujours en code 0, sans décision de permission.
