---
paths:
  - "**/src/app/**/*.ts"
  - "**/projects/*/src/**/*.ts"
  - "**/*.component.ts"
  - "**/src/app/**/*.html"
  - "**/projects/*/src/**/*.html"
  - "**/*.component.html"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle d'Angular (angular.dev, CC BY 4.0) et affaan-m/ecc (rules/angular, MIT) ; voir NOTICE.md. -->

* Vérifier la version d'Angular du projet (package.json) : plusieurs règles en dépendent. En cas de doute, la cohérence avec le style du fichier existant prime (guide de style officiel).
* Nommage : mots séparés par des tirets, même nom pour le TypeScript, le template et les styles d'un composant (user-profile.ts, .html, .css), test à côté du code (user-profile.spec.ts). Le guide actuel n'utilise plus de suffixe (.component) : suivre la convention déjà en place dans le projet. Pas de fichier générique (utils.ts, helpers.ts).
* Organisation par fonctionnalité, jamais par type (pas de dossiers components/, services/) ; un concept par fichier ; logique dans le .ts, template dans le .html, styles dans le .css (template intégré admis pour un petit composant).
* Composants standalone, sans écrire standalone: true (défaut depuis la v20) ; OnPush pour tout nouveau composant, explicite avant la v22, implicite à partir de la v22 (ne plus l'écrire).
* API de composant par fonctions : input(), output(), model() pour la liaison bidirectionnelle, requêtes par fonctions ; propriétés initialisées par Angular en readonly ; membres utilisés seulement par le template en protected ; propriétés Angular (injections, entrées, sorties, requêtes) regroupées avant les méthodes.
* Liaisons d'hôte dans l'objet host du décorateur, jamais @HostBinding ni @HostListener.
* Signals : signal pour l'état local, computed pour l'état dérivé, linkedSignal pour un état dérivé modifiable ; set ou update, jamais mutate ; effect réservé aux effets de bord, jamais pour synchroniser des signals.
* Templates : contrôle de flux natif (@if, @for avec track, @switch) au lieu de *ngIf, *ngFor, *ngSwitch ; logique complexe déplacée dans un computed ; liaisons class et style au lieu de ngClass et ngStyle ; pipe async pour les observables ; aucun global (new Date()) supposé disponible.
* Ne pas importer CommonModule : importer uniquement les directives et pipes utilisés par le template.
* Composants centrés sur la présentation : validation, transformations et accès aux données hors du composant ; jamais de HttpClient dans un composant.
* Gestionnaires d'événements nommés selon ce qu'ils font (enregistrerProfil), pas selon l'événement ; méthodes de cycle de vie courtes appelant des méthodes nommées, interfaces (OnInit...) implémentées.
* Formulaires : Signal Forms (@angular/forms/signals, stables en v22) pour les nouveaux formulaires, sinon Reactive Forms plutôt que template-driven, en suivant la stratégie du projet.
* NgOptimizedImage pour les images statiques (hors images base64 intégrées) ; accessibilité : contrôles AXE sans erreur, minimums WCAG AA (focus, contrastes, attributs ARIA), composants accessibles du CDK.
