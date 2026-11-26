---
paths: "**/src/main/java/**/*.java"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), enrichi de affaan-m/ecc (rules/java, licence MIT, voir NOTICE.md). -->

* Aucun secret (clé d'API, jeton, mot de passe) dans le code : variables d'environnement contrôlées au démarrage, gestionnaire de secrets en production.
* Requêtes SQL toujours paramétrées (PreparedStatement, JdbcTemplate, paramètres JPA) ; jamais de concaténation d'une entrée, y compris en requête native.
* Toute entrée validée à la frontière du système (Bean Validation sur les DTO, contrôles explicites sinon) ; chemins de fichiers et chaînes fournies assainis ; refus explicite d'une entrée invalide.
* Authentification et cryptographie par des bibliothèques éprouvées (Spring Security), jamais d'implémentation maison ; mots de passe hachés par bcrypt ou Argon2, jamais MD5 ni SHA-1.
* Contrôles d'autorisation au niveau des services, pas seulement de l'interface.
* Jamais de mot de passe, jeton ou donnée personnelle dans les journaux.
* Réponses d'erreur génériques côté client : ni trace, ni chemin interne, ni erreur SQL ; détail journalisé côté serveur.
* Dépendances : toute nouvelle dépendance auditée (mvn dependency:tree, ./gradlew dependencies, OWASP Dependency-Check si présent dans le projet).
