# Fichier généré avec l'assistance de l'IA (Claude).
# Fonctions communes aux tests bats.

RACINE_DEPOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

# Crée dans $BATS_TEST_TMPDIR/depot une copie du dépôt (catalogues, plugins, outils),
# initialisée en dépôt git sur la branche main avec un commit, et dont les sources
# git-subdir pointent sur ce dépôt local. Exporte DEPOT et CAPIA_DEPOT_URL.
creer_depot_fixture() {
  DEPOT="$BATS_TEST_TMPDIR/depot"
  mkdir -p "$DEPOT/canaux/early-access"
  cp -R "$RACINE_DEPOT/.claude-plugin" "$DEPOT/"
  cp -R "$RACINE_DEPOT/canaux/early-access/.claude-plugin" "$DEPOT/canaux/early-access/"
  cp -R "$RACINE_DEPOT/plugins" "$RACINE_DEPOT/outils" "$DEPOT/"
  export CAPIA_DEPOT_URL="file://$DEPOT"
  local early="$DEPOT/canaux/early-access/.claude-plugin/marketplace.json" tmp
  tmp="$(mktemp)"
  jq --arg u "$CAPIA_DEPOT_URL" '.plugins |= map(.source.url = $u)' "$early" > "$tmp" && mv "$tmp" "$early"
  git -C "$DEPOT" init -q -b main
  git -C "$DEPOT" config user.email "tests@exemple.invalid"
  git -C "$DEPOT" config user.name "tests"
  git -C "$DEPOT" add -A
  git -C "$DEPOT" commit -q -m "Fixture"
  export DEPOT
}

# Ajoute une section de version au CHANGELOG d'un plugin de la fixture et committe.
ajouter_section_changelog() {
  local plugin="$1" version="$2"
  printf '\n## %s\n\n* Test.\n' "$version" >> "$DEPOT/plugins/$plugin/CHANGELOG.md"
  git -C "$DEPOT" commit -q -am "Changelog $plugin $version"
}
