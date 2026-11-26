---
paths:
  - "**/tauri.conf.json"
  - "**/tauri.*.conf.json"
  - "**/Tauri.toml"
  - "**/src-tauri/capabilities/**"
  - "**/src-tauri/permissions/**"
  - "**/src-tauri/build.rs"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle de Tauri 2 (tauri-apps/tauri-docs) ; voir NOTICE.md. -->

* Moindre privilège : une capacité par fichier dans src-tauri/capabilities/ (toutes activées par défaut, sauf liste explicite dans app.security.capabilities) ; chaque capacité n'accorde que les permissions nécessaires, aux seules fenêtres concernées, désignées par leur label (jamais par leur titre), et aux seules plateformes visées.
* Par défaut, toutes les commandes de l'application sont accessibles à toutes les fenêtres : déclarer les commandes de l'application dans le manifeste (tauri_build::AppManifest dans build.rs) et les autoriser par des permissions, fenêtre par fenêtre.
* Création de fenêtres exposée aux seules fenêtres les plus privilégiées.
* Portées (scopes) les plus étroites possibles, deny prévalant sur allow ; jamais $HOME/** ni motif global pour fs, l'asset protocol (activé seulement si nécessaire, avec une portée explicite) ou les URL de http.
* Aucune permission d'exécution de commandes système ou de sidecar ni d'ouverture d'URL arbitraire sans besoin documenté et validé par l'utilisateur.
* API réservée par défaut au code embarqué : pas d'URL distante dans une capacité (remote) sauf décision explicite et commandes limitées.
* CSP active seulement si elle est définie dans la configuration : toujours la définir (app.security.csp), la plus restrictive possible, ressources limitées aux hôtes de confiance, idéalement possédés ; pas de script distant (CDN) ; Tauri ajoute lui-même nonces et empreintes ; 'wasm-unsafe-eval' seulement pour un frontal WebAssembly ; ne jamais la désactiver (csp: null).
* Distribution : binaires signés pour chaque plateforme ; mises à jour signées, clé publique configurée, vérification jamais désactivée.
* Serveur de développement seulement sur un réseau de confiance (pas d'authentification ni de chiffrement).
* Tauri, son CLI, @tauri-apps/api et les greffons maintenus à jour pour leurs correctifs de sécurité ; ne pas modifier l'identifiant de l'application (identifier), qui détermine les répertoires de données des utilisateurs.
* Toute modification de capacité, de permission ou de CSP est signalée explicitement à l'utilisateur dans la réponse.
