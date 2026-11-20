# Rapport de la phase 0 : fondations

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [État](#état)
* [Réalisé](#réalisé)
* [Résultats du prototype](#résultats-du-prototype)
* [Écarts par rapport au plan](#écarts-par-rapport-au-plan)
* [Tests](#tests)
* [Incidents](#incidents)
* [Critères de sortie](#critères-de-sortie)
* [Reste à faire](#reste-à-faire)

Rapport de la [phase 0](01_planDeDemarrage_00_fondation.md) du [plan de démarrage](01_planDeDemarrage.md).

## État

En cours (19/11/2026) : développements terminés sur la branche claude/blissful-hopper-s7x2c4, validation sur GitHub à dérouler par le mainteneur.

## Réalisé

* Paramétrage GitHub (application de publication, environnement publication, rulesets protection-main et tags-publication), réalisé par le mainteneur selon le [paramétrage GitHub du dépôt](../produit/mainteneur/parametrageGithub.md) ; branche par défaut renommée de master en main.
* Catalogues stable (vide jusqu'à la première publication) et early access.
* Plugin de diagnostic temoin.
* outils/publier.sh, outils/verifier-coherence.sh ; skill /temoin:canal (script configurer-canal.sh), qui remplace outils/installer.sh.
* Workflows validation.yml (PR et main, job validation) et publication.yml (déclenchement manuel, modes publication et retour-arriere).
* Tests bats, .gitattributes, CODEOWNERS, README.
* [Documentation mainteneur](../produit/mainteneur/index.md) et première version de la [documentation utilisateur](../produit/utilisateur.md).
* Règles de collaboration (.claude/rules/collaboration.md) et réorganisation de docs/ en produit et projet.

## Résultats du prototype

Prototype sur dépôt local, Claude Code 2.1.328, configuration isolée, puis vérifications sur le dépôt GitHub réel :

* git-subdir avec un tag en ref : confirmé, le canal stable livre le contenu du tag et affiche la version de l'entrée ;
* version calculée en l'absence de version : confirmé, le canal early access affiche une version dérivée du commit et livre le contenu de main ;
* installation depuis GitHub avec une source git-subdir : confirmée ;
* déclaration du catalogue early access par son URL brute (source url) : confirmée ;
* activation simultanée des deux canaux : possible, ce qui confirme le besoin d'exclusion mutuelle ;
* bascule de canal par le script de /temoin:canal : confirmée (test automatisé) ;
* déclaration du catalogue early access via le champ path d'une source git dans extraKnownMarketplaces : non prise en compte par la CLI ;
* dependencies : un nom seul est résolu dans le catalogue du plugin déclarant, donc dans le même canal ; une plage de versions exige une version dans plugin.json au commit du tag.

## Écarts par rapport au plan

Le [plan de démarrage](01_planDeDemarrage.md) a été amendé en conséquence :

* catalogue early access déclaré par source url au lieu de path ;
* dépendances déclarées par nom seul, sans plage de versions ;
* commande claude plugin tag non utilisée (elle exige une version dans plugin.json), tags créés par outils/publier.sh ;
* ajout du plugin temoin, conservé au-delà du prototype ;
* ajout de outils/verifier-coherence.sh ;
* installation par plugin au lieu d'un clone et d'un script : outils/installer.sh devient la skill /temoin:canal (temoin 0.2.0), après les commandes natives /plugin marketplace add et /plugin install.

## Tests

* 31 tests bats verts en local : publication et retour arrière (13), cohérence (7), hook temoin (5), configuration et bascule de canal de bout en bout avec la CLI claude (6).
* Chargement de la skill temoin:canal vérifié par claude plugin details ; exécution dans une session interactive non testable dans l'environnement de développement (à vérifier sur le poste du mainteneur).
* shellcheck sans alerte sur tous les scripts.
* claude plugin validate : catalogue early access valide en --strict, catalogue stable valide sans --strict (vide), plugin temoin valide.

## Incidents

* Première publication de temoin 0.1.0 en échec (« l'arbre de travail n'est pas propre ») : dans publication.yml, tee créait resultat.txt dans le dépôt avant le contrôle de publier.sh. Correction : fichier écrit dans $RUNNER_TEMP. Aucun tag n'avait été créé.
* Validation en échec sur main après la publication de temoin 0.1.0 (publication elle-même réussie : tag et entrée stable en place) : la fixture des tests copiait le catalogue stable réel, dont l'entrée pointe vers un tag absent de la fixture. Correction : catalogue stable vidé dans la fixture (tests/aide.bash).

## Critères de sortie

| Critère | État |
|---|---|
| Installation stable, early access puis retour en stable sur un poste vierge | validé en local, à vérifier sur le poste du mainteneur |
| Hypothèses des canaux confirmées ou plan amendé | atteint |
| Publication et retour arrière de temoin via le workflow | publication de 0.1.0 réussie, retour arrière à faire (voir [Incidents](#incidents)) |
| Statut validation obligatoire dans protection-main | fait par le mainteneur |
| Installation par plugin, sans clone ni script | développée (temoin 0.2.0), à vérifier sur le poste du mainteneur |
| Documentation mainteneur couvrant paramétrage GitHub et publication | atteint |

## Reste à faire

1. Ouvrir et fusionner la PR de la branche claude/blissful-hopper-s7x2c4 vers main, contrôle validation vert.
2. Rendre le statut validation obligatoire (étape 5 du [paramétrage GitHub](../produit/mainteneur/parametrageGithub.md#étape-5--statut-obligatoire-de-validationyml)).
3. Publier temoin 0.1.0 via le [workflow de publication](../produit/mainteneur/publication.md).
4. Publier temoin 0.2.0 (skill /temoin:canal).
5. Sur le poste du mainteneur (Git Bash) : installation selon la [documentation utilisateur](../produit/utilisateur.md#installation), puis /temoin:canal early et /temoin:canal stable, en vérifiant le message de temoin après chaque redémarrage.
6. Retour arrière en 0.1.0, vérification, puis retour en 0.2.0 (mode retour-arriere vers 0.2.0).
7. Compléter ce rapport et clore la phase.
