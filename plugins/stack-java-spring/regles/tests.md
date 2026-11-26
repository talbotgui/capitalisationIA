---
paths:
  - "**/src/test/**/*.java"
  - "**/*Test.java"
  - "**/*IT.java"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), enrichi de affaan-m/ecc (rules/java, licence MIT, voir NOTICE.md). -->

* Utiliser les outils déjà présents dans le projet ; à défaut JUnit 5 (@Test, @ParameterizedTest, @Nested, @DisplayName), AssertJ, Mockito, Testcontainers pour une base ou un service réel. Ne pas introduire un autre framework.
* Arborescence de src/test/java calquée sur les paquets de src/main/java ; tests d'intégration suffixés IT.
* Un test vérifie un comportement : nom methode_scenario_resultatAttendu ou @DisplayName lisible, structure préparation, action, vérification.
* Tests unitaires sans contexte Spring (MockitoExtension, classe testée construite à la main) ; tranches (@WebMvcTest, @DataJpaTest) pour une couche ; @SpringBootTest réservé aux tests d'intégration.
* Tests paramétrés (@CsvSource, @MethodSource) plutôt que des copies d'un même test.
* Aucune dépendance à l'ordre d'exécution, à l'heure courante ou au réseau : horloge injectée (Clock), données fixes et fictives.
* Ne pas simuler la classe testée ni les objets de valeur ; vérifier les résultats et les exceptions (assertThatThrownBy) plutôt que les appels internes.
* Couverture selon le seuil du projet, à défaut 80 % des lignes (JaCoCo) en priorité sur services et domaine ; inutile sur accesseurs et configuration.
* Tout correctif s'accompagne d'un test qui échoue sans lui ; lancer les tests concernés après modification (./mvnw -q test -Dtest=..., ./gradlew test --tests ...) et rapporter le résultat réel.
