# Organisation du dépôt et conventions

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [Organisation du dépôt](#organisation-du-dépôt)
* [Ajout d'un plugin](#ajout-dun-plugin)

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
* Rédaction : français, mention d'origine IA en en-tête de fichier, un paragraphe par ligne, sommaire en tête des documents, aucun emoji.

## Ajout d'un plugin

1. Créer plugins/<nom>/.claude-plugin/plugin.json (name, description, author ; pas de version), README.md et CHANGELOG.md.
2. Ajouter l'entrée du plugin dans le catalogue early access (source git-subdir, ref main, sans version).
3. Ajouter les tests bats dans tests/.
4. Ouvrir une PR ; après fusion, le plugin est livré au canal early access.
5. Publier la première version stable avec le [workflow de publication](publication.md) : l'entrée du catalogue stable est créée automatiquement.
