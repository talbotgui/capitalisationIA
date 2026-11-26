#!/usr/bin/env bats
# Fichier généré avec l'assistance de l'IA (Claude).
# Tests des règles des plugins de stack : pour chaque fichier manipulé, règles injectées attendues
# (première manipulation de la session, état vierge), et contenu des règles transmises.

bats_require_minimum_version 1.5.0

load aide

setup() {
  export CLAUDE_CONFIG_DIR="$BATS_TEST_TMPDIR/config"
  mkdir -p "$CLAUDE_CONFIG_DIR"
  unset CAPIA_DESACTIVER CLAUDE_PLUGIN_ROOT
  export CLAUDE_PROJECT_DIR="$BATS_TEST_TMPDIR/projet"
  mkdir -p "$CLAUDE_PROJECT_DIR"
}

# regles_injectees PLUGIN FICHIER : noms des règles injectées, triés, séparés par des espaces.
regles_injectees() {
  local session
  session="s$RANDOM$RANDOM"
  jq -n --arg f "$CLAUDE_PROJECT_DIR/$2" --arg s "$session" '{session_id: $s, tool_name: "Read", tool_input: {file_path: $f}}' \
    | bash "$RACINE_DEPOT/plugins/$1/scripts/injecter-regles.sh" \
    | jq -r '.hookSpecificOutput.additionalContext // empty' \
    | sed -n 's/^## Règles [a-z]*-\([a-z-]*\) (.*/\1/p' | sort | paste -sd' ' -
}

verifier() {
  local resultat
  resultat="$(regles_injectees "$1" "$2")"
  [ "$resultat" = "$3" ] || { echo "$1 $2 : attendu « $3 », obtenu « $resultat »"; return 1; }
}

@test "java : correspondance des fichiers et des règles" {
  verifier stack-java-spring src/main/java/ex/A.java "conception developpement securite"
  verifier stack-java-spring src/test/java/ex/ATest.java "developpement tests"
  verifier stack-java-spring module/src/test/java/ex/AIT.java "developpement tests"
  verifier stack-java-spring pom.xml "maven"
  verifier stack-java-spring build.gradle.kts "gradle"
  verifier stack-java-spring gradle/libs.versions.toml "gradle"
  verifier stack-java-spring src/main/resources/application-prod.properties "spring-configuration"
  verifier stack-java-spring src/app/a.ts ""
}

@test "ts-angular : correspondance des fichiers et des règles (conventions avec et sans suffixe)" {
  local A="angular-composants angular-conception angular-securite"
  verifier stack-ts-angular src/app/user/user-card.component.ts "$A typescript"
  verifier stack-ts-angular src/app/user-profile/user-profile.ts "$A typescript"
  verifier stack-ts-angular src/app/user-profile/user-profile.html "angular-composants angular-securite"
  verifier stack-ts-angular src/app/user-profile/user-profile.spec.ts "$A tests typescript"
  verifier stack-ts-angular projects/ma-lib/src/lib/bouton.ts "$A typescript"
  verifier stack-ts-angular legacy/user-card.component.html "angular-composants angular-securite"
  verifier stack-ts-angular src/environments/environment.ts "angular-securite typescript"
  verifier stack-ts-angular src/server.ts "angular-securite typescript"
  verifier stack-ts-angular e2e/parcours.ts "tests typescript"
  verifier stack-ts-angular outils/generer.ts "typescript"
  verifier stack-ts-angular package.json "configuration"
  verifier stack-ts-angular tsconfig.app.json "configuration"
  verifier stack-ts-angular src/main/java/A.java ""
}

@test "rust-tauri : correspondance des fichiers et des règles" {
  verifier stack-rust-tauri src/lib.rs "conception developpement securite tests"
  verifier stack-rust-tauri src-tauri/src/commandes/projet.rs "conception developpement securite tauri-commandes tests"
  verifier stack-rust-tauri tests/api.rs "developpement tests"
  verifier stack-rust-tauri src-tauri/Cargo.toml "cargo"
  verifier stack-rust-tauri rust-toolchain.toml "cargo"
  verifier stack-rust-tauri src-tauri/tauri.conf.json "tauri-configuration"
  verifier stack-rust-tauri src-tauri/tauri.windows.conf.json "tauri-configuration"
  verifier stack-rust-tauri src-tauri/capabilities/default.json "tauri-configuration"
  verifier stack-rust-tauri src/app/a.ts ""
}

@test "règles transmises sans en-tête ni mention d'origine, chacune une seule fois par session" {
  local e="$BATS_TEST_TMPDIR/e.json"
  jq -n --arg f "$CLAUDE_PROJECT_DIR/src-tauri/capabilities/default.json" '{session_id: "s1", tool_input: {file_path: $f}}' > "$e"
  run bash "$RACINE_DEPOT/plugins/stack-rust-tauri/scripts/injecter-regles.sh" < "$e"
  contexte="$(jq -r .hookSpecificOutput.additionalContext <<<"$output")"
  [[ "$contexte" == *"Moindre privilège"* ]]
  [[ "$contexte" == *'$HOME/**'* ]]
  [[ "$contexte" != *"<!--"* ]]
  [[ "$contexte" != *"paths:"* ]]
  run bash "$RACINE_DEPOT/plugins/stack-rust-tauri/scripts/injecter-regles.sh" < "$e"
  [ -z "$output" ]
}

@test "plugins de stack : mention de licence des règles adaptées" {
  for p in stack-java-spring stack-ts-angular stack-rust-tauri; do
    grep -q "affaan-m/ecc" "$RACINE_DEPOT/plugins/$p/NOTICE.md"
    grep -q "Permission is hereby granted" "$RACINE_DEPOT/plugins/$p/NOTICE.md"
  done
}
