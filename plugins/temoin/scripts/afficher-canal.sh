#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
# Hook SessionStart du plugin temoin : affiche le canal et la version chargés
# et signale une activation simultanée dans les deux canaux.
# Sortie JSON : systemMessage (affiché par la ligne de commande) et additionalContext
# (transmis à Claude, utile dans les interfaces qui n'affichent pas systemMessage, comme VS Code).
# Option --texte (skill /temoin:version) : message en texte brut ; sans CLAUDE_PLUGIN_ROOT,
# la racine du plugin est déduite de l'emplacement du script.
# Ne modifie rien et sort toujours en code 0.

set -u

mode="json"
[ "${1:-}" = "--texte" ] && mode="texte"

racine="${CLAUDE_PLUGIN_ROOT:-}"
if [ -z "$racine" ] && [ "$mode" = "texte" ]; then
  racine="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
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
    message="$message ATTENTION : les canaux stable et early access sont activés simultanément, chaque hook s'exécute deux fois. Lancer /temoin:canal stable ou /temoin:canal early, puis redémarrer Claude Code."
  fi
fi

if [ "$mode" = "texte" ]; then
  printf '%s\n' "$message"
else
  jq -n --arg m "$message" '{
    systemMessage: $m,
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: ("Plugin temoin (diagnostic) : " + $m + " Si l'"'"'utilisateur demande le canal ou la version du marketplace capitalisationIA, répondre avec cette information.")
    }
  }'
fi
exit 0
