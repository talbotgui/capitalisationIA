# Journal des modifications du plugin socle

Document généré avec l'assistance de l'IA (Claude).

## 1.1.0

* Bibliothèque commune : moteur d'injection des règles par motif de fichier, utilisé par les plugins de stack et regles-projets ; les commentaires HTML d'une ligne (mentions d'origine) ne sont pas transmis à Claude.
* Après un /clear ou un compactage, les règles déjà transmises dans la session le sont de nouveau au besoin.
* Purge au démarrage des états de session de plus de 7 jours.

## 1.0.0

* Journal local des prompts de la session principale, hors des projets : ~/.claude/capitalisation-ia/journaux/<projet>/prompts.log, accessible au seul utilisateur.
* Purge automatique au démarrage de session des entrées de plus de 90 jours.
* Coupe-circuit CAPIA_DESACTIVER et exécution d'une seule instance si le plugin est actif dans les deux canaux.
* Skills conventions-commits et redaction-markdown.
* Agent explorateur-code : exploration du code en lecture seule.
