---
paths:
  - "**/src/test/**/*.java"
  - "**/*Test.java"
  - "**/*IT.java"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude). -->

* Utiliser le framework de test déjà présent dans le projet (JUnit 5 par défaut, AssertJ si disponible, Mockito pour les doublures) ; ne pas en introduire un autre.
* Un test vérifie un comportement : nom explicite (méthode ou @DisplayName), structure préparation, action, vérification.
* Tests unitaires sans contexte Spring ; tranches (@WebMvcTest, @DataJpaTest) pour une couche ; @SpringBootTest réservé aux tests d'intégration.
* Aucune dépendance à l'ordre d'exécution, à l'heure courante ou au réseau : horloge injectée (Clock), données de test fixes et fictives, Testcontainers pour une base réelle si le projet l'utilise.
* Ne pas simuler la classe testée ni les objets de valeur ; vérifier les résultats plutôt que les appels internes.
* Tout correctif s'accompagne d'un test qui échoue sans lui.
* Lancer les tests concernés après modification (mvn -q test -Dtest=..., ./gradlew test --tests ...) et en rapporter le résultat réel.
