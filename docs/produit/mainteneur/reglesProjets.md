# Règles des projets

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [Principe](#principe)
* [Ajout d'un projet](#ajout-dun-projet)
* [Modification des règles d'un projet](#modification-des-règles-dun-projet)
* [Rédaction des règles](#rédaction-des-règles)

Retour à l'[accueil de la documentation mainteneur](index.md).

## Principe

Le plugin regles-projets identifie le projet ouvert par son remote origin normalisé (voir la [bibliothèque commune](conventions.md#bibliothèque-commune-des-hooks)), le cherche dans plugins/regles-projets/projets/mapping.json et injecte dans le contexte de Claude le fichier index.md du dossier projet, ainsi que la liste de ses autres fichiers de règles, que Claude lit à la demande. L'injection a lieu au démarrage, après une reprise, un /clear et un compactage.

Le dépôt étant public, les règles sont visibles de tous : aucune information confidentielle (hôte interne, nom de client, identifiant, donnée personnelle). Ce point est contrôlé en revue de PR.

## Ajout d'un projet

1. Copier plugins/regles-projets/projets/_modele sous plugins/regles-projets/projets/<projet> (minuscules, chiffres, point, tiret, souligné ; pas de _ initial).
2. Rédiger index.md et les fichiers thématiques utiles (nommage.md, conception.md, securite.md, tests.md) ; supprimer les fichiers sans contenu.
3. Ajouter l'entrée dans mapping.json : {"dossier": "<projet>", "remotes": ["hote/proprietaire/depot"]}, remotes sous forme normalisée en minuscules ; un fork s'ajoute comme remote supplémentaire du même projet.
4. Lancer outils/verifier-coherence.sh, qui contrôle les dossiers, les index.md, la forme et l'unicité des remotes.
5. Enrichir le CHANGELOG de regles-projets, puis ouvrir une PR. Après fusion, les règles sont livrées au canal early access ; elles parviennent au canal stable à la publication suivante de regles-projets.

## Modification des règles d'un projet

Même circuit que l'ajout, à partir de l'étape 2. Chaque modification de règles est une modification du plugin : sa diffusion en stable passe par une publication, cadence à surveiller pendant le pilote.

## Rédaction des règles

* index.md : court (il est injecté intégralement à chaque session), une liste de points essentiels ; les détails vont dans les fichiers thématiques.
* Règles actionnables, une par puce, sans renvoi à des documents absents du dépôt du projet.
* Si le projet possède déjà un CLAUDE.md ou des règles versionnées, l'index le rappelle : la configuration du projet prévaut, les règles de capitalisationIA n'en sont qu'un complément ou un résumé.
