#!/usr/bin/env bats
# Fichier généré avec l'assistance de l'IA (Claude).
# Tests du plugin socle : bibliothèque commune, journal des prompts et purge.

bats_require_minimum_version 1.5.0

load aide

SOCLE="$RACINE_DEPOT/plugins/socle"
JOURNALISER="$SOCLE/scripts/journaliser-prompt.sh"
PURGER="$SOCLE/scripts/purger-journaux.sh"

setup() {
  export CLAUDE_CONFIG_DIR="$BATS_TEST_TMPDIR/config"
  mkdir -p "$CLAUDE_CONFIG_DIR"
  unset CAPIA_DESACTIVER CAPIA_RETENTION_JOURS CLAUDE_PLUGIN_ROOT
  PROJET="$BATS_TEST_TMPDIR/projet"
  mkdir -p "$PROJET"
  git -C "$PROJET" init -q
  git -C "$PROJET" remote add origin git@github.com:Exemple/Projet.git
  export CLAUDE_PROJECT_DIR="$PROJET"
  JOURNAL="$CLAUDE_CONFIG_DIR/capitalisation-ia/journaux/github.com/exemple/projet/prompts.log"
  # shellcheck source=/dev/null
  . "$SOCLE/lib/commun.sh"
}

prompt() {
  jq -n --arg p "$1" '{hook_event_name: "UserPromptSubmit", prompt: $p}'
}

@test "normalisation : formes ssh, scp et https" {
  [ "$(capia_normaliser_remote git@github.com:Talbotgui/CapitalisationIA.git)" = "github.com/talbotgui/capitalisationia" ]
  [ "$(capia_normaliser_remote ssh://git@gitlab.exemple.fr:2222/equipe/depot.git)" = "gitlab.exemple.fr/equipe/depot" ]
  [ "$(capia_normaliser_remote https://github.com/talbotgui/capitalisationIA)" = "github.com/talbotgui/capitalisationia" ]
  [ "$(capia_normaliser_remote https://github.com/talbotgui/capitalisationIA.git/)" = "github.com/talbotgui/capitalisationia" ]
}

@test "normalisation : identifiants et port supprimés" {
  [ "$(capia_normaliser_remote https://utilisateur:jeton@git.exemple.fr:8443/equipe/depot.git)" = "git.exemple.fr/equipe/depot" ]
}

@test "normalisation : formes non reconnues ou dangereuses rejetées" {
  [ -z "$(capia_normaliser_remote /chemin/local/depot)" ]
  [ -z "$(capia_normaliser_remote https://hote/un/deux/trois)" ]
  [ -z "$(capia_normaliser_remote https://hote/../depot)" ]
  [ -z "$(capia_normaliser_remote https://hote/seul)" ]
}

@test "identifiant de repli sans remote" {
  local d="$BATS_TEST_TMPDIR/Mon Depot"
  mkdir -p "$d" && git -C "$d" init -q
  [ "$(capia_identifiant_projet "$d")" = "sans-remote/mon_depot" ]
}

@test "coupe-circuit : global, liste et autre plugin" {
  CAPIA_DESACTIVER=1 capia_desactive socle
  CAPIA_DESACTIVER="stack-rust, socle" capia_desactive socle
  CAPIA_DESACTIVER=stack-rust run ! capia_desactive socle
  run ! capia_desactive socle
}

@test "canal actif : l'instance early s'efface si le canal stable est actif" {
  echo '{"enabledPlugins":{"socle@capitalisation-ia":true,"socle@capitalisation-ia-early":true}}' > "$CLAUDE_CONFIG_DIR/settings.json"
  CLAUDE_PLUGIN_ROOT=/x/plugins/cache/capitalisation-ia-early/socle/abc run ! capia_instance_active socle
  CLAUDE_PLUGIN_ROOT=/x/plugins/cache/capitalisation-ia/socle/1.0.0 capia_instance_active socle
  echo '{"enabledPlugins":{"socle@capitalisation-ia-early":true}}' > "$CLAUDE_CONFIG_DIR/settings.json"
  CLAUDE_PLUGIN_ROOT=/x/plugins/cache/capitalisation-ia-early/socle/abc capia_instance_active socle
}

@test "journal : prompt consigné hors du projet avec les bons droits" {
  run bash "$JOURNALISER" <<<"$(prompt "Bonjour
sur deux lignes")"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ -f "$JOURNAL" ]
  grep -Eq '^\[[0-9]{4}-[0-9]{2}-[0-9]{2}T' "$JOURNAL"
  grep -qx "sur deux lignes" "$JOURNAL"
  [ "$(tail -n 1 "$JOURNAL")" = "---" ]
  [ "$(stat -c %a "$JOURNAL")" = "600" ]
  [ "$(stat -c %a "$(dirname "$JOURNAL")")" = "700" ]
  [ -z "$(git -C "$PROJET" status --porcelain --ignored)" ]
  [ "$(find "$PROJET" -mindepth 1 -not -path "$PROJET/.git*" | wc -l)" -eq 0 ]
}

@test "journal : coupe-circuit respecté" {
  CAPIA_DESACTIVER=socle run bash "$JOURNALISER" <<<"$(prompt "Bonjour")"
  [ "$status" -eq 0 ]
  [ ! -e "$JOURNAL" ]
}

@test "journal : instance early inactive si le canal stable est actif" {
  echo '{"enabledPlugins":{"socle@capitalisation-ia":true,"socle@capitalisation-ia-early":true}}' > "$CLAUDE_CONFIG_DIR/settings.json"
  CLAUDE_PLUGIN_ROOT=/x/plugins/cache/capitalisation-ia-early/socle/abc run bash "$JOURNALISER" <<<"$(prompt "Bonjour")"
  [ "$status" -eq 0 ]
  [ ! -e "$JOURNAL" ]
}

@test "journal : entrée invalide ignorée, code 0" {
  run bash "$JOURNALISER" <<<"pas du json"
  [ "$status" -eq 0 ]
  [ ! -e "$JOURNAL" ]
}

@test "purge : entrées anciennes supprimées, récentes conservées" {
  mkdir -p "$(dirname "$JOURNAL")"
  {
    printf '[%sT10:00:00+01:00]\nancien\n---\n' "$(date -d '-120 days' +%F)"
    printf '[%sT10:00:00+01:00]\nrecent\n---\n' "$(date -d '-10 days' +%F)"
  } > "$JOURNAL"
  chmod 600 "$JOURNAL"
  run bash "$PURGER"
  [ "$status" -eq 0 ]
  run ! grep -q ancien "$JOURNAL"
  grep -q recent "$JOURNAL"
  [ "$(stat -c %a "$JOURNAL")" = "600" ]
}

@test "purge : journal entièrement ancien supprimé, rétention paramétrable" {
  mkdir -p "$(dirname "$JOURNAL")"
  printf '[%sT10:00:00+01:00]\nmoyen\n---\n' "$(date -d '-20 days' +%F)" > "$JOURNAL"
  CAPIA_RETENTION_JOURS=30 run bash "$PURGER"
  [ -f "$JOURNAL" ]
  CAPIA_RETENTION_JOURS=15 run bash "$PURGER"
  [ "$status" -eq 0 ]
  [ ! -e "$JOURNAL" ]
}

@test "moteur de règles : motifs de chemin" {
  local r
  r="$(capia_glob_vers_regex '**/*.java')"
  grep -Eq "$r" <<<"A.java"
  grep -Eq "$r" <<<"src/main/java/A.java"
  run ! grep -Eq "$r" <<<"A.javax"
  r="$(capia_glob_vers_regex 'src/**/*Test.java')"
  grep -Eq "$r" <<<"src/FooTest.java"
  run ! grep -Eq "$r" <<<"lib/src/FooTest.java"
  r="$(capia_glob_vers_regex 'build.gradle{,.kts}')"
  grep -Eq "$r" <<<"build.gradle.kts"
  run ! grep -Eq "$r" <<<"build.gradleXkts"
  r="$(capia_glob_vers_regex '*.md')"
  grep -Eq "$r" <<<"README.md"
  run ! grep -Eq "$r" <<<"docs/a.md"
}

@test "moteur de règles : en-tête paths en chaîne, en liste, ou absent" {
  printf -- '---\npaths: "a/*.x, **/b.y"\n---\ncorps\n' > "$BATS_TEST_TMPDIR/r1.md"
  [ "$(capia_motifs_regle "$BATS_TEST_TMPDIR/r1.md" | paste -sd'|')" = 'a/*.x|**/b.y' ]
  printf -- '---\ndescription: x\npaths:\n  - "**/*.java"\n  - pom.xml\nautre: y\n---\ncorps\n' > "$BATS_TEST_TMPDIR/r2.md"
  [ "$(capia_motifs_regle "$BATS_TEST_TMPDIR/r2.md" | paste -sd'|')" = '**/*.java|pom.xml' ]
  [ "$(capia_corps_regle "$BATS_TEST_TMPDIR/r2.md")" = "corps" ]
  printf '# Sans en-tête\n' > "$BATS_TEST_TMPDIR/r3.md"
  [ -z "$(capia_motifs_regle "$BATS_TEST_TMPDIR/r3.md")" ]
}

@test "purge : états de session de plus de 7 jours supprimés" {
  local s="$CLAUDE_CONFIG_DIR/capitalisation-ia/sessions"
  mkdir -p "$s/ancienne" "$s/recente"
  touch -d '-10 days' "$s/ancienne"
  run bash "$PURGER"
  [ "$status" -eq 0 ]
  [ ! -e "$s/ancienne" ]
  [ -d "$s/recente" ]
}
