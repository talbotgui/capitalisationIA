#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Hook SessionStart (startup, resume, clear, compact) du plugin regles-projets :
# identifie le projet par son remote origin normalisé, le cherche dans projets/mapping.json
# et injecte dans le contexte de Claude son index.md et la liste de ses fichiers de règles sans en-tête paths
# (ceux qui en ont un sont injectés à la demande par injecter-regles-fichier.sh).
# Aucun effet sur un projet inconnu ou sans remote. N'écrit aucun fichier. Sort toujours en code 0.

set -uo pipefail

racine_plugin="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=SCRIPTDIR/../lib/commun.sh
. "$racine_plugin/lib/commun.sh" || exit 0
# shellcheck source=SCRIPTDIR/projet.sh
. "$racine_plugin/scripts/projet.sh" || exit 0

capia_desactive regles-projets && exit 0
command -v jq >/dev/null 2>&1 || exit 0
capia_instance_active regles-projets || exit 0

evenement="$(cat)"
origine="$(printf '%s' "$evenement" | jq -r '.source // empty' 2>/dev/null)"
projet="${CLAUDE_PROJECT_DIR:-}"
[ -n "$projet" ] || projet="$(printf '%s' "$evenement" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$projet" ] || projet="$PWD"

dossier="$(regles_projet_dossier "$racine_plugin" "$projet")"
[ -n "$dossier" ] || exit 0
id="$(capia_normaliser_remote "$(git -C "$projet" config --get remote.origin.url)")"
regles="$racine_plugin/projets/$dossier"

liste=""
for fichier in "$regles"/*.md; do
  [ "$(basename "$fichier")" = "index.md" ] && continue
  [ -z "$(capia_motifs_regle "$fichier")" ] || continue
  liste="$liste* $fichier"$'\n'
done

contexte="Règles du projet $dossier, fournies par le plugin regles-projets du marketplace capitalisationIA (remote $id). En cas de contradiction avec le CLAUDE.md ou les règles versionnées du projet, ces derniers prévalent ; signaler alors la contradiction à l'utilisateur.

$(cat "$regles/index.md")"
if [ -n "$liste" ]; then
  contexte="$contexte

Fichiers de règles détaillées, à lire avec l'outil Read avant tout travail sur le thème concerné :
$liste"
fi

if [ "$origine" = "startup" ]; then
  message="capitalisationIA : règles du projet $dossier chargées."
else
  message=""
fi

jq -n --arg c "$contexte" --arg m "$message" '
  {hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $c}}
  + (if $m == "" then {} else {systemMessage: $m} end)'
exit 0
