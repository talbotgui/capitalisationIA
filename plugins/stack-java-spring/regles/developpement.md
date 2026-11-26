---
paths: "**/*.java"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle de Spring Boot et de JUnit et affaan-m/ecc (rules/java) ; voir NOTICE.md. -->

* Respecter la version de Java déclarée par le projet (maven.compiler.release, toolchain Gradle) ; utiliser ses fonctionnalités modernes quand elles clarifient le code : records pour les données, classes sealed pour les hiérarchies fermées, pattern matching (instanceof, switch exhaustif), switch expressions, text blocks.
* Conventions de nommage Java : PascalCase pour les types, camelCase pour méthodes, champs et variables, MAJUSCULES_SOULIGNEES pour les constantes static final, paquets en minuscules ; la langue des identifiants suit celle du code existant.
* Un type public de premier niveau par fichier ; ordre des membres : constantes, champs, constructeurs, méthodes publiques, protégées, privées.
* Immutabilité par défaut : champs private final, pas de setter inutile, copies défensives dans les API publiques (List.copyOf, Map.copyOf, Set.copyOf), nouvelles instances plutôt que mutation.
* Optional uniquement en retour d'une recherche pouvant être vide, exploité par map, flatMap, orElseThrow ; jamais get() sans contrôle, jamais en paramètre ni en champ ; jamais de null retourné pour une collection.
* Exceptions : exceptions métier non vérifiées, spécifiques et porteuses de contexte (identifiant concerné) ; jamais de catch vide ; catch (Exception) réservé aux gestionnaires de plus haut niveau.
* Streams courts (trois ou quatre opérations), sans effet de bord, références de méthode quand elles sont lisibles ; une boucle plutôt qu'un pipeline alambiqué.
* Ressources fermées par try-with-resources ; journalisation SLF4J à messages paramétrés ({}), jamais System.out ni printStackTrace.
* Pas de code mort, d'import inutilisé ni de commentaire paraphrasant le code ; Javadoc sur les API publiques.
* Le formatage est appliqué automatiquement après modification si l'outil du projet est disponible : ne pas reformater manuellement le reste du fichier. Vérifier la compilation après modification (./mvnw -q compile, ./gradlew compileJava).
