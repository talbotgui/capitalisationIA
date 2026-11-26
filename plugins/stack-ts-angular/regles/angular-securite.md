---
paths:
  - "**/src/app/**/*.ts"
  - "**/projects/*/src/**/*.ts"
  - "**/*.component.ts"
  - "**/src/app/**/*.html"
  - "**/*.component.html"
  - "**/environments/*.ts"
  - "**/server.ts"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle d'Angular (angular.dev, CC BY 4.0) et affaan-m/ecc (rules/angular, MIT) ; voir NOTICE.md. -->

* Toute valeur est non fiable par défaut et assainie par Angular dans les liaisons ; le template, lui, est du code exécutable : ne jamais construire de template à partir de données, ne jamais compiler de template dynamique (compilateur AOT en production).
* API marquées « Security Risk » à éviter : bypassSecurityTrust* seulement pour une valeur inspectée et sûre, avec raison documentée et revue de sécurité ; pas de [innerHTML] avec un contenu non fiable ; jamais de [href] lié à une saisie.
* Éviter la manipulation directe du DOM (ElementRef.nativeElement, document, bibliothèques DOM) ; si elle est inévitable, assainir par DomSanitizer.sanitize avec le SecurityContext adapté.
* Politique de sécurité du contenu stricte : nonce aléatoire par réponse transmis à Angular (ngCspNonce ou CSP_NONCE), ou autoCsp en hébergement statique ; pas de unsafe-inline dans script-src ; Trusted Types recommandés.
* HttpClient exclusivement (intercepteurs) ; protection XSRF intégrée conservée (jamais withNoXsrfProtection sans raison documentée), le serveur devant poser le cookie et vérifier l'en-tête ; nom de cookie propre à l'application si plusieurs partagent le domaine.
* Jeton d'authentification ajouté par intercepteur ; réponses d'API traitées comme unknown et validées ; aucun jeton, identifiant ou donnée personnelle dans les journaux.
* Aucun secret dans le code ni dans les environment.ts versionnés ; secrets fournis par la chaîne de déploiement.
* Route authentifiée ou réservée à un rôle protégée par une garde (canMatch pour les routes sensibles) : masquer un élément d'interface ne suffit pas.
* Rendu serveur : ne jamais générer de template Angular côté serveur ; en-têtes de mandataire (X-Forwarded-*) conservés seulement par trustProxyHeaders et hôtes autorisés configurés ; aucune variable serveur exposée par TransferState sans intention explicite.
* Maintenir Angular à jour (correctifs de sécurité) et ne jamais modifier sa copie d'Angular.
