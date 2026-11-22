#!/usr/bin/env bats
# Fichier généré avec l'assistance de l'IA (Claude).
# Tests de outils/verifier-coherence.sh.

load aide

setup() {
  creer_depot_fixture
  cd "$DEPOT"
}

modifier_json() {
  local fichier="$1" filtre="$2" tmp
  tmp="$(mktemp)"
  jq "$filtre" "$fichier" > "$tmp" && mv "$tmp" "$fichier"
}

@test "dépôt cohérent" {
  run outils/verifier-coherence.sh
  [ "$status" -eq 0 ]
}

@test "détecte un champ version dans plugin.json" {
  modifier_json plugins/temoin/.claude-plugin/plugin.json '.version = "1.0.0"'
  run outils/verifier-coherence.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"champ version est interdit"* ]]
}

@test "détecte un CHANGELOG absent" {
  rm plugins/temoin/CHANGELOG.md
  run outils/verifier-coherence.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"CHANGELOG.md absent"* ]]
}

@test "détecte un plugin absent du catalogue early access" {
  modifier_json canaux/early-access/.claude-plugin/marketplace.json '.plugins = []'
  run outils/verifier-coherence.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"absent du catalogue early access"* ]]
}

@test "détecte une entrée early access avec une version ou une autre ref" {
  modifier_json canaux/early-access/.claude-plugin/marketplace.json '.plugins[0].version = "1.0.0" | .plugins[0].source.ref = "dev"'
  run outils/verifier-coherence.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"ref main"* ]]
  [[ "$output" == *"ne doit pas avoir de champ version"* ]]
}

@test "détecte une entrée stable pointant vers un tag inexistant" {
  tmp="$(mktemp)"
  jq --arg u "$CAPIA_DEPOT_URL" '.plugins = [{name: "temoin", description: "t", version: "9.9.9", source: {source: "git-subdir", url: $u, path: "plugins/temoin", ref: "temoin--v9.9.9"}}]' \
    .claude-plugin/marketplace.json > "$tmp" && mv "$tmp" .claude-plugin/marketplace.json
  run outils/verifier-coherence.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"le tag temoin--v9.9.9 n'existe pas"* ]]
}

@test "détecte une entrée stable dont la ref ne correspond pas à la version" {
  git tag temoin--v1.0.0
  tmp="$(mktemp)"
  jq --arg u "$CAPIA_DEPOT_URL" '.plugins = [{name: "temoin", description: "t", version: "1.0.1", source: {source: "git-subdir", url: $u, path: "plugins/temoin", ref: "temoin--v1.0.0"}}]' \
    .claude-plugin/marketplace.json > "$tmp" && mv "$tmp" .claude-plugin/marketplace.json
  run outils/verifier-coherence.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"doit avoir la ref temoin--v1.0.1"* ]]
}

@test "détecte une copie divergente de la bibliothèque commune" {
  echo "# modification" >> plugins/regles-projets/lib/commun.sh
  run outils/verifier-coherence.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"diffère de plugins/socle/lib/commun.sh"* ]]
}

@test "détecte un mapping vers un dossier sans index.md" {
  modifier_json plugins/regles-projets/projets/mapping.json '.projets += [{"dossier": "absent", "remotes": ["github.com/x/absent"]}]'
  run outils/verifier-coherence.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"absent/index.md absent"* ]]
}

@test "détecte un remote non normalisé ou en double dans le mapping" {
  modifier_json plugins/regles-projets/projets/mapping.json '.projets[0].remotes += ["https://github.com/X/Y.git", .projets[0].remotes[0]]'
  run outils/verifier-coherence.sh
  [ "$status" -ne 0 ]
  [[ "$output" == *"non normalisé"* ]]
  [[ "$output" == *"associé à plusieurs projets"* ]]
}
