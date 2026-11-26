# Journal des modifications du plugin regles-projets

Document généré avec l'assistance de l'IA (Claude).

## 0.1.0

* Injection au démarrage de session (et après reprise, /clear ou compactage) des règles du projet, identifié par son remote origin.
* Aucun effet sur un projet inconnu ou sans remote.
* Premier projet référencé : suiviProjets (test).
* Fichiers de règles du projet à en-tête paths transmis à Claude à la première lecture ou modification d'un fichier concerné, au lieu d'être listés au démarrage.
* Modèle de dossier projet : index court limité à la stack, aux dérogations et aux spécificités du projet.
