---
name: canal
description: Configure le canal du marketplace capitalisationIA (stable ou early) sur le poste, active la mise à jour automatique, installe tous les plugins du canal et désactive ceux de l'autre canal.
argument-hint: stable|early
disable-model-invocation: true
allowed-tools: Bash(bash "${CLAUDE_SKILL_DIR}/configurer-canal.sh" *)
---

<!-- Fichier généré avec l'assistance de l'IA (Claude). -->

Configurer le canal du marketplace capitalisationIA demandé : « $ARGUMENTS ».

1. Si l'argument n'est pas exactement stable ou early, demander à l'utilisateur de choisir entre stable (versions publiées, recommandé) et early (chaque fusion sur main, réservé aux pilotes), sans rien exécuter d'autre.
2. Exécuter : bash "${CLAUDE_SKILL_DIR}/configurer-canal.sh" <canal>
3. Restituer en français et de façon concise ce que le script a fait (marketplace ajouté ou mis à jour, plugins installés, réactivés ou désactivés), ou l'erreur rencontrée et sa correction indiquée par le script.
4. Rappeler qu'il faut redémarrer Claude Code (nouvelle session) pour que les changements prennent effet.

Ne modifier aucun fichier de configuration par un autre moyen que ce script.
