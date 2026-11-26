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
#   * toutes les sources sont des git-subdir vers plugins/<nom> du même dépôt ;
#   * toute copie de lib/commun.sh dans un plugin est identique à celle de socle ;
#   * tout fichier regles/*.md d'un plugin porte un en-tête paths non vide ;
#   * projets/mapping.json de regles-projets : dossiers existants avec index.md, remotes normalisés et uniques.

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

# Copies de la bibliothèque commune
BIBLIOTHEQUE="plugins/socle/lib/commun.sh"
for copie in plugins/*/lib/commun.sh; do
  [ -e "$copie" ] && [ "$copie" != "$BIBLIOTHEQUE" ] || continue
  cmp -s "$copie" "$BIBLIOTHEQUE" || signaler "$copie diffère de $BIBLIOTHEQUE (recopier la bibliothèque de socle)."
done

# Règles injectées par motif de fichier
# shellcheck source=SCRIPTDIR/../plugins/socle/lib/commun.sh
. "$BIBLIOTHEQUE"
for regle in plugins/*/regles/*.md; do
  [ -e "$regle" ] || continue
  [ -n "$(capia_motifs_regle "$regle")" ] || signaler "$regle : en-tête paths absent ou vide (la règle ne serait jamais injectée)."
done

# Mapping des règles projets
MAPPING="plugins/regles-projets/projets/mapping.json"
if [ -f "$MAPPING" ]; then
  if ! jq -e '.projets | type == "array"' "$MAPPING" >/dev/null 2>&1; then
    signaler "$MAPPING : JSON invalide ou tableau projets absent."
  else
    while IFS=$'\t' read -r dossier remote; do
      case "$dossier" in
        ""|_*|.*|*[!a-z0-9._-]*) signaler "$MAPPING : nom de dossier invalide « $dossier »." ;;
        *) [ -f "plugins/regles-projets/projets/$dossier/index.md" ] || signaler "$MAPPING : plugins/regles-projets/projets/$dossier/index.md absent." ;;
      esac
      [ "$(capia_normaliser_remote "https://$remote")" = "$remote" ] || signaler "$MAPPING : remote « $remote » non normalisé (attendu hote/proprietaire/depot en minuscules)."
    done < <(jq -r '.projets[] | .dossier as $d | (.remotes // [])[] | [$d, .] | @tsv' "$MAPPING")
    for doublon in $(jq -r '[.projets[].remotes[]] | group_by(.) | map(select(length > 1) | .[0]) | .[]' "$MAPPING"); do
      signaler "$MAPPING : remote $doublon associé à plusieurs projets."
    done
  fi
fi

if [ "$erreurs" -gt 0 ]; then
  echo "$erreurs erreur(s) de cohérence." >&2
  exit 1
fi
echo "Cohérence vérifiée."
