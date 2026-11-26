---
paths: "**/src/main/java/**/*.java"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude). -->

* Respecter le découpage en couches existant (par exemple controleur, service, dépôt) et le sens des dépendances : une couche ne dépend jamais d'une couche supérieure, aucune dépendance circulaire entre paquets.
* Injection de dépendances par constructeur, champs final ; jamais d'injection par champ (@Autowired sur un champ).
* Contrôleurs REST minces : validation des entrées (@Valid, Bean Validation), délégation au service, aucune logique métier.
* Ne jamais exposer une entité JPA dans une API : DTO dédiés et conversion explicite.
* Transactions (@Transactional) sur la couche service, en lecture seule (readOnly = true) pour les lectures ; jamais sur un contrôleur.
* Configuration externalisée (application.yml, @ConfigurationProperties typées) ; aucune valeur d'environnement, URL ou secret en dur.
* Requêtes : paramètres liés, jamais de concaténation de chaînes ; attention aux requêtes N+1 (fetch join, entity graph).
* Gestion d'erreur centralisée (@RestControllerAdvice), réponses d'erreur homogènes sans trace technique exposée.
