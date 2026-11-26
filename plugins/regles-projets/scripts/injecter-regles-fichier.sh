#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Hook PreToolUse (Read, Edit, MultiEdit, Write) du plugin regles-projets : injecte dans le contexte de Claude
# les fichiers de règles du projet dont l'en-tête paths correspond au fichier manipulé, une fois par règle
# et par session. Aucun effet sur un projet inconnu. Ne bloque jamais l'outil. Sort toujours en code 0.

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
projet="${CLAUDE_PROJECT_DIR:-}"
[ -n "$projet" ] || projet="$(printf '%s' "$evenement" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$projet" ] || exit 0
dossier="$(regles_projet_dossier "$racine_plugin" "$projet")"
[ -n "$dossier" ] || exit 0

printf '%s' "$evenement" | capia_injecter_regles regles-projets "$racine_plugin/projets/$dossier" "$dossier/"
exit 0
