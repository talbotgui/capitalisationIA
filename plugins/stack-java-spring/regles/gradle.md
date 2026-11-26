---
paths:
  - "**/build.gradle"
  - "**/build.gradle.kts"
  - "**/settings.gradle"
  - "**/settings.gradle.kts"
  - "**/gradle/libs.versions.toml"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude). -->

* Versions centralisées dans le catalogue gradle/libs.versions.toml s'il existe, sinon dans la plateforme Spring Boot ; ne pas fixer une version déjà gérée.
* Toute nouvelle dépendance est justifiée (besoin, licence, maintenance) et soumise à l'utilisateur avant ajout ; configuration minimale (testImplementation, runtimeOnly).
* Aucune version dynamique (+, latest.release) ni dépôt ajouté sans accord.
* Utiliser le wrapper du projet (./gradlew) ; ne pas modifier gradle-wrapper.properties sans demande.
* Ne pas modifier la configuration des plugins de qualité (Spotless, Checkstyle, JaCoCo, seuils) sans demande explicite.
