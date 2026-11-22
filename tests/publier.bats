#!/usr/bin/env bats
# Fichier généré avec l'assistance de l'IA (Claude).
# Tests de outils/publier.sh (sans push).

load aide

setup() {
  creer_depot_fixture
  export CAPIA_PUBLIER_SANS_PUSH=1
  cd "$DEPOT"
}

entree_stable() {
  jq -c --arg p "$1" '.plugins[] | select(.name == $p) | {version, ref: .source.ref, path: .source.path, url: .source.url}' .claude-plugin/marketplace.json
}

@test "publication : crée le tag et l'entrée du catalogue stable" {
  run outils/publier.sh publication temoin 0.1.0
  [ "$status" -eq 0 ]
  git rev-parse -q --verify refs/tags/temoin--v0.1.0
  [ "$(entree_stable temoin)" = "{\"version\":\"0.1.0\",\"ref\":\"temoin--v0.1.0\",\"path\":\"plugins/temoin\",\"url\":\"$CAPIA_DEPOT_URL\"}" ]
  [ -z "$(git status --porcelain)" ]
  # Le tag pointe sur le commit précédant la mise à jour du catalogue.
  [ "$(git rev-parse temoin--v0.1.0^{commit})" = "$(git rev-parse HEAD~1)" ]
  run outils/verifier-coherence.sh
  [ "$status" -eq 0 ]
}

@test "publication : met à jour une entrée existante" {
  outils/publier.sh publication temoin 0.1.0
  ajouter_section_changelog temoin 0.2.0
  run outils/publier.sh publication temoin 0.2.0
  [ "$status" -eq 0 ]
  [ "$(jq '[.plugins[] | select(.name == "temoin")] | length' .claude-plugin/marketplace.json)" -eq 1 ]
  [ "$(entree_stable temoin | jq -r .ref)" = "temoin--v0.2.0" ]
}

@test "publication : refuse un tag existant" {
  outils/publier.sh publication temoin 0.1.0
  run outils/publier.sh publication temoin 0.1.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"existe déjà"* ]]
}

@test "publication : refuse une version inférieure à la dernière publiée" {
  ajouter_section_changelog temoin 0.10.0
  outils/publier.sh publication temoin 0.10.0
  ajouter_section_changelog temoin 0.9.0
  run outils/publier.sh publication temoin 0.9.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"strictement supérieure"* ]]
}

@test "publication : refuse une version sans section dans le CHANGELOG" {
  run outils/publier.sh publication temoin 99.0.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"CHANGELOG"* ]]
}

@test "publication : refuse une version non semver" {
  run outils/publier.sh publication temoin 1.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"version invalide"* ]]
}

@test "publication : refuse un plugin inconnu" {
  run outils/publier.sh publication inconnu 1.0.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"plugin inconnu"* ]]
}

@test "publication : refuse un arbre de travail modifié" {
  echo "modif" >> plugins/temoin/README.md
  run outils/publier.sh publication temoin 0.1.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"pas propre"* ]]
}

@test "publication : refuse une autre branche que main" {
  git checkout -q -b autre
  run outils/publier.sh publication temoin 0.1.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"uniquement depuis la branche main"* ]]
}

@test "publication : refuse un plugin.json contenant une version" {
  tmp="$(mktemp)"
  jq '.version = "0.1.0"' plugins/temoin/.claude-plugin/plugin.json > "$tmp" && mv "$tmp" plugins/temoin/.claude-plugin/plugin.json
  git commit -q -am "version"
  run outils/publier.sh publication temoin 0.1.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"champ version"* ]]
}

@test "retour arrière : repointe l'entrée stable sans créer de tag" {
  outils/publier.sh publication temoin 0.1.0
  ajouter_section_changelog temoin 0.2.0
  outils/publier.sh publication temoin 0.2.0
  tags_avant="$(git tag | wc -l)"
  run outils/publier.sh retour-arriere temoin 0.1.0
  [ "$status" -eq 0 ]
  [ "$(entree_stable temoin | jq -r .ref)" = "temoin--v0.1.0" ]
  [ "$(entree_stable temoin | jq -r .version)" = "0.1.0" ]
  [ "$(git tag | wc -l)" -eq "$tags_avant" ]
}

@test "retour arrière : refuse un tag inexistant" {
  run outils/publier.sh retour-arriere temoin 0.0.1
  [ "$status" -ne 0 ]
  [[ "$output" == *"n'existe pas"* ]]
}

@test "retour arrière : refuse la version déjà en place" {
  outils/publier.sh publication temoin 0.1.0
  run outils/publier.sh retour-arriere temoin 0.1.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"pointe déjà"* ]]
}
