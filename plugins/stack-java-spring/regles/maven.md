---
paths: "**/pom.xml"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude). -->

* Versions des dépendances gérées par le parent Spring Boot ou un BOM (dependencyManagement) ; ne pas fixer une version déjà gérée.
* Toute nouvelle dépendance est justifiée (besoin, licence, maintenance) et soumise à l'utilisateur avant ajout ; portée minimale (test, provided, runtime).
* Aucune version SNAPSHOT ni plage de versions ; aucun dépôt Maven ajouté sans accord.
* Utiliser le wrapper du projet (./mvnw) s'il existe.
* Ne pas modifier la configuration des plugins de qualité (Checkstyle, Spotless, JaCoCo, seuils) sans demande explicite.
