---
paths:
  - "**/*.spec.ts"
  - "**/*.test.ts"
  - "**/e2e/**/*.ts"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), adapté de affaan-m/ecc (rules/typescript et rules/angular, licence MIT, voir NOTICE.md). -->

* Utiliser l'exécuteur de tests configuré par le projet (angular.json, package.json : Jest, Vitest ou Karma) et son framework de bout en bout (Playwright, Cypress) ; ne pas en introduire un autre.
* Composants standalone importés directement dans TestBed.configureTestingModule ; compileComponents() pour un template externe ; entrées signal fixées par fixture.componentRef.setInput().
* Interactions par les harnesses du CDK plutôt que par requêtes DOM ; RouterTestingHarness pour ce qui dépend du routeur.
* HTTP simulé par provideHttpClient() et provideHttpClientTesting(), HttpTestingController vérifié (verify) après chaque test ; jamais d'appel réseau réel.
* Asynchrone maîtrisé (fakeAsync et tick, ou whenStable) ; données de test fixes et fictives.
* À tester : services (méthodes publiques, chemins d'erreur, échanges HTTP), composants (entrées, sorties, rendu des états clés, interactions), pipes en tests unitaires simples, gardes et résolveurs (cas autorisé et refusé). Tester le comportement, pas l'implémentation.
* Bout en bout : parcours critiques uniquement, sélecteurs stables par attributs dédiés (data-cy, data-testid), jamais par classe CSS ou texte.
* Couverture selon le seuil du projet, à défaut 80 % pour services et pipes ; lancer les tests concernés (ng test --no-watch ou commande du projet) et rapporter le résultat réel.
