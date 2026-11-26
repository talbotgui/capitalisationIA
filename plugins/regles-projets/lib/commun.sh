#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Bibliothèque commune des hooks du marketplace capitalisationIA, à sourcer (pas d'exécution directe).
# Aucune écriture dans le dépôt du projet ; seul capia_injecter_regles écrit un état de session sous capia_dossier_donnees.
#
#   capia_normaliser_remote URL    identifiant hote/proprietaire/depot d'un remote git (vide si non reconnu)
#   capia_identifiant_projet DIR   identifiant du projet de DIR : remote origin normalisé, sinon sans-remote/<dossier>
#   capia_desactive PLUGIN         vrai si le coupe-circuit CAPIA_DESACTIVER concerne PLUGIN
#   capia_instance_active PLUGIN   vrai si cette instance du plugin (CLAUDE_PLUGIN_ROOT) doit s'exécuter
#   capia_dossier_donnees          dossier des données locales du marketplace
#   capia_chemin_unix CHEMIN       chemin à séparateurs / (cygpath -u sous Git Bash, sinon \ remplacés par /)
#   capia_glob_vers_regex GLOB     expression régulière étendue équivalente à un motif de chemin (syntaxe .claude/rules)
#   capia_motifs_regle FICHIER     motifs de l'en-tête paths d'un fichier de règle, un par ligne
#   capia_corps_regle FICHIER      contenu d'un fichier de règle sans son en-tête
#   capia_injecter_regles PLUGIN DOSSIER [PREFIXE]
#                                  moteur du hook PreToolUse : lit l'événement sur l'entrée standard et produit le
#                                  contexte additionnel des règles de DOSSIER dont un motif correspond au fichier
#                                  manipulé, une seule fois par règle et par session

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

capia_chemin_unix() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$1" 2>/dev/null || printf '%s\n' "${1//\\//}"
  else
    printf '%s\n' "${1//\\//}"
  fi
}

# Conversion d'un motif de chemin en expression régulière étendue ancrée :
# ** (segments quelconques, y compris aucun), * (hors /), ? (un caractère hors /), {a,b} (alternative).
capia_glob_vers_regex() {
  local glob="$1" regex="" i c accolades=0
  for ((i = 0; i < ${#glob}; i++)); do
    c="${glob:i:1}"
    case "$c" in
      '*')
        if [ "${glob:i+1:1}" = "*" ]; then
          if [ "${glob:i+2:1}" = "/" ]; then
            regex="${regex}(.*/)?"
            i=$((i + 2))
          else
            regex="${regex}.*"
            i=$((i + 1))
          fi
        else
          regex="${regex}[^/]*"
        fi ;;
      '?') regex="${regex}[^/]" ;;
      '{') regex="${regex}("; accolades=$((accolades + 1)) ;;
      '}')
        if [ "$accolades" -gt 0 ]; then regex="${regex})"; accolades=$((accolades - 1)); else regex="${regex}\\}"; fi ;;
      ',')
        if [ "$accolades" -gt 0 ]; then regex="${regex}|"; else regex="${regex},"; fi ;;
      [.+\(\)\|^\$\[\]\\]) regex="${regex}\\${c}" ;;
      *) regex="${regex}${c}" ;;
    esac
  done
  printf '^%s$\n' "$regex"
}

# En-tête attendu en première ligne : ---, puis paths: "a, b" (chaîne, virgules) ou paths: suivi d'une liste - "a".
capia_motifs_regle() {
  awk '
    function nettoyer(v) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); gsub(/^["\047]|["\047]$/, "", v); return v }
    NR == 1 { if ($0 != "---") exit; next }
    /^---[[:space:]]*$/ { exit }
    /^paths:/ {
      valeur = $0; sub(/^paths:[[:space:]]*/, "", valeur)
      liste = (valeur == "")
      if (!liste) { valeur = nettoyer(valeur); n = split(valeur, m, /,/); for (i = 1; i <= n; i++) { v = nettoyer(m[i]); if (v != "") print v } }
      next
    }
    liste && /^[[:space:]]*-/ { v = $0; sub(/^[[:space:]]*-/, "", v); v = nettoyer(v); if (v != "") print v; next }
    { liste = 0 }
  ' "$1"
}

# Corps d'un fichier de règle, sans son en-tête.
capia_corps_regle() {
  awk 'NR == 1 && $0 == "---" { entete = 1; next } entete && /^---[[:space:]]*$/ { entete = 0; next } !entete' "$1"
}

capia_injecter_regles() {
  local plugin="$1" dossier="$2" prefixe="${3:-}" evenement fichier session projet relatif regle nom motif etat contexte=""
  evenement="$(cat)"
  fichier="$(printf '%s' "$evenement" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null)"
  session="$(printf '%s' "$evenement" | jq -r '.session_id // empty' 2>/dev/null)"
  [ -n "$fichier" ] && [ -n "$session" ] && [ -d "$dossier" ] || return 0
  case "$session" in *[!A-Za-z0-9_-]*) return 0 ;; esac
  projet="${CLAUDE_PROJECT_DIR:-}"
  [ -n "$projet" ] || projet="$(printf '%s' "$evenement" | jq -r '.cwd // empty' 2>/dev/null)"
  [ -n "$projet" ] || return 0
  fichier="$(capia_chemin_unix "$fichier")"
  projet="$(capia_chemin_unix "$projet")"
  projet="${projet%/}"
  case "$fichier" in
    "$projet"/*) relatif="${fichier#"$projet"/}" ;;
    /*) return 0 ;;
    *) relatif="$fichier" ;;
  esac
  etat="$(capia_dossier_donnees)/sessions/$session"
  for regle in "$dossier"/*.md; do
    [ -f "$regle" ] || continue
    nom="$(basename "$regle" .md)"
    [ -e "$etat/$plugin--$nom" ] && continue
    while IFS= read -r motif; do
      if printf '%s\n' "$relatif" | grep -Eq "$(capia_glob_vers_regex "$motif")"; then
        contexte="$contexte

## Règles $prefixe$nom ($plugin, fichiers $motif)

$(capia_corps_regle "$regle")"
        (umask 077 && mkdir -p "$etat" && : >"$etat/$plugin--$nom") 2>/dev/null
        break
      fi
    done < <(capia_motifs_regle "$regle")
  done
  [ -n "$contexte" ] || return 0
  contexte="Règles du marketplace capitalisationIA applicables au fichier $relatif. En cas de contradiction avec le CLAUDE.md, les règles versionnées du projet ou les règles propres au projet (plugin regles-projets), ces dernières prévalent.$contexte"
  jq -n --arg c "$contexte" '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $c}}'
}
