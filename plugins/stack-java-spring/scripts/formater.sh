#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Hook PostToolUse (Edit, MultiEdit, Write) du plugin stack-java-spring, sur le modèle de
# formater-et-analyser.sh de suiviProjets : formate le seul fichier .java modifié avec l'outil déjà
# présent sur le poste ou configuré dans le projet, par ordre de préférence :
#   1. google-java-format dans le PATH ;
#   2. plugin Spotless déclaré dans le pom.xml du module : mvnw ou mvn spotless:apply, hors ligne ;
#   3. plugin Spotless déclaré dans le build.gradle(.kts) du module : gradlew ou gradle spotlessApply, hors ligne.
# Aucune installation ni téléchargement. Sortie immédiate si le fichier n'est pas un .java d'un projet
# Maven ou Gradle, silencieuse si aucun outil n'est disponible. Les erreurs d'outil sont écrites sur
# la sortie d'erreur sans interrompre la session. Sort toujours en code 0.

set -uo pipefail

racine_plugin="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=SCRIPTDIR/../lib/commun.sh
. "$racine_plugin/lib/commun.sh" || exit 0

capia_desactive stack-java-spring && exit 0
command -v jq >/dev/null 2>&1 || exit 0
capia_instance_active stack-java-spring || exit 0

DELAI="${CAPIA_JAVA_DELAI:-50}"

evenement="$(cat)"
fichier="$(printf '%s' "$evenement" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
case "$fichier" in *.java) ;; *) exit 0 ;; esac
fichier="$(capia_chemin_unix "$fichier")"
[ -f "$fichier" ] || exit 0

projet="${CLAUDE_PROJECT_DIR:-}"
[ -n "$projet" ] || projet="$(printf '%s' "$evenement" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$projet" ] || exit 0
projet="$(capia_chemin_unix "$projet")"
projet="${projet%/}"
case "$fichier" in "$projet"/*) ;; *) exit 0 ;; esac

# Module : premier dossier, en remontant depuis le fichier jusqu'au projet, contenant un fichier de construction.
module=""
dossier="$(dirname "$fichier")"
while :; do
  if [ -f "$dossier/pom.xml" ] || [ -f "$dossier/build.gradle" ] || [ -f "$dossier/build.gradle.kts" ]; then
    module="$dossier"
    break
  fi
  [ "$dossier" = "$projet" ] && break
  dossier="$(dirname "$dossier")"
  case "$dossier" in "$projet"|"$projet"/*) ;; *) break ;; esac
done
[ -n "$module" ] || exit 0

executer() {
  local outil="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$DELAI" "$@"
  else
    "$@"
  fi 2>&1 | sed "s/^/[stack-java-spring $outil] /" >&2
}

# Lanceur local (mvnw, gradlew) remonté depuis le module jusqu'au projet, sinon commande du PATH.
lanceur() {
  local local_="$1" global="$2" d="$module"
  while :; do
    [ -x "$d/$local_" ] && { printf '%s\n' "$d/$local_"; return 0; }
    [ "$d" = "$projet" ] && break
    d="$(dirname "$d")"
  done
  command -v "$global" 2>/dev/null
}

if command -v google-java-format >/dev/null 2>&1; then
  executer google-java-format google-java-format --replace "$fichier"
elif [ -f "$module/pom.xml" ] && grep -q "spotless-maven-plugin" "$module/pom.xml" 2>/dev/null; then
  mvn_="$(lanceur mvnw mvn)" || exit 0
  [ -n "$mvn_" ] || exit 0
  # Expression régulière Spotless : fin du chemin absolu, caractères spéciaux échappés, séparateur / ou \.
  relatif="${fichier#"$module"/}"
  motif=".*"
  for ((i = 0; i < ${#relatif}; i++)); do
    c="${relatif:i:1}"
    case "$c" in
      /) motif="${motif}[/\\]" ;;
      [.*+?^\$\(\)\{\}\|\[\]\\]) motif="${motif}\\${c}" ;;
      *) motif="${motif}${c}" ;;
    esac
  done
  (cd "$module" && executer spotless "$mvn_" -q -o spotless:apply "-DspotlessFiles=$motif")
elif grep -qs "com.diffplug.spotless" "$module/build.gradle" "$module/build.gradle.kts"; then
  gradle_="$(lanceur gradlew gradle)" || exit 0
  [ -n "$gradle_" ] || exit 0
  (cd "$module" && executer spotless "$gradle_" -q --offline spotlessApply "-PspotlessIdeHook=$fichier")
fi

exit 0
