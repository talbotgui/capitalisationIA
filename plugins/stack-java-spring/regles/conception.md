---
paths: "**/src/main/java/**/*.java"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), enrichi de affaan-m/ecc (rules/java, licence MIT, voir NOTICE.md). -->

* Respecter le découpage en couches existant (contrôleur, service, dépôt) et le sens des dépendances : aucune dépendance vers une couche supérieure ni entre paquets en cycle ; organiser de préférence par domaine fonctionnel.
* Logique métier dans les services ; contrôleurs et dépôts minces. Accès aux données derrière une interface de dépôt (implémentations JPA, JDBC ou en mémoire pour les tests).
* Injection de dépendances par constructeur, champs final ; jamais d'injection par champ (@Autowired, @Inject sur un champ).
* Contrôleurs REST : validation des entrées (@Valid, Bean Validation), délégation au service, aucune logique métier ; réponses de forme homogène selon la convention du projet.
* Ne jamais exposer une entité JPA dans une API : DTO en records, conversion explicite aux frontières (méthode statique from).
* Builder pour les objets à nombreux paramètres optionnels ; types sealed et records pour les résultats métier à cas multiples, traités par un switch exhaustif.
* Transactions (@Transactional) sur la couche service, readOnly = true pour les lectures ; jamais sur un contrôleur.
* Configuration externalisée (application.yml, @ConfigurationProperties typées) ; aucune URL, valeur d'environnement ou secret en dur.
* Requêtes : attention aux requêtes N+1 (fetch join, entity graph) ; gestion d'erreur centralisée (@RestControllerAdvice).
