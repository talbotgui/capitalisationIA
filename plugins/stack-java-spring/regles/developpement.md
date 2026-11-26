---
paths: "**/*.java"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude). -->

* Respecter la version de Java déclarée par le projet (maven.compiler.release, toolchain Gradle) ; ne pas utiliser de fonctionnalité plus récente.
* Classes, méthodes et variables nommées selon les conventions Java (PascalCase, camelCase, constantes en MAJUSCULES) ; la langue des identifiants suit celle du code existant.
* Visibilité la plus restreinte possible ; champs private et final par défaut ; préférer les records et les objets immuables pour les données.
* Jamais de null retourné pour une collection (collection vide) ; Optional uniquement en type de retour, jamais en paramètre ni en champ.
* Exceptions : ne jamais avaler une exception (catch vide), ne pas capturer Exception ou Throwable sans la relancer ; exceptions métier non vérifiées et explicites.
* Ressources fermées par try-with-resources.
* Journalisation par SLF4J, messages paramétrés ({}), jamais de System.out ni de printStackTrace ; aucune donnée sensible dans les journaux.
* Pas de code mort, d'import inutilisé ni de commentaire paraphrasant le code ; Javadoc sur les API publiques.
* Le formatage est appliqué automatiquement après modification si l'outil du projet est disponible : ne pas reformater manuellement le reste du fichier.
