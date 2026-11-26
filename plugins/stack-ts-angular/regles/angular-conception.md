---
paths:
  - "**/*.service.ts"
  - "**/*.store.ts"
  - "**/*.routes.ts"
  - "**/*.guard.ts"
  - "**/*.resolver.ts"
  - "**/*.interceptor.ts"
  - "**/app.config.ts"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), adapté de affaan-m/ecc (rules/typescript et rules/angular, licence MIT, voir NOTICE.md). -->

* Les services portent l'accès aux données et la logique métier ; les composants délèguent. Services singletons (providedIn: 'root') sauf besoin d'une portée de composant ou de route (providers).
* Données asynchrones : resource() ou toSignal pour un chargement simple selon la version, RxJS pour les flux complexes ; toute souscription manuelle terminée par takeUntilDestroyed.
* Opérateurs RxJS choisis selon l'intention : switchMap (recherche, navigation), mergeMap (requêtes indépendantes), exhaustMap (soumission de formulaire) ; erreurs toujours traitées par catchError, jamais de flux qui s'arrête silencieusement.
* Routage : modules de fonctionnalité chargés à la demande (loadChildren, loadComponent) ; gardes et résolveurs fonctionnels (CanActivateFn, ResolveFn) ; canMatch plutôt que canActivate quand la route ne doit pas être chargée sans autorisation.
* Intercepteurs HTTP fonctionnels (HttpInterceptorFn) pour authentification, erreurs et nouvelles tentatives, déclarés dans provideHttpClient(withInterceptors(...)).
* Rendu côté serveur : jamais d'accès direct à window, document ou localStorage ; passer par isPlatformBrowser ou le jeton DOCUMENT.
* Accessibilité : composants accessibles du CDK Angular plutôt qu'une gestion manuelle des attributs ARIA.
