#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Contrôles de cohérence du dépôt, exécutés par la CI (validation.yml).
# Les tags doivent être présents localement (checkout avec fetch-depth: 0).
#
# Contrôles :
#   * aucun plugin.json ne porte de champ version ;
#   * chaque plugin a un CHANGELOG.md et un README.md ;
#   * chaque plugin est référencé dans le catalogue early access, avec ref main et sans version ;
#   * chaque entrée du catalogue early access correspond à un dossier plugins/<nom> ;
#   * chaque entrée stable pointe vers un tag <plugin>--v<version> existant, cohérent avec son champ version ;
#   * toutes les sources sont des git-subdir vers plugins/<nom> du même dépôt.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CATALOGUE_STABLE=".claude-plugin/marketplace.json"
CATALOGUE_EARLY="canaux/early-access/.claude-plugin/marketplace.json"
DEPOT_URL="${CAPIA_DEPOT_URL:-https://github.com/talbotgui/capitalisationIA.git}"

erreurs=0
signaler() {
  echo "ERREUR : $*" >&2
  erreurs=$((erreurs + 1))
}

for manifeste in plugins/*/.claude-plugin/plugin.json; do
  [ -e "$manifeste" ] || continue
  dossier="$(dirname "$(dirname "$manifeste")")"
  nom="$(basename "$dossier")"

  [ "$(jq -r '.name' "$manifeste")" = "$nom" ] || signaler "$manifeste : name différent du nom de dossier « $nom »."
  jq -e 'has("version")' "$manifeste" >/dev/null && signaler "$manifeste : le champ version est interdit (il figerait le canal early access)."
  [ -f "$dossier/CHANGELOG.md" ] || signaler "$dossier/CHANGELOG.md absent."
  [ -f "$dossier/README.md" ] || signaler "$dossier/README.md absent."

  jq -e --arg n "$nom" 'any(.plugins[]; .name == $n)' "$CATALOGUE_EARLY" >/dev/null \
    || signaler "$nom absent du catalogue early access."
done

# Catalogue early access
while IFS=$'\t' read -r nom source url chemin ref version; do
  [ -d "plugins/$nom" ] || signaler "early access : $nom ne correspond à aucun dossier plugins/."
  [ "$source" = "git-subdir" ] || signaler "early access : $nom doit avoir une source git-subdir."
  [ "$url" = "$DEPOT_URL" ] || signaler "early access : $nom doit pointer sur $DEPOT_URL."
  [ "$chemin" = "plugins/$nom" ] || signaler "early access : $nom doit avoir le chemin plugins/$nom."
  [ "$ref" = "main" ] || signaler "early access : $nom doit avoir la ref main."
  [ -z "$version" ] || signaler "early access : $nom ne doit pas avoir de champ version."
done < <(jq -r '.plugins[] | [.name, .source.source, .source.url, .source.path, .source.ref, (.version // "")] | @tsv' "$CATALOGUE_EARLY")

# Catalogue stable
while IFS=$'\t' read -r nom source url chemin ref version; do
  [ -d "plugins/$nom" ] || signaler "stable : $nom ne correspond à aucun dossier plugins/."
  [ "$source" = "git-subdir" ] || signaler "stable : $nom doit avoir une source git-subdir."
  [ "$url" = "$DEPOT_URL" ] || signaler "stable : $nom doit pointer sur $DEPOT_URL."
  [ "$chemin" = "plugins/$nom" ] || signaler "stable : $nom doit avoir le chemin plugins/$nom."
  [ "$ref" = "$nom--v$version" ] || signaler "stable : $nom doit avoir la ref $nom--v$version (trouvé : $ref)."
  git rev-parse -q --verify "refs/tags/$ref" >/dev/null || signaler "stable : le tag $ref n'existe pas."
done < <(jq -r '.plugins[] | [.name, .source.source, .source.url, .source.path, .source.ref, (.version // "")] | @tsv' "$CATALOGUE_STABLE")

if [ "$erreurs" -gt 0 ]; then
  echo "$erreurs erreur(s) de cohérence." >&2
  exit 1
fi
echo "Cohérence vérifiée."
