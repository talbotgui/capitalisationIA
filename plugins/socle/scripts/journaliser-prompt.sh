#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Hook UserPromptSubmit du plugin socle, adapté de suiviProjets (.claude/hooks/journaliser-prompt.sh) :
# journalise l'horodatage et le contenu de chaque prompt soumis dans la session principale.
# Les sous-agents ne déclenchent pas cet événement : leurs échanges ne sont pas journalisés.
#
# Journal strictement local, hors du projet : <config>/capitalisation-ia/journaux/<identifiant-projet>/prompts.log
# (<config> = CLAUDE_CONFIG_DIR, défaut ~/.claude), fichier en mode 600, dossiers en mode 700.
# Aucune écriture dans l'arbre de travail du projet. Sort toujours en code 0.

set -uo pipefail

# shellcheck source=SCRIPTDIR/../lib/commun.sh
. "$(dirname "${BASH_SOURCE[0]}")/../lib/commun.sh" || exit 0

capia_desactive socle && exit 0
command -v jq >/dev/null 2>&1 || exit 0
capia_instance_active socle || exit 0

evenement="$(cat)"
prompt="$(printf '%s' "$evenement" | jq -r '.prompt // empty' 2>/dev/null)"
[ -n "$prompt" ] || exit 0

projet="${CLAUDE_PROJECT_DIR:-}"
[ -n "$projet" ] || projet="$(printf '%s' "$evenement" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$projet" ] || projet="$PWD"

umask 077
dossier="$(capia_dossier_donnees)/journaux/$(capia_identifiant_projet "$projet")"
mkdir -p "$dossier" 2>/dev/null || exit 0
chmod 700 "$dossier" 2>/dev/null
journal="$dossier/prompts.log"

{
  printf '[%s]\n' "$(date --iso-8601=seconds)"
  printf '%s\n' "$prompt"
  printf -- '---\n'
} >>"$journal" 2>/dev/null
chmod 600 "$journal" 2>/dev/null

exit 0
