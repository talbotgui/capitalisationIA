---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
  - "**/*.cts"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), adapté de affaan-m/ecc (rules/typescript, MIT) et des bonnes pratiques officielles d'Angular (angular.dev, CC BY 4.0) ; voir NOTICE.md. -->

* Vérification de types stricte ; inférence quand le type est évident ; conventions du guide de style TypeScript de Google sauf convention contraire du projet.
* Types explicites (paramètres et retour) sur les fonctions exportées, utilitaires partagés et méthodes publiques ; inférence pour les variables locales évidentes ; formes d'objet répétées extraites en types nommés.
* interface pour les formes d'objet extensibles ou implémentées ; type pour les unions, intersections, tuples et types utilitaires ; unions de littéraux plutôt qu'enum, sauf interopérabilité.
* Jamais de any dans le code applicatif : unknown pour une donnée externe ou non fiable, puis rétrécissement sûr ; génériques quand le type dépend de l'appelant. Aucune assertion as ou ! non justifiée.
* Ne pas assouplir la configuration stricte du compilateur (strict, noImplicitAny, strictNullChecks) ni désactiver une règle ESLint sans demande.
* Immutabilité : mises à jour par copie (décomposition ...), Readonly et readonly sur les données partagées, jamais de mutation d'un paramètre.
* Asynchrone : async/await, toute Promise attendue ou explicitement gérée ; erreurs capturées typées unknown et rétrécies (instanceof Error) avant usage.
* Données externes validées par schéma à la frontière (Zod ou l'outil du projet), types inférés du schéma.
* Aucun console.log dans le code de production : utiliser le service de journalisation du projet.
* Vérifier après modification par la compilation (tsc --noEmit, ng build) et le linter du projet.
