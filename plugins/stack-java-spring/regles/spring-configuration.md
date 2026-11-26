---
paths:
  - "**/application*.yml"
  - "**/application*.yaml"
  - "**/application*.properties"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle de Spring Boot et de JUnit et affaan-m/ecc (rules/java) ; voir NOTICE.md. -->

* Aucun secret en clair : mots de passe, jetons et clés fournis par variables d'environnement ou gestionnaire de secrets (${NOM_VARIABLE}).
* Valeurs propres à un environnement dans des profils (application-<profil>.yml), jamais dans la configuration par défaut.
* Un seul format (YAML ou properties) pour toute l'application, celui déjà en place ; clés en forme canonique (kebab-case en minuscules), y compris dans les @Value("${...}").
* Actuator : seul health est exposé par défaut ; n'exposer un autre endpoint (management.endpoints.web.exposure.include) que s'il ne contient pas d'information sensible ou s'il est protégé (Spring Security, réseau interne), et jamais * sans demande explicite.
