---
paths:
  - "**/tauri.conf.json"
  - "**/tauri.*.conf.json"
  - "**/Tauri.toml"
  - "**/src-tauri/capabilities/**"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après les conventions de Tauri 2 (aucune règle Tauri dans affaan-m/ecc). -->

* Moindre privilège : chaque capacité (capabilities/) n'accorde que les permissions nécessaires, aux seules fenêtres concernées ; portées (scopes) de fichiers et d'URL les plus étroites possibles, jamais $HOME/** ni de motif global.
* Aucune permission d'exécution de commandes système (shell:allow-execute, spawn) ni d'ouverture d'URL arbitraire sans besoin documenté et validé par l'utilisateur.
* Aucun contenu distant n'accède à l'IPC : pas de domaine distant dans les capacités sauf décision explicite.
* Politique de sécurité du contenu (app.security.csp) stricte : pas de unsafe-eval ni unsafe-inline dans script-src, connect-src limité aux hôtes nécessaires ; ne jamais la désactiver (csp: null).
* Mise à jour automatique : artefacts signés, clé publique configurée ; ne jamais désactiver la vérification de signature.
* Ne pas modifier l'identifiant de l'application (identifier), qui détermine les répertoires de données des utilisateurs.
* Toute modification de capacité ou de CSP est signalée explicitement à l'utilisateur dans la réponse.
