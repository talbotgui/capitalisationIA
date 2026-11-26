#!/usr/bin/env bash
# Fichier généré avec l'assistance de l'IA (Claude).
#
# Fonctions du plugin regles-projets, à sourcer après lib/commun.sh.
#   regles_projet_dossier RACINE_PLUGIN DOSSIER_PROJET
#     nom du dossier de règles du projet (remote origin normalisé cherché dans projets/mapping.json),
#     vide si le projet est inconnu, sans remote ou si son dossier de règles est invalide.

regles_projet_dossier() {
  local racine_plugin="$1" projet="$2" url id dossier
  url="$(git -C "$projet" config --get remote.origin.url 2>/dev/null)" || return 0
  id="$(capia_normaliser_remote "$url")"
  [ -n "$id" ] || return 0
  dossier="$(jq -r --arg id "$id" 'first(.projets[] | select(.remotes | index($id)) | .dossier) // empty' \
    "$racine_plugin/projets/mapping.json" 2>/dev/null)"
  case "$dossier" in ""|_*|*[!a-z0-9._-]*|.*) return 0 ;; esac
  [ -f "$racine_plugin/projets/$dossier/index.md" ] || return 0
  printf '%s\n' "$dossier"
}
