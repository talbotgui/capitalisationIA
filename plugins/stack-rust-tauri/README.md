# Plugin stack-rust-tauri

Document généré avec l'assistance de l'IA (Claude).

Règles de la stack Rust et Tauri. Dépend du plugin socle.

* Règles : à la première lecture ou modification, dans la session, d'un fichier concerné, Claude reçoit les règles correspondantes du dossier regles/ : développement et tests (.rs), conception et sécurité (src/**/*.rs), Cargo (Cargo.toml, rust-toolchain.toml, deny.toml), commandes Tauri (src-tauri/src/**/*.rs), configuration Tauri (tauri.conf.json, Tauri.toml, src-tauri/capabilities/). Rien n'est chargé sur un projet d'une autre stack.
* Les règles du projet (CLAUDE.md, règles versionnées, plugin regles-projets) prévalent sur celles de ce plugin.
* Formatage automatique : prévu en phase 5 du plan de démarrage, non inclus dans cette version.
* Coupe-circuit : CAPIA_DESACTIVER=stack-rust-tauri. Le hook n'écrit rien dans le projet.
* Sources : règles Rust adaptées de affaan-m/ecc (licence MIT, voir NOTICE.md) ; règles Tauri rédigées d'après les conventions de Tauri 2, ecc n'en contenant pas.
