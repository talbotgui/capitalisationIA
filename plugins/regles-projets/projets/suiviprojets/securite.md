<!-- Document généré avec l'assistance de l'IA (Claude), synthèse des règles versionnées de talbotgui/suiviProjets. -->

# Sécurité

* Aucun secret persisté sur disque : identifiants GitLab et Sonar en mémoire volatile uniquement, mot de passe du fichier jamais stocké.
* Identifiants transmis uniquement en en-tête HTTP, jamais en paramètre d'URL ; aucun secret dans un prompt ni dans l'historique git.
* Toute donnée saisie validée côté interface et revalidée côté cœur natif ; réponses d'API désérialisées avec typage strict.
* Aucune injection HTML dynamique ; tout innerHTML ou bypassSecurityTrust soumis à revue ; CSP stricte sans unsafe-inline ni eval.
* Aucune donnée sensible dans un journal ; journaux strictement locaux, aucune télémétrie.
* cargo audit et npm audit avant toute publication ; exceptions documentées dans audit-exceptions.json.
