# Plugin regles-projets

Document généré avec l'assistance de l'IA (Claude).

Règles propres à chaque projet, stockées dans ce dépôt plutôt que dans les dépôts de code.

* Au démarrage de session, après une reprise, un /clear ou un compactage, le hook lit le remote origin du projet, le normalise (hote/proprietaire/depot) et le cherche dans projets/mapping.json.
* Projet connu : son index.md et la liste de ses fichiers de règles sont transmis à Claude, avec la consigne que le CLAUDE.md du projet prévaut en cas de contradiction. Au démarrage, le message « capitalisationIA : règles du projet <projet> chargées. » s'affiche en ligne de commande.
* Fichiers de règles à en-tête paths : non listés au démarrage, transmis à Claude à la première lecture ou modification d'un fichier correspondant de la session.
* Projet inconnu ou sans remote : aucun effet.
* Le hook n'écrit aucun fichier. Coupe-circuit : CAPIA_DESACTIVER=regles-projets.

Le dépôt étant public, les règles sont visibles de tous : aucune information confidentielle. Ajout d'un projet : voir la documentation mainteneur.
