---
paths:
  - "**/*.component.ts"
  - "**/*.component.html"
  - "**/*.service.ts"
  - "**/*.interceptor.ts"
  - "**/*.guard.ts"
  - "**/environments/*.ts"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), adapté de affaan-m/ecc (rules/typescript et rules/angular, licence MIT, voir NOTICE.md). -->

* Aucun secret dans le code ni dans les fichiers environment.ts versionnés (simple forme de configuration) ; secrets fournis par la chaîne de déploiement.
* Ne jamais contourner l'assainissement d'Angular (bypassSecurityTrust*) sans raison documentée et revue ; pas de [innerHTML] avec un contenu non fiable ; jamais de [href] lié à une saisie (URL javascript:) ; jamais de template construit à partir de données.
* HttpClient exclusivement (jamais fetch ni XHR) pour bénéficier des intercepteurs ; jeton d'authentification ajouté par intercepteur, jamais dans chaque appel ; réponses d'API traitées comme unknown à la frontière et validées.
* Aucune réponse HTTP pouvant contenir jeton, identifiant ou donnée personnelle dans les journaux.
* Toute route authentifiée ou réservée à un rôle protégée par une garde (canMatch pour les routes sensibles) : masquer un élément d'interface ne suffit pas.
* Politique de sécurité du contenu stricte, sans unsafe-inline dans script-src ; en rendu serveur, aucune variable serveur exposée par TransferState sans intention explicite.
