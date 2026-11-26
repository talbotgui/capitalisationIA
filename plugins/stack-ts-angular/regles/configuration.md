---
paths:
  - "**/package.json"
  - "**/angular.json"
  - "**/tsconfig*.json"
  - "**/eslint.config.*"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude). -->

* Toute nouvelle dépendance est justifiée (besoin, licence, maintenance, taille) et soumise à l'utilisateur avant ajout ; dépendance de développement si elle ne sert qu'à la construction ou aux tests.
* Lockfile (package-lock.json, yarn.lock, pnpm-lock.yaml) toujours mis à jour et committé avec package.json ; installation reproductible par npm ci ou équivalent.
* Montée de version d'Angular par ng update, jamais par modification manuelle des versions ; ne pas mélanger des versions majeures de paquets @angular.
* Ne pas assouplir tsconfig (strict, options de vérification) ni la configuration ESLint ou des budgets de angular.json sans demande explicite.
