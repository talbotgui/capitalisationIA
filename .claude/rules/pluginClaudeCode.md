# Règles de développement des plugins Claude Code

Fichier généré avec l'assistance de l'IA (Claude).

## Contrôle systématique en fin de développement

À la fin de chaque sujet de développement, avant de le déclarer terminé, vérifier pour chaque plugin modifié (tout fichier sous plugins/<plugin>/) :

1. CHANGELOG enrichi : plugins/<plugin>/CHANGELOG.md décrit les changements du sujet dans une section « ## x.y.z ».
   * Si la section la plus récente correspond à une version déjà publiée (tag <plugin>--vx.y.z existant), créer en tête une nouvelle section avec la version suivante : correctif → patch, ajout compatible → mineure, rupture → majeure.
   * Sinon (version non encore publiée), compléter cette section.
   * Sections de la plus récente à la plus ancienne, une ligne par changement, rédigées pour l'utilisateur du plugin.
2. README du plugin à jour si le comportement visible change.
3. Aucun champ version dans plugin.json.
4. Nouveau plugin : entrée ajoutée au catalogue early access (source git-subdir, ref main, sans version).
5. Contrôles verts : shellcheck, claude plugin validate (plugin et catalogues), outils/verifier-coherence.sh, bats tests/.

Indiquer dans la réponse de fin de sujet la version de CHANGELOG concernée par plugin, ou l'absence de plugin modifié.
