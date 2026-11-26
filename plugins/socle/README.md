# Plugin socle

Document généré avec l'assistance de l'IA (Claude).

Socle commun du marketplace capitalisationIA, prérequis des autres plugins.

* Journal des prompts : chaque prompt soumis dans la session principale est consigné avec son horodatage dans ~/.claude/capitalisation-ia/journaux/<projet>/prompts.log, où <projet> est le remote origin normalisé (hote/proprietaire/depot) ou sans-remote/<dossier>. Rien n'est écrit dans le projet. Fichier en mode 600, dossiers en mode 700 ; les échanges des sous-agents ne sont pas journalisés.
* Purge : au démarrage de session, les entrées de plus de 90 jours sont supprimées (variable CAPIA_RETENTION_JOURS pour une autre durée).
* Avertissement : le journal contient le texte intégral des prompts, y compris un secret qui y aurait été collé. Ne jamais coller de secret dans un prompt ; en cas d'erreur, supprimer l'entrée du journal.
* Coupe-circuit : CAPIA_DESACTIVER=1 désactive tous les hooks du marketplace, CAPIA_DESACTIVER=socle ceux de ce seul plugin.
* Skills : conventions-commits (messages de commit, mention d'origine IA), redaction-markdown (règles de rédaction des fichiers .md).
* Agent explorateur-code : exploration du code en lecture seule, restitution des constats avec références chemin:ligne.
* Bibliothèque lib/commun.sh : normalisation du remote, identifiant de projet, coupe-circuit, contrôle du canal actif, moteur d'injection des règles par motif de fichier (état par session sous ~/.claude/capitalisation-ia/sessions/, purgé après 7 jours).
* Après un /clear ou un compactage, l'état des règles transmises dans la session est remis à zéro, pour qu'elles soient de nouveau transmises au besoin.

Les conventions des skills s'effacent devant le CLAUDE.md et les règles du projet en cas de contradiction.
