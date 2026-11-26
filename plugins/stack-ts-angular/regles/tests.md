---
paths:
  - "**/*.spec.ts"
  - "**/*.test.ts"
  - "**/e2e/**/*.ts"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle d'Angular (angular.dev, CC BY 4.0) et affaan-m/ecc (rules/angular, MIT) ; voir NOTICE.md. -->

* Utiliser l'exécuteur configuré par le projet (angular.json, package.json) : Vitest avec jsdom par défaut pour les nouveaux projets CLI, Karma toujours pris en charge, Jest ; framework de bout en bout du projet (Playwright, Cypress). Ne pas en introduire un autre.
* Test unitaire à côté du code testé, même nom suffixé .spec.ts ; fournisseurs communs aux tests dans le fichier déclaré par providersFile ou setupFiles d'angular.json.
* Composants standalone importés directement dans TestBed.configureTestingModule ; entrées signal fixées par fixture.componentRef.setInput().
* Interactions par les harnesses du CDK plutôt que par requêtes DOM ; RouterTestingHarness pour ce qui dépend du routeur ; mode navigateur de Vitest pour les API propres au navigateur.
* HTTP simulé par provideHttpClient() et provideHttpClientTesting(), HttpTestingController vérifié après chaque test ; jamais d'appel réseau réel.
* Asynchrone maîtrisé (fakeAsync et tick, ou whenStable) ; données de test fixes et fictives.
* À tester : services (méthodes publiques, erreurs, échanges HTTP), composants (entrées, sorties, rendu des états clés, interactions), pipes en tests simples, gardes et résolveurs (cas autorisé et refusé). Tester le comportement, pas l'implémentation.
* Bout en bout : parcours critiques, sélecteurs par attributs dédiés (data-cy, data-testid), jamais par classe CSS ou texte.
* Couverture selon le seuil du projet (ng test --coverage), à défaut 80 % pour services et pipes ; lancer les tests concernés (ng test --no-watch ou commande du projet) et rapporter le résultat réel.
