#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
# Hook SessionStart du plugin temoin : affiche le canal et la version chargés
# et signale une activation simultanée dans les deux canaux.
# Ne modifie rien et sort toujours en code 0.

set -u

racine="${CLAUDE_PLUGIN_ROOT:-}"
if [ -z "$racine" ] || ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Chemin d'installation attendu : .../plugins/cache/<marketplace>/<plugin>/<version>
version="$(basename "$racine")"
marketplace="$(basename "$(dirname "$(dirname "$racine")")")"

case "$marketplace" in
  capitalisation-ia) canal="stable" ;;
  capitalisation-ia-early) canal="early access" ;;
  *) canal="inconnu ($marketplace)" ;;
esac

message="capitalisationIA : canal $canal, version $version du plugin temoin."

settings="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
if [ -f "$settings" ]; then
  doublon="$(jq -r '
    (.enabledPlugins // {}) as $p
    | if ($p["temoin@capitalisation-ia"] == true) and ($p["temoin@capitalisation-ia-early"] == true)
      then "oui" else "non" end' "$settings" 2>/dev/null || echo "non")"
  if [ "$doublon" = "oui" ]; then
    message="$message ATTENTION : les canaux stable et early access sont activés simultanément, chaque hook s'exécute deux fois. Relancer outils/installer.sh avec le canal souhaité."
  fi
fi

jq -n --arg m "$message" '{systemMessage: $m}'
exit 0
