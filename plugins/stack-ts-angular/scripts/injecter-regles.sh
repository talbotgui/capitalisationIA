#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Hook PreToolUse (Read, Edit, MultiEdit, Write) du plugin stack-ts-angular : injecte dans le contexte
# de Claude les règles de regles/ dont l'en-tête paths correspond au fichier manipulé, une fois par
# règle et par session. Ne bloque jamais l'outil. Sort toujours en code 0.

set -uo pipefail

racine_plugin="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=SCRIPTDIR/../lib/commun.sh
. "$racine_plugin/lib/commun.sh" || exit 0

capia_desactive stack-ts-angular && exit 0
command -v jq >/dev/null 2>&1 || exit 0
capia_instance_active stack-ts-angular || exit 0

capia_injecter_regles stack-ts-angular "$racine_plugin/regles" "ts-"
exit 0
