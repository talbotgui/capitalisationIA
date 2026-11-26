---
paths: "**/src-tauri/src/**/*.rs"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle de Tauri 2 (tauri-apps/tauri-docs) ; voir NOTICE.md. -->

* Frontière de confiance : le code Rust a accès à toutes les ressources du système, le frontal seulement à ce que l'IPC expose. Les capacités ne protègent ni d'un code Rust non sûr ni d'un contrôle de portée mal implémenté : toute donnée reçue d'une commande est validée et convertie en types valides dans la commande ; tout contrôle de portée écrit dans une commande est audité.
* Commandes (#[tauri::command]) minces, logique métier dans des modules testables sans Tauri ; noms uniques dans toute l'application (non préfixés par le module) ; commandes de lib.rs non pub, commandes d'un module dédié pub ; toutes déclarées dans un seul appel tauri::generate_handler!, invoke_handler n'étant appelé qu'une fois.
* Arguments : types implémentant serde::Deserialize ; clés en camelCase côté JavaScript par défaut (rename_all pour une autre convention), conformément à la convention du projet.
* Retour : tout ce qui est retourné implémente serde::Serialize, erreurs comprises ; type d'erreur dédié (thiserror) sérialisé avec un discriminant (kind) et un message exploitable par le frontal, sans détail interne, plutôt que map_err vers String ; jamais de panique dans une commande.
* Travail lourd dans une commande async (exécutée hors du fil principal ; une commande synchrone s'exécute sur le fil principal et fige l'interface) ; une commande async n'accepte pas d'argument emprunté (&str, State<'_, T>) sauf à retourner un Result : préférer les types possédés.
* Flux de données (progression, réponse en continu) par tauri::ipc::Channel ; événements (emit) réservés aux notifications simples, ni typés ni porteurs de retour.
* État partagé par Builder::manage et State<T>, sans Arc (Tauri l'ajoute) ; mutabilité par Mutex de la bibliothèque standard, Mutex asynchrone seulement si le verrou est conservé à travers un .await.
* Chemins de l'application par le résolveur de chemins (app.path() : app_data_dir, app_config_dir), jamais en dur ; tout chemin fourni par le frontal confiné au répertoire autorisé.
* Secrets jamais transmis au frontal ni stockés en clair : trousseau du système ou greffon stronghold.
* Tests : logique testée sans Tauri, intégration par le runtime simulé de Tauri (fonctionnalité test, tauri::test) ; côté frontal, IPC simulée par mockIPC de @tauri-apps/api/mocks et clearMocks après chaque test ; bout en bout par WebDriver (tauri-driver) si le projet l'utilise.
