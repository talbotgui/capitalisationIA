---
paths:
  - "**/package.json"
  - "**/angular.json"
  - "**/tsconfig*.json"
  - "**/eslint.config.*"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle d'Angular (angular.dev, CC BY 4.0) ; voir NOTICE.md. -->

* Toute nouvelle dépendance est justifiée (besoin, licence, maintenance, taille) et soumise à l'utilisateur avant ajout ; dépendance de développement si elle ne sert qu'à la construction ou aux tests.
* Lockfile (package-lock.json, yarn.lock, pnpm-lock.yaml) toujours mis à jour et committé avec package.json ; installation reproductible par npm ci ou équivalent.
* Angular maintenu à jour pour ses correctifs de sécurité ; montée de version par ng update, jamais par modification manuelle des versions ; ne pas mélanger des versions majeures de paquets @angular.
* Ne pas assouplir tsconfig (strict, options de vérification) ni la configuration ESLint ou des budgets de angular.json sans demande explicite ; ne jamais désactiver la compilation AOT ni la protection CSP (security.autoCsp) configurées.
