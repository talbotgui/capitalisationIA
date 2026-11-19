# Documentation utilisateur

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [Objet](#objet)
* [Prérequis](#prérequis)
* [Installation](#installation)
* [Canaux stable et early access](#canaux-stable-et-early-access)
* [Vérification](#vérification)
* [Désinstallation](#désinstallation)
* [Plugins disponibles](#plugins-disponibles)
* [Dépannage](#dépannage)
* [Sections à compléter](#sections-à-compléter)

## Objet

Ce document s'adresse aux utilisateurs du marketplace capitalisationIA et de ses plugins. Il décrit l'installation sur un poste, le choix du canal et le rôle de chaque plugin.

## Prérequis

* Git Bash (seul environnement supporté).
* Claude Code en version 2.1.328 minimum (claude --version ; mise à jour par claude update).
* git et jq accessibles dans le PATH.

Le dépôt étant public, aucun jeton ni identifiant n'est nécessaire.

## Installation

1. Cloner le dépôt : git clone https://github.com/talbotgui/capitalisationIA.git
2. Lancer le script d'installation avec le canal souhaité : capitalisationIA/outils/installer.sh stable (ou early).

Le script sauvegarde ~/.claude/settings.json (fichier settings.json.capia-<date>.bak), déclare le marketplace du canal choisi avec mise à jour automatique, désactive les plugins de l'autre canal, puis installe ou réactive tous les plugins du canal choisi, en portée user. Le reste de settings.json est conservé.

Le script peut être relancé sans risque : il ne fait que compléter ce qui manque.

## Canaux stable et early access

* stable (marketplace capitalisation-ia) : versions explicitement publiées, recommandé pour un usage quotidien.
* early access (marketplace capitalisation-ia-early) : chaque modification fusionnée est livrée au démarrage suivant de Claude Code ; réservé aux pilotes.

Pour changer de canal, relancer le script avec l'autre canal. Un plugin ne doit jamais être actif dans les deux canaux à la fois : chaque hook s'exécuterait deux fois.

Les mises à jour sont appliquées automatiquement au démarrage de Claude Code.

## Vérification

Ouvrir une nouvelle session Claude Code : le plugin temoin affiche un message du type « capitalisationIA : canal stable, version 0.1.0 du plugin temoin ». La commande /plugin liste les plugins installés et leur état.

## Désinstallation

Pour chaque plugin : claude plugin uninstall <plugin>@<marketplace>, puis claude plugin marketplace remove <marketplace> pour chaque canal déclaré.

## Plugins disponibles

### temoin

Plugin de diagnostic. Au démarrage de session, il affiche le canal et la version chargés, et signale une activation simultanée dans les deux canaux. Il n'écrit aucun fichier.

## Dépannage

* Le script indique une version de Claude Code insuffisante : lancer claude update puis relancer le script.
* Le script refuse settings.json : le fichier n'est pas un JSON valide ; le corriger, ou restaurer une sauvegarde .bak, puis relancer.
* Le message de temoin signale les deux canaux actifs : relancer le script avec le canal souhaité.
* Un plugin n'apparaît pas après une publication : lancer claude plugin marketplace update <marketplace>, puis redémarrer Claude Code.

## Sections à compléter

Sections prévues par le plan, rédigées au fil des phases :

* plugins socle, regles-projets et plugins de stack (rôle, déclenchement des hooks, fichiers écrits) ;
* journal des prompts (emplacement, droits, rétention, avertissement sur les secrets) ;
* coupe-circuit CAPIA_DESACTIVER ;
* demande d'ajout ou de modification des règles de son projet ;
* remontée d'incident.
