<!-- Document généré avec l'assistance de l'IA (Claude), synthèse des règles versionnées de talbotgui/suiviProjets. -->

# Tests

* Frameworks : cargo test (Rust), Jest (TypeScript, jamais Karma ni Jasmine), Playwright contre ng serve avec façade bouchonnée (bout en bout).
* Couverture : 90 % pour le moteur de jugement, 80 % pour le reste du cœur natif ; composants graphiques suivis par le nombre de méthodes jamais appelées.
* Connecteurs et persistance testés sans réseau ni disque réels ; la façade de commandes n'est jamais testée isolément.
* En CI, uniquement des réponses HTTP simulées, chaque catégorie d'anomalie RG-021 testée ; tests contre de vraies instances marqués ignore et lancés à la main.
* Données de test exclusivement fictives, valeurs fixes et jamais aléatoires.
