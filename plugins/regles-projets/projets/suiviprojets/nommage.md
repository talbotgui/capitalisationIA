<!-- Document généré avec l'assistance de l'IA (Claude), synthèse des règles versionnées de talbotgui/suiviProjets. -->

# Nommage

* Identifiants en français, sauf ceux imposés par une API externe.
* Rust : fichiers et fonctions en snake_case.
* Angular : fichiers et dossiers en kebab-case, composants en PascalCase avec préfixe applicatif (SqmFicheProjetComponent), services en PascalCase suffixés Service, variables et fonctions en camelCase.
* Commandes de la façade alignées une à une entre TypeScript (creerFichier) et Rust (creer_fichier) ; une commande non nommée par la conception l'est par symétrie avec ses voisines, choix signalé à l'humain.
* Gabarits nommés exemple-reference.* (Angular) ou exemple_reference.rs (Rust).
* Commits au format Conventional Commits (feat, fix, refactor, test, docs, chore, security), scope = module, corps citant l'US ou la RG, mention d'origine IA.
