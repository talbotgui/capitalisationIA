#!/usr/bin/env bats
# Fichier généré avec l'assistance de l'IA (Claude).
# Tests du hook SessionStart du plugin temoin.

load aide

SCRIPT="$RACINE_DEPOT/plugins/temoin/scripts/afficher-canal.sh"

setup() {
  export CLAUDE_CONFIG_DIR="$BATS_TEST_TMPDIR/config"
  mkdir -p "$CLAUDE_CONFIG_DIR"
}

@test "affiche le canal stable et la version" {
  CLAUDE_PLUGIN_ROOT="/x/plugins/cache/capitalisation-ia/temoin/0.1.0" run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$(jq -r .systemMessage <<<"$output")" = "capitalisationIA : canal stable, version 0.1.0 du plugin temoin." ]
}

@test "affiche le canal early access" {
  CLAUDE_PLUGIN_ROOT="/x/plugins/cache/capitalisation-ia-early/temoin/abc123" run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$(jq -r .systemMessage <<<"$output")" == *"canal early access, version abc123"* ]]
}

@test "signale une activation simultanée des deux canaux" {
  echo '{"enabledPlugins":{"temoin@capitalisation-ia":true,"temoin@capitalisation-ia-early":true}}' > "$CLAUDE_CONFIG_DIR/settings.json"
  CLAUDE_PLUGIN_ROOT="/x/plugins/cache/capitalisation-ia/temoin/0.1.0" run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ATTENTION"* ]]
}

@test "pas d'alerte si un seul canal est actif" {
  echo '{"enabledPlugins":{"temoin@capitalisation-ia":true,"temoin@capitalisation-ia-early":false}}' > "$CLAUDE_CONFIG_DIR/settings.json"
  CLAUDE_PLUGIN_ROOT="/x/plugins/cache/capitalisation-ia/temoin/0.1.0" run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"ATTENTION"* ]]
}

@test "sort en code 0 sans rien afficher hors contexte de plugin" {
  CLAUDE_PLUGIN_ROOT="" run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
