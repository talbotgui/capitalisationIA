#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Configuration du canal du marketplace capitalisationIA sur le poste (portée user).
# Appelé par la skill /temoin:canal ; utilisable directement pour les tests.
#
# Usage : configurer-canal.sh stable|early
#
# Le script :
#   1. vérifie les prérequis (claude en version minimale, git, jq) ;
#   2. sauvegarde ~/.claude/settings.json ;
#   3. déclare le marketplace du canal choisi (ou le met à jour) et active sa mise à jour automatique ;
#   4. désactive les plugins de l'autre canal (un plugin ne doit jamais être actif dans les deux canaux) ;
#   5. installe ou réactive tous les plugins du canal choisi.
# Les changements prennent effet à la session Claude Code suivante.
#
# Variables d'environnement (tests) :
#   CAPIA_SOURCE_STABLE  source du catalogue stable (défaut talbotgui/capitalisationIA)
#   CAPIA_SOURCE_EARLY   source du catalogue early access (défaut : URL brute du fichier sur main)
#   CLAUDE_CONFIG_DIR    dossier de configuration de Claude Code (défaut ~/.claude)

set -euo pipefail

VERSION_MIN_CLAUDE="2.1.328"
MARKETPLACE_STABLE="capitalisation-ia"
MARKETPLACE_EARLY="capitalisation-ia-early"
SOURCE_STABLE="${CAPIA_SOURCE_STABLE:-talbotgui/capitalisationIA}"
SOURCE_EARLY="${CAPIA_SOURCE_EARLY:-https://raw.githubusercontent.com/talbotgui/capitalisationIA/main/canaux/early-access/.claude-plugin/marketplace.json}"
DOSSIER_CONFIG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$DOSSIER_CONFIG/settings.json"

erreur() {
  echo "ERREUR : $*" >&2
  exit 1
}

etape() {
  echo "==> $*"
}

# Vrai si la version $1 (x.y.z) est supérieure ou égale à $2.
version_suffisante() {
  [ "$(printf '%s\n%s\n' "$1" "$2" | sort -t. -k1,1n -k2,2n -k3,3n | head -n 1)" = "$2" ]
}

# Applique « claude plugin $1 <id> --scope user » à chaque identifiant passé ensuite, en relançant les échecs
# tant qu'un passage fait progresser : l'ordre imposé par les dépendances entre plugins est ainsi respecté
# (un plugin requis par un autre ne se désactive qu'après lui, et ne se réactive qu'avant lui).
appliquer_dans_l_ordre() {
  local action="$1" restants progres id echecs
  shift
  restants=("$@")
  while [ "${#restants[@]}" -gt 0 ]; do
    progres=0
    echecs=()
    for id in "${restants[@]}"; do
      if claude plugin "$action" "$id" --scope user; then
        progres=1
      else
        echecs+=("$id")
      fi
    done
    [ "$progres" -eq 1 ] || erreur "impossible d'appliquer « $action » à : ${echecs[*]}."
    restants=("${echecs[@]}")
  done
}

marketplace_connu() {
  claude plugin marketplace list --json | jq -e --arg m "$1" 'any(.[]; .name == $m)' >/dev/null
}

canal="${1:-}"
case "$canal" in
  stable)
    marketplace="$MARKETPLACE_STABLE"; source="$SOURCE_STABLE"; autre="$MARKETPLACE_EARLY" ;;
  early)
    marketplace="$MARKETPLACE_EARLY"; source="$SOURCE_EARLY"; autre="$MARKETPLACE_STABLE" ;;
  *)
    echo "Usage : $0 stable|early" >&2
    exit 2 ;;
esac

# 1. Prérequis
etape "Vérification des prérequis"
for outil in claude git jq; do
  command -v "$outil" >/dev/null 2>&1 || erreur "$outil est introuvable dans le PATH."
done
version_claude="$(claude --version | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+' || true)"
[ -n "$version_claude" ] || erreur "impossible de déterminer la version de Claude Code."
version_suffisante "$version_claude" "$VERSION_MIN_CLAUDE" \
  || erreur "Claude Code $version_claude détecté, version $VERSION_MIN_CLAUDE minimum requise (claude update)."

# 2. Sauvegarde
mkdir -p "$DOSSIER_CONFIG"
if [ -f "$SETTINGS" ]; then
  jq empty "$SETTINGS" 2>/dev/null || erreur "$SETTINGS n'est pas un JSON valide : corriger le fichier avant de relancer."
  sauvegarde="$SETTINGS.capia-$(date +%Y%m%d-%H%M%S).bak"
  cp "$SETTINGS" "$sauvegarde"
  etape "Sauvegarde de settings.json dans $sauvegarde"
fi

# 3. Marketplace du canal choisi
if marketplace_connu "$marketplace"; then
  etape "Mise à jour du marketplace $marketplace"
  claude plugin marketplace update "$marketplace"
else
  etape "Ajout du marketplace $marketplace ($source)"
  claude plugin marketplace add "$source"
  marketplace_connu "$marketplace" || erreur "la source $source ne déclare pas le marketplace $marketplace."
fi

etape "Activation de la mise à jour automatique de $marketplace"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
tmp="$(mktemp)"
jq --arg m "$marketplace" '.extraKnownMarketplaces[$m].autoUpdate = true' "$SETTINGS" > "$tmp"
mv "$tmp" "$SETTINGS"

installes="$(claude plugin list --json)"

# 4. Désactivation de l'autre canal
a_desactiver=()
for id in $(jq -r --arg m "$autre" '.[] | select(.scope == "user" and .enabled and (.id | endswith("@" + $m))) | .id' <<<"$installes"); do
  etape "Désactivation de $id (autre canal)"
  a_desactiver+=("$id")
done
[ "${#a_desactiver[@]}" -eq 0 ] || appliquer_dans_l_ordre disable "${a_desactiver[@]}"

# 5. Plugins du canal choisi
disponibles="$(claude plugin list --available --json)"
plugins="$(jq -r --arg m "$marketplace" '
  [(.available // [])[] | select(.marketplaceName == $m) | .name]
  + [(.installed // [])[] | select(.id | endswith("@" + $m)) | .id | sub("@.*$"; "")]
  | unique | .[]' <<<"$disponibles")"
[ -n "$plugins" ] || echo "Aucun plugin publié dans le canal $canal pour le moment."

a_reactiver=()
a_installer=()
for nom in $plugins; do
  id="$nom@$marketplace"
  etat="$(jq -r --arg id "$id" '[.[] | select(.id == $id and .scope == "user")][0] | if . == null then "absent" elif .enabled then "actif" else "inactif" end' <<<"$installes")"
  case "$etat" in
    absent)
      a_installer+=("$id") ;;
    inactif)
      a_reactiver+=("$id") ;;
    actif)
      etape "$id déjà installé et actif" ;;
  esac
done
# Réactivations d'abord, pour qu'un plugin installé ensuite trouve ses dépendances actives.
for id in "${a_reactiver[@]}"; do
  etape "Réactivation de $id"
done
[ "${#a_reactiver[@]}" -eq 0 ] || appliquer_dans_l_ordre enable "${a_reactiver[@]}"
for id in "${a_installer[@]}"; do
  etape "Installation de $id"
  claude plugin install "$id" --scope user
done

echo
echo "Canal $canal configuré."
echo "Redémarrer Claude Code (nouvelle session) pour appliquer les changements ; le plugin temoin affichera alors le canal et la version chargés."
