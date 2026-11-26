#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Hook SessionStart (clear, compact) du plugin socle : après un /clear ou un compactage, le contexte
# des règles injectées par fichier est perdu ; l'état de la session est supprimé pour qu'elles soient
# injectées de nouveau à la prochaine manipulation d'un fichier concerné. Sort toujours en code 0.

set -uo pipefail

# shellcheck source=SCRIPTDIR/../lib/commun.sh
. "$(dirname "${BASH_SOURCE[0]}")/../lib/commun.sh" || exit 0

capia_desactive socle && exit 0
command -v jq >/dev/null 2>&1 || exit 0
capia_instance_active socle || exit 0

session="$(jq -r '.session_id // empty' 2>/dev/null)"
case "$session" in ""|*[!A-Za-z0-9_-]*) exit 0 ;; esac
rm -rf "$(capia_dossier_donnees)/sessions/$session" 2>/dev/null
exit 0
