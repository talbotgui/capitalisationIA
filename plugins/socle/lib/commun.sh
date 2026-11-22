#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Bibliothèque commune des hooks du marketplace capitalisationIA, à sourcer (pas d'exécution directe).
# Fonctions sans effet de bord sur le poste ni sur le dépôt du projet.
#
#   capia_normaliser_remote URL    identifiant hote/proprietaire/depot d'un remote git (vide si non reconnu)
#   capia_identifiant_projet DIR   identifiant du projet de DIR : remote origin normalisé, sinon sans-remote/<dossier>
#   capia_desactive PLUGIN         vrai si le coupe-circuit CAPIA_DESACTIVER concerne PLUGIN
#   capia_instance_active PLUGIN   vrai si cette instance du plugin (CLAUDE_PLUGIN_ROOT) doit s'exécuter
#   capia_dossier_donnees          dossier des données locales du marketplace

CAPIA_MARKETPLACE_STABLE="capitalisation-ia"
CAPIA_MARKETPLACE_EARLY="capitalisation-ia-early"

capia_dossier_config() {
  printf '%s\n' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
}

capia_dossier_donnees() {
  printf '%s/capitalisation-ia\n' "$(capia_dossier_config)"
}

# Formes acceptées : git@hote:proprietaire/depot.git, ssh://[user@]hote[:port]/proprietaire/depot.git,
# http(s)://[identifiants@]hote[:port]/proprietaire/depot(.git)(/).
# Les identifiants éventuels (jeton dans une URL https) et le port sont supprimés ; résultat en minuscules.
capia_normaliser_remote() {
  local url="$1" hote chemin
  url="${url%"${url##*[![:space:]]}"}"
  case "$url" in
    ssh://*|http://*|https://*|git://*)
      url="${url#*://}"
      hote="${url%%/*}"
      chemin="${url#*/}"
      [ "$chemin" != "$url" ] || return 0
      hote="${hote##*@}"
      hote="${hote%%:*}" ;;
    *@*:*)
      url="${url#*@}"
      hote="${url%%:*}"
      chemin="${url#*:}" ;;
    *)
      return 0 ;;
  esac
  chemin="${chemin%/}"
  chemin="${chemin%.git}"
  chemin="${chemin#/}"
  # Exactement deux segments non vides, sans segment « . » ou « .. ».
  case "$chemin" in
    */*/*|/*|*/|"") return 0 ;;
    */*) ;;
    *) return 0 ;;
  esac
  local proprietaire="${chemin%%/*}" depot="${chemin#*/}" s
  for s in "$hote" "$proprietaire" "$depot"; do
    case "$s" in ""|.|..) return 0 ;; esac
  done
  printf '%s/%s/%s\n' "$hote" "$proprietaire" "$depot" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9._/~\n-' '_'
}

capia_identifiant_projet() {
  local dossier="$1" url id nom
  url="$(git -C "$dossier" config --get remote.origin.url 2>/dev/null || true)"
  id=""
  [ -z "$url" ] || id="$(capia_normaliser_remote "$url")"
  if [ -z "$id" ]; then
    nom="$(basename "$(git -C "$dossier" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$dossier")")"
    nom="$(printf '%s' "$nom" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9._~-' '_')"
    case "$nom" in ""|.|..) nom="inconnu" ;; esac
    id="sans-remote/$nom"
  fi
  printf '%s\n' "$id"
}

# CAPIA_DESACTIVER=1 (ou all) désactive tous les hooks ; CAPIA_DESACTIVER=socle,stack-rust désactive ceux des plugins cités.
capia_desactive() {
  local plugin="$1" valeur="${CAPIA_DESACTIVER:-}" element
  [ -n "$valeur" ] || return 1
  case "$valeur" in 1|all|tous) return 0 ;; esac
  local IFS=','
  for element in $valeur; do
    element="${element//[[:space:]]/}"
    [ "$element" = "$plugin" ] && return 0
  done
  return 1
}

# Chemin d'installation attendu : .../plugins/cache/<marketplace>/<plugin>/<version>.
# Si le plugin est activé dans les deux canaux, seule l'instance stable s'exécute.
# Hors installation par un marketplace du dépôt (développement local), l'instance est active.
capia_instance_active() {
  local plugin="$1" racine="${CLAUDE_PLUGIN_ROOT:-}" marketplace settings
  [ -n "$racine" ] || return 0
  marketplace="$(basename "$(dirname "$(dirname "$racine")")")"
  [ "$marketplace" = "$CAPIA_MARKETPLACE_EARLY" ] || return 0
  settings="$(capia_dossier_config)/settings.json"
  [ -f "$settings" ] || return 0
  if jq -e --arg id "$plugin@$CAPIA_MARKETPLACE_STABLE" '(.enabledPlugins // {})[$id] == true' "$settings" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}
