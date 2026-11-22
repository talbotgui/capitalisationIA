#!/usr/bin/env bats
# Fichier généré avec l'assistance de l'IA (Claude).
# Tests du hook SessionStart du plugin regles-projets, sur une copie du plugin avec un mapping fictif.

bats_require_minimum_version 1.5.0

load aide

setup() {
  export CLAUDE_CONFIG_DIR="$BATS_TEST_TMPDIR/config"
  mkdir -p "$CLAUDE_CONFIG_DIR"
  unset CAPIA_DESACTIVER CLAUDE_PLUGIN_ROOT
  PLUGIN="$BATS_TEST_TMPDIR/regles-projets"
  cp -R "$RACINE_DEPOT/plugins/regles-projets" "$PLUGIN"
  rm -rf "$PLUGIN/projets"/*/
  mkdir -p "$PLUGIN/projets/fictif"
  printf '# Projet fictif\n\nRègle essentielle du projet fictif.\n' > "$PLUGIN/projets/fictif/index.md"
  printf '# Tests\n' > "$PLUGIN/projets/fictif/tests.md"
  echo '{"projets":[{"dossier":"fictif","remotes":["github.com/exemple/fictif","github.com/forkeur/fictif"]}]}' > "$PLUGIN/projets/mapping.json"
  SCRIPT="$PLUGIN/scripts/injecter-regles.sh"
  PROJET="$BATS_TEST_TMPDIR/projet"
  mkdir -p "$PROJET"
  git -C "$PROJET" init -q
  export CLAUDE_PROJECT_DIR="$PROJET"
}

evenement() {
  jq -n --arg s "$1" '{hook_event_name: "SessionStart", source: $s}'
}

@test "projet connu : règles injectées et message au démarrage" {
  git -C "$PROJET" remote add origin git@github.com:Exemple/Fictif.git
  run bash "$SCRIPT" <<<"$(evenement startup)"
  [ "$status" -eq 0 ]
  [ "$(jq -r .hookSpecificOutput.hookEventName <<<"$output")" = "SessionStart" ]
  contexte="$(jq -r .hookSpecificOutput.additionalContext <<<"$output")"
  [[ "$contexte" == *"Règle essentielle du projet fictif."* ]]
  [[ "$contexte" == *"le CLAUDE.md"*"prévalent"* ]]
  [[ "$contexte" == *"$PLUGIN/projets/fictif/tests.md"* ]]
  [[ "$contexte" != *"index.md"* ]]
  [ "$(jq -r .systemMessage <<<"$output")" = "capitalisationIA : règles du projet fictif chargées." ]
}

@test "réinjection après compactage, sans message affiché" {
  git -C "$PROJET" remote add origin https://github.com/exemple/fictif
  run bash "$SCRIPT" <<<"$(evenement compact)"
  [ "$status" -eq 0 ]
  [[ "$(jq -r .hookSpecificOutput.additionalContext <<<"$output")" == *"Règle essentielle"* ]]
  [ "$(jq -r 'has("systemMessage")' <<<"$output")" = "false" ]
}

@test "fork : second remote du même projet reconnu" {
  git -C "$PROJET" remote add origin git@github.com:forkeur/fictif.git
  run bash "$SCRIPT" <<<"$(evenement startup)"
  [[ "$output" == *"Règle essentielle"* ]]
}

@test "projet inconnu : aucun effet" {
  git -C "$PROJET" remote add origin git@github.com:exemple/autre.git
  run bash "$SCRIPT" <<<"$(evenement startup)"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "projet sans remote ou hors dépôt git : aucun effet" {
  run bash "$SCRIPT" <<<"$(evenement startup)"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  CLAUDE_PROJECT_DIR="$BATS_TEST_TMPDIR" run bash "$SCRIPT" <<<"$(evenement startup)"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "coupe-circuit et instance early inactive respectés" {
  git -C "$PROJET" remote add origin git@github.com:exemple/fictif.git
  CAPIA_DESACTIVER=regles-projets run bash "$SCRIPT" <<<"$(evenement startup)"
  [ -z "$output" ]
  echo '{"enabledPlugins":{"regles-projets@capitalisation-ia":true}}' > "$CLAUDE_CONFIG_DIR/settings.json"
  CLAUDE_PLUGIN_ROOT=/x/plugins/cache/capitalisation-ia-early/regles-projets/abc run bash "$SCRIPT" <<<"$(evenement startup)"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "aucun fichier écrit dans le projet" {
  git -C "$PROJET" remote add origin git@github.com:exemple/fictif.git
  run bash "$SCRIPT" <<<"$(evenement startup)"
  [ -z "$(git -C "$PROJET" status --porcelain --ignored)" ]
}

@test "mapping réel : suiviProjets reconnu" {
  git -C "$PROJET" remote add origin git@github.com:talbotgui/suiviProjets.git
  run bash "$RACINE_DEPOT/plugins/regles-projets/scripts/injecter-regles.sh" <<<"$(evenement startup)"
  [ "$status" -eq 0 ]
  [[ "$(jq -r .systemMessage <<<"$output")" == *"suiviprojets"* ]]
}
