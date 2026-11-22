# Journal des modifications du plugin temoin

Document généré avec l'assistance de l'IA (Claude).

## 0.3.0

* Le message de démarrage est aussi transmis à Claude : dans l'extension VS Code, qui ne l'affiche pas, demander « quel canal ? » donne la réponse.
* Skill /temoin:version : affiche à la demande le canal, la version et l'éventuelle alerte de double activation, dans toutes les interfaces.

## 0.2.0

* Skill /temoin:canal stable|early : configure le canal sur le poste (mise à jour automatique, installation des plugins du canal, désactivation de ceux de l'autre canal). Remplace le script outils/installer.sh.

## 0.1.0

* Première version : affichage du canal et de la version actifs au démarrage de session, alerte en cas d'activation simultanée dans les deux canaux.
