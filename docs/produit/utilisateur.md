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
* [Journal des prompts](#journal-des-prompts)
* [Coupe-circuit](#coupe-circuit)
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

Tout se fait dans une session Claude Code, sans clone ni script :

1. /plugin marketplace add talbotgui/capitalisationIA
2. /plugin install temoin@capitalisation-ia
3. Redémarrer Claude Code.
4. /temoin:canal stable (ou /temoin:canal early pour le canal early access).
5. Redémarrer Claude Code.

La skill /temoin:canal sauvegarde ~/.claude/settings.json (fichier settings.json.capia-<date>.bak), déclare le marketplace du canal choisi avec mise à jour automatique, désactive les plugins de l'autre canal, puis installe ou réactive tous les plugins du canal choisi, en portée user. Le reste de settings.json est conservé.

La skill peut être relancée sans risque : elle ne fait que compléter ce qui manque.

## Canaux stable et early access

* stable (marketplace capitalisation-ia) : versions explicitement publiées, recommandé pour un usage quotidien.
* early access (marketplace capitalisation-ia-early) : chaque modification fusionnée est livrée au démarrage suivant de Claude Code ; réservé aux pilotes.

Pour changer de canal : /temoin:canal avec l'autre canal, puis redémarrer Claude Code. Un plugin ne doit jamais être actif dans les deux canaux à la fois : chaque hook s'exécuterait deux fois.

Les mises à jour sont appliquées automatiquement au démarrage de Claude Code.

## Vérification

Ouvrir une nouvelle session Claude Code : le plugin temoin affiche un message du type « capitalisationIA : canal stable, version 0.1.0 du plugin temoin ». Dans l'extension VS Code, ce message n'est pas affiché au démarrage : lancer /temoin:version, ou demander à Claude « quel canal ? ». La commande /plugin liste les plugins installés et leur état.

## Désinstallation

Pour chaque plugin : claude plugin uninstall <plugin>@<marketplace>, puis claude plugin marketplace remove <marketplace> pour chaque canal déclaré.

## Plugins disponibles

### temoin

Plugin de diagnostic et de configuration. Au démarrage de session, il affiche le canal et la version chargés, et signale une activation simultanée dans les deux canaux. Ce message est aussi transmis à Claude, et la skill /temoin:version l'affiche à la demande, notamment dans l'extension VS Code. Sa skill /temoin:canal stable|early configure le canal (voir [Installation](#installation)). Seule cette skill modifie la configuration utilisateur ; le hook n'écrit aucun fichier.

### socle

Socle commun, installé avec les autres plugins du canal par /temoin:canal.

* Hook au dépôt de chaque prompt (UserPromptSubmit) : consigne le prompt dans le journal local (voir [Journal des prompts](#journal-des-prompts)).
* Hook au démarrage de session : purge des entrées du journal de plus de 90 jours.
* Skills conventions-commits et redaction-markdown, utilisées par Claude lors d'un commit ou de la rédaction d'un fichier .md ; les règles du projet (CLAUDE.md) prévalent en cas de contradiction.
* Agent explorateur-code : exploration du code en lecture seule, à demander explicitement (« utilise l'agent explorateur-code pour… ») ou choisi par Claude.

Le plugin n'écrit rien dans les projets : son seul fichier est le journal des prompts.

## Journal des prompts

* Emplacement : ~/.claude/capitalisation-ia/journaux/<projet>/prompts.log, où <projet> est le remote origin du dépôt sous la forme hote/proprietaire/depot (par exemple github.com/talbotgui/capitalisationia), ou sans-remote/<dossier> à défaut de remote.
* Contenu : pour chaque prompt de la session principale, l'horodatage, le texte intégral du prompt et une ligne ---. Les échanges internes des sous-agents ne sont pas journalisés.
* Droits : fichier lisible par le seul utilisateur (mode 600), dossiers en mode 700. Aucune transmission distante.
* Rétention : 90 jours, purge automatique au démarrage de session ; la variable d'environnement CAPIA_RETENTION_JOURS permet une autre durée.
* Avertissement : un secret collé dans un prompt (mot de passe, jeton, clé) est conservé dans le journal. Ne jamais coller de secret dans un prompt ; en cas d'erreur, supprimer l'entrée concernée du fichier.

## Coupe-circuit

En cas de dysfonctionnement d'un hook, la variable d'environnement CAPIA_DESACTIVER, positionnée avant de lancer Claude Code, désactive les hooks sans désinstaller les plugins ni modifier le projet :

* CAPIA_DESACTIVER=1 : tous les hooks du marketplace (hors temoin, qui n'écrit rien) ;
* CAPIA_DESACTIVER=socle (ou une liste séparée par des virgules, par exemple socle,stack-rust) : les hooks des plugins cités.

Exemple dans Git Bash : CAPIA_DESACTIVER=socle claude. Signaler ensuite l'incident au mainteneur.

## Dépannage

* /temoin:canal indique une version de Claude Code insuffisante : lancer claude update puis relancer la skill.
* /temoin:canal refuse settings.json : le fichier n'est pas un JSON valide ; le corriger, ou restaurer une sauvegarde .bak, puis relancer.
* Le message de temoin signale les deux canaux actifs : lancer /temoin:canal avec le canal souhaité, puis redémarrer.
* /temoin:canal est introuvable : la version installée de temoin est antérieure à 0.2.0 ; lancer /plugin marketplace update capitalisation-ia, puis redémarrer.
* Un plugin n'apparaît pas après une publication : lancer claude plugin marketplace update <marketplace>, puis redémarrer Claude Code.

## Sections à compléter

Sections prévues par le plan, rédigées au fil des phases :

* plugins regles-projets et plugins de stack (rôle, déclenchement des hooks, fichiers écrits) ;
* demande d'ajout ou de modification des règles de son projet ;
* remontée d'incident.
