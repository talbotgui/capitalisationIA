# Plugin stack-ts-angular

Document généré avec l'assistance de l'IA (Claude).

Règles de la stack TypeScript et Angular. Dépend du plugin socle.

* Règles : à la première lecture ou modification, dans la session, d'un fichier concerné, Claude reçoit les règles correspondantes du dossier regles/ : TypeScript (.ts, .tsx), composants Angular (*.component.ts et .html, directives, pipes), conception Angular (services, stores, routes, gardes, résolveurs, intercepteurs), sécurité (composants, services, intercepteurs, environnements), tests (*.spec.ts, *.test.ts, e2e/), configuration (package.json, angular.json, tsconfig, ESLint). Rien n'est chargé sur un projet d'une autre stack.
* Les règles du projet (CLAUDE.md, règles versionnées, plugin regles-projets) prévalent sur celles de ce plugin, et le style déjà en place dans le projet prévaut sur les recommandations dépendant de la version d'Angular.
* Formatage automatique : prévu en phase 5 du plan de démarrage, non inclus dans cette version.
* Coupe-circuit : CAPIA_DESACTIVER=stack-ts-angular. Le hook n'écrit rien dans le projet.
* Sources : règles adaptées de affaan-m/ecc (licence MIT, voir NOTICE.md).
