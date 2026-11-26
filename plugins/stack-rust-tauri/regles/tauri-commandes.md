---
paths: "**/src-tauri/src/**/*.rs"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après les conventions de Tauri 2 (aucune règle Tauri dans affaan-m/ecc). -->

* Toute donnée reçue du frontal par une commande est non fiable : arguments validés et convertis en types valides dans la commande, comme une entrée réseau.
* Commandes (#[tauri::command]) minces : logique métier dans des modules testables sans Tauri ; commandes déclarées dans un seul generate_handler!.
* Retour Result<T, E> avec un type d'erreur dédié implémentant serde::Serialize (thiserror) et des messages exploitables par le frontal, sans détail interne ; jamais de panique (unwrap, expect) dans une commande.
* Travail long ou bloquant dans une commande async ou spawn_blocking, jamais sur le fil principal ; progression remontée par événements (emit) ou canaux (Channel).
* État partagé par app.manage() et State<'_, T>, protégé par Mutex ou RwLock ; aucun verrou std conservé à travers un .await.
* Chemins de l'application obtenus par le résolveur de chemins (app.path() : app_data_dir, app_config_dir), jamais en dur ; tout chemin fourni par le frontal confiné au répertoire autorisé.
* Secrets jamais transmis au frontal ni stockés en clair : trousseau du système ou greffon stronghold.
* Commandes nommées de façon cohérente entre Rust (snake_case) et le frontal (camelCase), appelées côté frontal depuis un module unique et typé encapsulant invoke.
