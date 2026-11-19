#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Publication d'une version stable d'un plugin, ou retour arrière du canal stable.
# Appelé par le workflow .github/workflows/publication.yml ; utilisable en local pour les tests.
#
# Usage :
#   outils/publier.sh publication <plugin> <version>
#   outils/publier.sh retour-arriere <plugin> <version>
#
# publication    : crée et pousse le tag <plugin>--v<version> sur le commit courant de main,
#                  puis met à jour l'entrée du catalogue stable, committe et pousse sur main.
# retour-arriere : repointe l'entrée du catalogue stable sur un tag existant, sans créer de tag.
#
# Variables d'environnement :
#   CAPIA_DEPOT_URL        URL git du dépôt écrite dans les sources git-subdir
#                          (défaut https://github.com/talbotgui/capitalisationIA.git)
#   CAPIA_BRANCHE          branche de publication (défaut main)
#   CAPIA_REMOTE           remote git (défaut origin)
#   CAPIA_PUBLIER_SANS_PUSH=1  n'effectue aucun push (tests)

set -euo pipefail

DEPOT_URL="${CAPIA_DEPOT_URL:-https://github.com/talbotgui/capitalisationIA.git}"
BRANCHE="${CAPIA_BRANCHE:-main}"
REMOTE="${CAPIA_REMOTE:-origin}"
CATALOGUE_STABLE=".claude-plugin/marketplace.json"
SEMVER='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'

erreur() {
  echo "ERREUR : $*" >&2
  exit 1
}

usage() {
  echo "Usage : $0 publication|retour-arriere <plugin> <version>" >&2
  exit 2
}

pousser() {
  if [ "${CAPIA_PUBLIER_SANS_PUSH:-0}" = "1" ]; then
    echo "(push désactivé) git push $*"
  else
    git push "$@"
  fi
}

# Version courante de l'entrée du plugin dans le catalogue stable (vide si absente).
version_stable_actuelle() {
  jq -r --arg p "$1" '(.plugins[] | select(.name == $p) | .version) // ""' "$CATALOGUE_STABLE"
}

# Plus grande version publiée (tag) du plugin, vide si aucune.
derniere_version_publiee() {
  git tag --list "$1--v*" | sed "s/^$1--v//" | { grep -E "$SEMVER" || true; } | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1
}

# Vrai si $1 est strictement supérieure à $2 (semver x.y.z).
superieure() {
  [ "$1" != "$2" ] && [ "$(printf '%s\n%s\n' "$1" "$2" | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1)" = "$1" ]
}

# Met à jour (ou crée) l'entrée du plugin dans le catalogue stable.
mettre_a_jour_catalogue() {
  local plugin="$1" version="$2" description tmp
  description="$(jq -r '.description // ""' "plugins/$plugin/.claude-plugin/plugin.json")"
  tmp="$(mktemp)"
  jq --arg p "$plugin" --arg v "$version" --arg d "$description" --arg u "$DEPOT_URL" '
    ({
      name: $p,
      description: $d,
      version: $v,
      source: { source: "git-subdir", url: $u, path: ("plugins/" + $p), ref: ($p + "--v" + $v) }
    }) as $entree
    | if any(.plugins[]; .name == $p)
      then .plugins |= map(if .name == $p then .version = $v | .source.ref = ($p + "--v" + $v) else . end)
      else .plugins += [$entree] | .plugins |= sort_by(.name)
      end' "$CATALOGUE_STABLE" > "$tmp"
  mv "$tmp" "$CATALOGUE_STABLE"
}

[ $# -eq 3 ] || usage
mode="$1"
plugin="$2"
version="$3"
tag="$plugin--v$version"

case "$mode" in
  publication | retour-arriere) ;;
  *) usage ;;
esac

command -v jq >/dev/null 2>&1 || erreur "jq est requis."
cd "$(git rev-parse --show-toplevel)"

# Contrôles communs
[ "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCHE" ] || erreur "la publication se fait uniquement depuis la branche $BRANCHE."
[ -z "$(git status --porcelain)" ] || erreur "l'arbre de travail n'est pas propre."
[ -f "plugins/$plugin/.claude-plugin/plugin.json" ] || erreur "plugin inconnu : plugins/$plugin/.claude-plugin/plugin.json absent."
[[ "$version" =~ $SEMVER ]] || erreur "version invalide « $version » (attendu : x.y.z)."
if jq -e 'has("version")' "plugins/$plugin/.claude-plugin/plugin.json" >/dev/null; then
  erreur "plugins/$plugin/.claude-plugin/plugin.json ne doit pas contenir de champ version."
fi

if [ "$mode" = "publication" ]; then
  git rev-parse -q --verify "refs/tags/$tag" >/dev/null && erreur "le tag $tag existe déjà."
  derniere="$(derniere_version_publiee "$plugin")"
  if [ -n "$derniere" ] && ! superieure "$version" "$derniere"; then
    erreur "la version $version doit être strictement supérieure à la dernière version publiée ($derniere)."
  fi
  changelog="plugins/$plugin/CHANGELOG.md"
  [ -f "$changelog" ] || erreur "$changelog absent."
  grep -Eq "^## \[?${version//./\\.}\]?([[:space:]]|$)" "$changelog" || erreur "$changelog ne contient pas de section « ## $version »."

  git tag -a "$tag" -m "Publication de $plugin $version"
  pousser "$REMOTE" "refs/tags/$tag"
  message="Publier $plugin $version dans le canal stable"
else
  git rev-parse -q --verify "refs/tags/$tag" >/dev/null || erreur "le tag $tag n'existe pas : retour arrière impossible."
  [ "$(version_stable_actuelle "$plugin")" != "$version" ] || erreur "le canal stable pointe déjà sur $plugin $version."
  message="Retour arrière de $plugin en version $version dans le canal stable"
fi

mettre_a_jour_catalogue "$plugin" "$version"
git add "$CATALOGUE_STABLE"
git commit -q -m "$message"
pousser "$REMOTE" "HEAD:refs/heads/$BRANCHE"

echo "Tag : $tag"
echo "Commit : $(git rev-parse HEAD)"
echo "Entrée stable :"
jq --arg p "$plugin" '.plugins[] | select(.name == $p)' "$CATALOGUE_STABLE"
