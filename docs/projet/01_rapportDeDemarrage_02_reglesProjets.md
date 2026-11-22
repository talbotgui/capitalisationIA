# Rapport de la phase 2 : règles projets

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [État](#état)
* [Réalisé](#réalisé)
* [Choix de conception](#choix-de-conception)
* [Tests](#tests)
* [Critères de sortie](#critères-de-sortie)
* [Reste à faire](#reste-à-faire)

Rapport de la [phase 2](01_planDeDemarrage_02_reglesProjets.md) du [plan de démarrage](01_planDeDemarrage.md).

## État

En cours (22/11/2026) : développements terminés sur la branche claude/keen-allen-agvylk, vérification sur le poste du mainteneur à dérouler.

## Réalisé

* Plugin regles-projets (CHANGELOG 0.1.0), référencé dans le catalogue early access :
  * hook SessionStart (startup, resume, clear, compact) injecter-regles.sh : index.md et liste des fichiers de règles transmis à Claude (additionalContext), message affiché au seul démarrage ;
  * copie de la bibliothèque commune de socle dans lib/ ;
  * projets/mapping.json et modèle de dossier projet projets/_modele ;
  * premier projet : suiviprojets, synthèse des règles versionnées de talbotgui/suiviProjets (index, nommage, conception, sécurité, tests).
* outils/verifier-coherence.sh : copies de la bibliothèque identiques à celle de socle, mapping (dossiers, index.md, remotes normalisés et uniques).
* Documentation : [règles des projets](../produit/mainteneur/reglesProjets.md) (mainteneur), plugin regles-projets et demande d'ajout de règles ([utilisateur](../produit/utilisateur.md#regles-projets)).

## Choix de conception

* Bibliothèque commune copiée dans chaque plugin, avec contrôle d'identité en CI (choix validé par le mainteneur le 22/11/2026).
* Seul index.md est injecté ; les fichiers thématiques sont listés par chemin absolu et lus par Claude à la demande, pour limiter la taille du contexte.
* Message « règles du projet chargées » affiché au seul démarrage, pour ne pas répéter l'affichage à chaque compactage.
* Amendement du plan (22/11/2026) : le filtrage par chemin des .claude/rules n'étant pas disponible pour un plugin, et pour limiter la consommation de tokens, les règles sont organisées en trois niveaux (commun, langage ou stack, projet), les règles de langage relevant de skills avec paths des plugins de stack (voir [Organisation des règles](01_planDeDemarrage.md#organisation-des-règles)). L'index de suiviprojets sera réduit en phase 5.
* suiviProjets possède déjà un CLAUDE.md et des règles versionnées : le contenu injecté en est un résumé et rappelle que la configuration du projet prévaut. Ce projet sert de test de bout en bout, pas de cas d'usage cible.

## Tests

* 57 tests bats verts en local, dont 8 pour regles-projets (projet connu, réinjection après compactage, fork, projet inconnu, sans remote, coupe-circuit et instance early, aucune écriture dans le projet, mapping réel) et 3 nouveaux contrôles de cohérence.
* Exécution du hook sur un clone de talbotgui/suiviProjets : règles reconnues et injectées.
* shellcheck sans alerte ; claude plugin validate vert sur les trois plugins et les deux catalogues.

## Critères de sortie

| Critère | État |
|---|---|
| Règles injectées sur un projet connu | atteint en tests, à vérifier sur le poste du mainteneur avec suiviProjets |
| Aucun effet sur un projet inconnu ou sans remote | atteint en tests |
| Réinjection après compact vérifiée | atteint en tests, à vérifier en session réelle (/compact) |

## Reste à faire

1. Fusionner la branche claude/keen-allen-agvylk sur main : regles-projets livré au canal early access.
2. Sur le poste du mainteneur : /temoin:canal early, redémarrage, ouverture de suiviProjets (message affiché, puis question à Claude sur les règles de nommage du projet), /compact et nouvelle question, puis ouverture d'un autre projet (aucun message).
3. Publier regles-projets 0.1.0, puis /temoin:canal stable.
4. Compléter ce rapport et clore la phase.
