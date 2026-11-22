# Plugin temoin

Document généré avec l'assistance de l'IA (Claude).

Plugin de diagnostic du marketplace capitalisationIA. Au démarrage de chaque session Claude Code, il affiche le canal (stable ou early access) et la version du plugin réellement chargés, ce qui permet de vérifier une installation ou une bascule de canal. Il signale aussi une activation simultanée dans les deux canaux, situation à proscrire car chaque hook s'exécuterait deux fois.

Le hook n'écrit aucun fichier : il lit uniquement le chemin d'installation du plugin et le fichier settings.json de l'utilisateur.

L'extension VS Code n'affiche pas ce message de démarrage. Il est donc aussi transmis à Claude, qui peut répondre à la question « quel canal ? ». La skill /temoin:version affiche le même message à la demande, dans toutes les interfaces.

La skill /temoin:canal stable|early configure le canal sur le poste : mise à jour automatique du marketplace, installation des plugins du canal, désactivation de ceux de l'autre canal, avec sauvegarde préalable de settings.json. Installation : /plugin marketplace add talbotgui/capitalisationIA puis /plugin install temoin@capitalisation-ia.
