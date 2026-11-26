---
paths:
  - "**/src/app/**/*.ts"
  - "**/projects/*/src/**/*.ts"
  - "**/*.component.ts"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle d'Angular (angular.dev, CC BY 4.0) et affaan-m/ecc (rules/angular, MIT) ; voir NOTICE.md. -->

* Services à responsabilité unique, portant l'accès aux données et la logique métier ; les composants délèguent.
* Injection par la fonction inject() plutôt que par paramètres de constructeur (guide de style officiel) ; InjectionToken pour les dépendances qui ne sont pas des classes ; portée de composant ou de route (providers) seulement si le service ne doit pas être un singleton.
* Nouveau service singleton : décorateur @Service à partir de la v22, @Injectable({ providedIn: 'root' }) avant.
* Données asynchrones : resource() ou toSignal pour un chargement simple selon la version, RxJS pour les flux complexes ; souscription manuelle terminée par takeUntilDestroyed.
* Opérateurs RxJS choisis selon l'intention : switchMap (recherche, navigation), mergeMap (requêtes indépendantes), exhaustMap (soumission) ; erreurs toujours traitées par catchError.
* Routage : routes de fonctionnalité chargées à la demande (loadChildren, loadComponent) ; gardes, résolveurs et intercepteurs fonctionnels (CanActivateFn, ResolveFn, HttpInterceptorFn) ; canMatch quand la route ne doit pas être chargée sans autorisation.
* Transformations d'état pures et prévisibles ; règles de validation et transformations de données dans des fonctions ou classes dédiées, testables sans composant.
* Rendu côté serveur : jamais d'accès direct à window, document ou localStorage ; passer par isPlatformBrowser ou le jeton DOCUMENT.
