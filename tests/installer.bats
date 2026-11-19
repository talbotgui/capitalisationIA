#!/usr/bin/env bats
# Fichier généré avec l'assistance de l'IA (Claude).
# Tests de bout en bout de outils/installer.sh sur un dépôt local, avec une configuration
# Claude Code isolée (CLAUDE_CONFIG_DIR). Nécessite la CLI claude ; aucun accès réseau.

load aide

setup_file() {
  command -v claude >/dev/null 2>&1 || skip "CLI claude absente"
}

setup() {
  command -v claude >/dev/null 2>&1 || skip "CLI claude absente"
  creer_depot_fixture
  # Publication de temoin 0.1.0 dans le canal stable de la fixture.
  (cd "$DEPOT" && CAPIA_PUBLIER_SANS_PUSH=1 outils/publier.sh publication temoin 0.1.0 >/dev/null)
  export CLAUDE_CONFIG_DIR="$BATS_TEST_TMPDIR/config"
  export CAPIA_SOURCE_STABLE="$DEPOT"
  export CAPIA_SOURCE_EARLY="$DEPOT/canaux/early-access"
}

etat() {
  claude plugin list --json | jq -r --arg id "$1" '[.[] | select(.id == $id)][0] | if . == null then "absent" elif .enabled then "actif" else "inactif" end'
}

@test "installation stable" {
  run "$RACINE_DEPOT/outils/installer.sh" stable
  [ "$status" -eq 0 ]
  [ "$(etat temoin@capitalisation-ia)" = "actif" ]
  [ "$(etat temoin@capitalisation-ia-early)" = "absent" ]
  [ "$(jq -r '.extraKnownMarketplaces["capitalisation-ia"].autoUpdate' "$CLAUDE_CONFIG_DIR/settings.json")" = "true" ]
  [ "$(claude plugin list --json | jq -r '.[] | select(.id == "temoin@capitalisation-ia") | .version')" = "0.1.0" ]
}

@test "bascule stable, early puis stable : un seul canal actif à chaque étape" {
  "$RACINE_DEPOT/outils/installer.sh" stable
  run "$RACINE_DEPOT/outils/installer.sh" early
  [ "$status" -eq 0 ]
  [ "$(etat temoin@capitalisation-ia)" = "inactif" ]
  [ "$(etat temoin@capitalisation-ia-early)" = "actif" ]
  run "$RACINE_DEPOT/outils/installer.sh" stable
  [ "$status" -eq 0 ]
  [ "$(etat temoin@capitalisation-ia)" = "actif" ]
  [ "$(etat temoin@capitalisation-ia-early)" = "inactif" ]
}

@test "conserve le reste de settings.json et en fait une sauvegarde" {
  mkdir -p "$CLAUDE_CONFIG_DIR"
  echo '{"theme":"dark"}' > "$CLAUDE_CONFIG_DIR/settings.json"
  run "$RACINE_DEPOT/outils/installer.sh" stable
  [ "$status" -eq 0 ]
  [ "$(jq -r .theme "$CLAUDE_CONFIG_DIR/settings.json")" = "dark" ]
  ls "$CLAUDE_CONFIG_DIR"/settings.json.capia-*.bak
}

@test "refuse un settings.json invalide" {
  mkdir -p "$CLAUDE_CONFIG_DIR"
  echo '{ invalide' > "$CLAUDE_CONFIG_DIR/settings.json"
  run "$RACINE_DEPOT/outils/installer.sh" stable
  [ "$status" -ne 0 ]
  [[ "$output" == *"n'est pas un JSON valide"* ]]
}

@test "refuse un canal inconnu" {
  run "$RACINE_DEPOT/outils/installer.sh" beta
  [ "$status" -eq 2 ]
}
