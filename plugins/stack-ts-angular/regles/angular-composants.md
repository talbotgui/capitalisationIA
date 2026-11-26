---
paths:
  - "**/*.component.ts"
  - "**/*.component.html"
  - "**/*.directive.ts"
  - "**/*.pipe.ts"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), adapté de affaan-m/ecc (rules/typescript et rules/angular, licence MIT, voir NOTICE.md). -->

* Vérifier la version d'Angular du projet (package.json) avant d'écrire du code : les fonctionnalités ci-dessous dépendent de la version, et le style déjà en place dans le projet prévaut.
* Conventions du CLI : un artefact par fichier (user-card.component.ts, .html, .spec.ts), dossiers par fonctionnalité ; générer avec ng generate.
* Composants standalone (par défaut depuis la v17) en ChangeDetectionStrategy.OnPush pour tout nouveau composant ; entrées et sorties par input(), input.required(), output() quand la version le permet.
* Injection par inject() plutôt que par constructeur dans le nouveau code ; InjectionToken pour les dépendances qui ne sont pas des classes.
* Signals : signal pour l'état local, computed pour toute valeur dérivée (jamais dupliquée dans un autre signal), linkedSignal pour un état dérivé modifiable ; effect réservé aux effets de bord, jamais pour synchroniser des signals.
* Templates : syntaxe de blocs (@if, @for, @switch), track obligatoire dans @for ; aucune logique au-delà de conditions simples, déplacée dans le composant ou un pipe.
* Composant de présentation : entrées et sorties uniquement, sans service injecté ; le composant conteneur porte données et état. Jamais de HttpClient dans un composant.
* Styles encapsulés (ViewEncapsulation.Emulated), :host pour l'élément hôte, propriétés CSS personnalisées pour les valeurs thématisables ; pas de ViewEncapsulation.None hors système de design.
* OnPush : ne jamais muter un objet reçu en entrée ; éviter markForCheck et detectChanges, laisser signals et pipe async déclencher la détection.
* Formulaires : suivre la stratégie du projet (Signal Forms en v21+, sinon Reactive Forms pour les formulaires complexes, ngModel pour les simples seulement).
