#!/usr/bin/env bats
# Fichier généré avec l'assistance de l'IA (Claude).
# Tests du plugin stack-java-spring : injection des règles par motif de fichier et formatage du fichier modifié.
# Les outils de formatage sont simulés par des scripts qui consignent leurs arguments.

bats_require_minimum_version 1.5.0

load aide

PLUGIN="$RACINE_DEPOT/plugins/stack-java-spring"
INJECTER="$PLUGIN/scripts/injecter-regles.sh"
FORMATER="$PLUGIN/scripts/formater.sh"
REINITIALISER="$RACINE_DEPOT/plugins/socle/scripts/reinitialiser-regles.sh"

setup() {
  export CLAUDE_CONFIG_DIR="$BATS_TEST_TMPDIR/config"
  mkdir -p "$CLAUDE_CONFIG_DIR"
  unset CAPIA_DESACTIVER CLAUDE_PLUGIN_ROOT
  PROJET="$BATS_TEST_TMPDIR/projet"
  mkdir -p "$PROJET/src/main/java/exemple" "$PROJET/src/test/java/exemple"
  echo '<project/>' > "$PROJET/pom.xml"
  echo 'class A {}' > "$PROJET/src/main/java/exemple/A.java"
  echo 'class ATest {}' > "$PROJET/src/test/java/exemple/ATest.java"
  echo 'export const a = 1;' > "$PROJET/a.ts"
  export CLAUDE_PROJECT_DIR="$PROJET"
  OUTILS="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$OUTILS"
  TRACE="$BATS_TEST_TMPDIR/trace"
  # PATH réduit : seuls jq, git et les utilitaires système, sans mvn, gradle ni google-java-format réels.
  export PATH="$OUTILS:/usr/bin:/bin"
}

outil_simule() {
  printf '#!/usr/bin/env bash\necho "%s $*" >> "%s"\n%s\n' "$1" "$TRACE" "${2:-exit 0}" > "$OUTILS/$1"
  chmod +x "$OUTILS/$1"
}

evenement() {
  jq -n --arg f "$1" --arg s "${2:-session1}" '{hook_event_name: "PreToolUse", session_id: $s, tool_name: "Read", tool_input: {file_path: $f}}'
}

contexte() {
  jq -r '.hookSpecificOutput.additionalContext // empty' <<<"$output"
}

@test "règles : fichier Java principal, développement et conception injectés une seule fois" {
  run bash "$INJECTER" <<<"$(evenement "$PROJET/src/main/java/exemple/A.java")"
  [ "$status" -eq 0 ]
  [ "$(jq -r .hookSpecificOutput.hookEventName <<<"$output")" = "PreToolUse" ]
  [[ "$(contexte)" == *"Règles java-developpement"* ]]
  [[ "$(contexte)" == *"Règles java-conception"* ]]
  [[ "$(contexte)" != *"java-tests"* ]]
  [[ "$(contexte)" != *"paths:"* ]]
  [[ "$(contexte)" == *"prévalent"* ]]
  run bash "$INJECTER" <<<"$(evenement "$PROJET/src/main/java/exemple/A.java")"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "règles : test Java, seules les règles de test sont ajoutées après le code principal" {
  bash "$INJECTER" <<<"$(evenement "$PROJET/src/main/java/exemple/A.java")" >/dev/null
  run bash "$INJECTER" <<<"$(evenement "$PROJET/src/test/java/exemple/ATest.java")"
  [[ "$(contexte)" == *"Règles java-tests"* ]]
  [[ "$(contexte)" != *"java-developpement"* ]]
}

@test "règles : pom.xml et configuration Spring" {
  run bash "$INJECTER" <<<"$(evenement "$PROJET/pom.xml")"
  [[ "$(contexte)" == *"Règles java-maven"* ]]
  mkdir -p "$PROJET/src/main/resources"
  run bash "$INJECTER" <<<"$(evenement "$PROJET/src/main/resources/application-dev.yml")"
  [[ "$(contexte)" == *"Règles java-spring-configuration"* ]]
}

@test "règles : rien pour un fichier d'une autre stack ou hors du projet" {
  run bash "$INJECTER" <<<"$(evenement "$PROJET/a.ts")"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  run bash "$INJECTER" <<<"$(evenement "/ailleurs/B.java")"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "règles : chemins Windows à séparateurs \\" {
  run env CLAUDE_PROJECT_DIR='C:\p' bash "$INJECTER" <<<"$(evenement 'C:\p\src\main\java\A.java')"
  [[ "$(contexte)" == *"Règles java-developpement"* ]]
}

@test "règles : réinjection après compactage, sessions indépendantes" {
  bash "$INJECTER" <<<"$(evenement "$PROJET/pom.xml")" >/dev/null
  run bash "$INJECTER" <<<"$(evenement "$PROJET/pom.xml" session2)"
  [[ "$(contexte)" == *"java-maven"* ]]
  jq -n '{hook_event_name: "SessionStart", source: "compact", session_id: "session1"}' | bash "$REINITIALISER"
  run bash "$INJECTER" <<<"$(evenement "$PROJET/pom.xml")"
  [[ "$(contexte)" == *"java-maven"* ]]
}

@test "règles : session invalide, coupe-circuit et instance early inactive" {
  run bash "$INJECTER" <<<"$(evenement "$PROJET/pom.xml" '../x')"
  [ -z "$output" ]
  CAPIA_DESACTIVER=stack-java-spring run bash "$INJECTER" <<<"$(evenement "$PROJET/pom.xml")"
  [ -z "$output" ]
  echo '{"enabledPlugins":{"stack-java-spring@capitalisation-ia":true}}' > "$CLAUDE_CONFIG_DIR/settings.json"
  CLAUDE_PLUGIN_ROOT=/x/plugins/cache/capitalisation-ia-early/stack-java-spring/abc run bash "$INJECTER" <<<"$(evenement "$PROJET/pom.xml")"
  [ -z "$output" ]
  [ ! -d "$CLAUDE_CONFIG_DIR/capitalisation-ia/sessions" ]
}

@test "règles : aucun fichier écrit dans le projet, état hors projet" {
  git -C "$PROJET" init -q
  bash "$INJECTER" <<<"$(evenement "$PROJET/pom.xml")" >/dev/null
  [ -f "$CLAUDE_CONFIG_DIR/capitalisation-ia/sessions/session1/stack-java-spring--maven" ]
  [ "$(git -C "$PROJET" status --porcelain --ignored | wc -l)" -eq "$(git -C "$PROJET" status --porcelain | wc -l)" ]
  [ ! -e "$PROJET/.claude" ]
}

formatage() {
  jq -n --arg f "$1" '{hook_event_name: "PostToolUse", session_id: "s", tool_name: "Edit", tool_input: {file_path: $f}}' | bash "$FORMATER"
}

@test "formatage : google-java-format prioritaire" {
  outil_simule google-java-format
  outil_simule mvn
  run formatage "$PROJET/src/main/java/exemple/A.java"
  [ "$status" -eq 0 ]
  grep -qx "google-java-format --replace $PROJET/src/main/java/exemple/A.java" "$TRACE"
  run ! grep -q "^mvn" "$TRACE"
}

@test "formatage : Spotless Maven hors ligne, wrapper du projet prioritaire" {
  echo '<project><build><plugins><plugin><artifactId>spotless-maven-plugin</artifactId></plugin></plugins></build></project>' > "$PROJET/pom.xml"
  outil_simule mvn
  run formatage "$PROJET/src/main/java/exemple/A.java"
  grep -q '^mvn -q -o spotless:apply -DspotlessFiles=.\*src\[/\\\]main\[/\\\]java\[/\\\]exemple\[/\\\]A\\.java$' "$TRACE"
  printf '#!/usr/bin/env bash\necho "mvnw $*" >> "%s"\n' "$TRACE" > "$PROJET/mvnw"
  chmod +x "$PROJET/mvnw"
  run formatage "$PROJET/src/main/java/exemple/A.java"
  grep -q "^mvnw -q -o spotless:apply" "$TRACE"
}

@test "formatage : Spotless Gradle d'un module" {
  rm "$PROJET/pom.xml"
  mkdir -p "$PROJET/module/src/main/java"
  echo 'class B {}' > "$PROJET/module/src/main/java/B.java"
  echo 'plugins { id("com.diffplug.spotless") }' > "$PROJET/module/build.gradle.kts"
  outil_simule gradle
  run formatage "$PROJET/module/src/main/java/B.java"
  [ "$status" -eq 0 ]
  grep -qx "gradle -q --offline spotlessApply -PspotlessIdeHook=$PROJET/module/src/main/java/B.java" "$TRACE"
}

@test "formatage : sans effet hors Java, hors projet Maven ou Gradle, ou sans outil" {
  outil_simule google-java-format
  run formatage "$PROJET/a.ts"
  [ "$status" -eq 0 ]
  rm "$PROJET/pom.xml"
  run formatage "$PROJET/src/main/java/exemple/A.java"
  [ "$status" -eq 0 ]
  [ ! -e "$TRACE" ]
  echo '<project/>' > "$PROJET/pom.xml"
  rm "$OUTILS/google-java-format"
  run formatage "$PROJET/src/main/java/exemple/A.java"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "formatage : échec de l'outil sans interruption, message préfixé" {
  outil_simule google-java-format 'echo "erreur de syntaxe" >&2; exit 1'
  run --separate-stderr formatage "$PROJET/src/main/java/exemple/A.java"
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"[stack-java-spring google-java-format] erreur de syntaxe"* ]]
}

@test "formatage : coupe-circuit" {
  outil_simule google-java-format
  CAPIA_DESACTIVER=stack-java-spring run formatage "$PROJET/src/main/java/exemple/A.java"
  [ ! -e "$TRACE" ]
}
