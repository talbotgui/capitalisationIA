---
paths: "**/src/main/java/**/*.java"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle de Spring Boot et de JUnit et affaan-m/ecc (rules/java) ; voir NOTICE.md. -->

* Respecter le découpage en couches existant (contrôleur, service, dépôt) et le sens des dépendances : aucune dépendance vers une couche supérieure ni entre paquets en cycle ; organiser de préférence par domaine fonctionnel.
* Jamais de classe dans le paquet par défaut ; paquets en nom de domaine inversé (com.exemple.projet) ; classe principale (@SpringBootApplication) dans le paquet racine, au-dessus des autres classes, pour que l'analyse des composants les trouve.
* Configuration par classes @Configuration (une classe principale, les autres importées par @Import ou trouvées par l'analyse des composants) ; pas de configuration XML sauf existant.
* Logique métier dans les services ; contrôleurs et dépôts minces. Accès aux données derrière une interface de dépôt (implémentations JPA, JDBC ou en mémoire pour les tests).
* Injection de dépendances par constructeur (recommandation de Spring Boot), champs final, sans @Autowired quand le constructeur est unique ; jamais d'injection par champ.
* Contrôleurs REST : validation des entrées (@Valid, Bean Validation), délégation au service, aucune logique métier ; réponses de forme homogène selon la convention du projet.
* Ne jamais exposer une entité JPA dans une API : DTO en records, conversion explicite aux frontières (méthode statique from).
* Builder pour les objets à nombreux paramètres optionnels ; types sealed et records pour les résultats métier à cas multiples, traités par un switch exhaustif.
* Transactions (@Transactional) sur la couche service, readOnly = true pour les lectures ; jamais sur un contrôleur.
* Configuration externalisée : clés propres à l'application regroupées dans des classes @ConfigurationProperties typées, de préférence immuables (record ou constructeur unique, liaison par constructeur) et validées (@Validated), plutôt que des @Value dispersés ; aucune URL, valeur d'environnement ou secret en dur.
* JPA : Spring Boot active par défaut l'« Open EntityManager in View » en application web ; le désactiver (spring.jpa.open-in-view=false) pour un nouveau projet et charger explicitement les associations nécessaires ; attention aux requêtes N+1 (fetch join, entity graph).
* Gestion d'erreur centralisée (@RestControllerAdvice), réponses d'erreur au format Problem Details (RFC 9457, ProblemDetail, spring.mvc.problemdetails.enabled) si le projet n'a pas déjà son format.
