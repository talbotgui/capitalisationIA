---
paths:
  - "**/application*.yml"
  - "**/application*.yaml"
  - "**/application*.properties"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude). -->

* Aucun secret en clair : mots de passe, jetons et clés fournis par variables d'environnement ou gestionnaire de secrets (${NOM_VARIABLE}).
* Valeurs propres à un environnement dans des profils (application-<profil>.yml), jamais dans la configuration par défaut.
* Conserver le format existant (YAML ou properties) ; ne pas mélanger les deux pour un même module.
* Endpoints Actuator exposés au strict nécessaire (health, info) sauf demande explicite.
