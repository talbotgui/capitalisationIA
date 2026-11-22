<!-- Document généré avec l'assistance de l'IA (Claude), synthèse des règles versionnées de talbotgui/suiviProjets. -->

# Conception

* Interface : ecrans/, composants/, services/sansetat/{jugement,commandes}/ et services/avecetat/{campagne,etat,recherche}/ ; services/sansetat/commandes/ est la frontière unique vers invoke et ne dépend jamais de services/avecetat/.
* Cœur natif : commandes/, connecteurs/, persistance/, modele/ ; aucune dépendance circulaire entre couches.
* Moteur de jugement : fonctions pures, sans effet de bord ; aucun seuil codé en dur (lecture depuis parametres et referentiels).
* Chaque commande de la façade journalise son début et sa fin d'exécution.
* TypeScript : visibilité et types de retour explicites, JSDoc sur toute classe et méthode, aucune fonction hors classe, aucun any, aucune assertion non justifiée, toute Promise gérée.
* Rust : visibilité la plus restrictive, Rustdoc sur tout élément public, forbid(unsafe_code), jamais unwrap ni expect.
* Dates calendaires mises en forme par DateCalendaireUtils.formaterFr, jamais par Date ou DatePipe.
* Dépendances : lockfiles committés, installation par npm ci et cargo build --locked, toute nouvelle dépendance justifiée dans son commit.
