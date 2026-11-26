# Plugin stack-java-spring

Document généré avec l'assistance de l'IA (Claude).

Règles et outillage de la stack Java et Spring Boot. Dépend du plugin socle.

* Règles : à la première lecture ou modification, dans la session, d'un fichier concerné, Claude reçoit les règles correspondantes du dossier regles/ : développement et conception (fichiers .java), tests (src/test, *Test.java, *IT.java), Maven (pom.xml), Gradle (build.gradle, settings.gradle, libs.versions.toml), configuration Spring (application*.yml, application*.properties). Rien n'est chargé sur un projet d'une autre stack. Après un /clear ou un compactage, les règles sont de nouveau transmises au besoin.
* Formatage : après chaque modification d'un fichier .java d'un projet Maven ou Gradle, le fichier est formaté avec google-java-format s'il est dans le PATH, sinon avec le plugin Spotless du projet (mvnw ou mvn spotless:apply, gradlew ou gradle spotlessApply), hors ligne. Aucun outil disponible : aucun effet. Délai maximal 50 secondes (variable CAPIA_JAVA_DELAI).
* Les règles du projet (CLAUDE.md, règles versionnées, plugin regles-projets) prévalent sur celles de ce plugin.
* Coupe-circuit : CAPIA_DESACTIVER=stack-java-spring. Les hooks n'écrivent rien dans le projet hormis le formatage du fichier modifié.
