# Plugin stack-ts-angular

Document généré avec l'assistance de l'IA (Claude).

Règles de la stack TypeScript et Angular. Dépend du plugin socle.

* Règles : à la première lecture ou modification, dans la session, d'un fichier concerné, Claude reçoit les règles correspondantes du dossier regles/ : TypeScript (.ts, .tsx), composants, conception et sécurité Angular (fichiers .ts et .html de src/app et de projects/*/src, ou suffixés .component, pour couvrir les projets avec ou sans suffixes de fichiers), sécurité des environnements et du serveur (environments/, server.ts), tests (*.spec.ts, *.test.ts, e2e/), configuration (package.json, angular.json, tsconfig, ESLint). Rien n'est chargé sur un projet d'une autre stack.
* Les règles du projet (CLAUDE.md, règles versionnées, plugin regles-projets) prévalent sur celles de ce plugin, et le style déjà en place dans le projet prévaut sur les recommandations dépendant de la version d'Angular.
* Formatage automatique : prévu en phase 5 du plan de démarrage, non inclus dans cette version.
* Coupe-circuit : CAPIA_DESACTIVER=stack-ts-angular. Le hook n'écrit rien dans le projet.
* Sources : documentation officielle d'Angular (angular.dev, CC BY 4.0) et affaan-m/ecc (licence MIT), voir NOTICE.md. Les règles dépendant de la version (OnPush implicite et @Service en v22, standalone implicite depuis la v20) le précisent.
