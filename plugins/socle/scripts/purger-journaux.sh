#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Hook SessionStart (startup) du plugin socle : supprime des journaux de prompts les entrées
# de plus de CAPIA_RETENTION_JOURS jours (90 par défaut), pour tous les projets, et les états de session
# des règles injectées par fichier datant de plus de 7 jours.
# Une entrée commence par une ligne [horodatage ISO 8601] et se termine par une ligne ---.
# Un journal devenu vide est supprimé. Sort toujours en code 0, sans rien afficher.

set -uo pipefail

# shellcheck source=SCRIPTDIR/../lib/commun.sh
. "$(dirname "${BASH_SOURCE[0]}")/../lib/commun.sh" || exit 0

capia_desactive socle && exit 0
command -v jq >/dev/null 2>&1 || exit 0
capia_instance_active socle || exit 0

retention="${CAPIA_RETENTION_JOURS:-90}"
case "$retention" in ''|*[!0-9]*) retention=90 ;; esac
limite="$(date -d "-$retention days" +%F 2>/dev/null)" || exit 0
sessions="$(capia_dossier_donnees)/sessions"
[ -d "$sessions" ] && find "$sessions" -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} + 2>/dev/null

racine="$(capia_dossier_donnees)/journaux"
[ -d "$racine" ] || exit 0

umask 077
while IFS= read -r -d '' journal; do
  tmp="$journal.purge.$$"
  awk -v limite="$limite" '
    BEGIN { attendre = 1; garder = 1 }
    attendre && /^\[[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[^]]*\]$/ {
      garder = (substr($0, 2, 10) >= limite)
    }
    { attendre = ($0 == "---"); if (garder) print }
  ' "$journal" >"$tmp" 2>/dev/null || { rm -f "$tmp"; continue; }
  if [ -s "$tmp" ]; then
    chmod 600 "$tmp" 2>/dev/null
    mv -f "$tmp" "$journal" 2>/dev/null || rm -f "$tmp"
  else
    rm -f "$tmp" "$journal"
  fi
done < <(find "$racine" -type f -name prompts.log -print0 2>/dev/null)

exit 0
