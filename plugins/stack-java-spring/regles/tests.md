---
paths:
  - "**/src/test/**/*.java"
  - "**/*Test.java"
  - "**/*IT.java"
---
<!-- Fichier généré avec l'assistance de l'IA (Claude), d'après la documentation officielle de Spring Boot et de JUnit et affaan-m/ecc (rules/java) ; voir NOTICE.md. -->

* Utiliser les outils déjà présents dans le projet ; à défaut JUnit Jupiter (JUnit 5 ou 6 selon le projet : @Test, @ParameterizedTest, @Nested, @DisplayName), AssertJ, Mockito, Testcontainers pour une base ou un service réel. Ne pas introduire un autre framework.
* Classes, méthodes de test et méthodes de cycle de vie sans modificateur public (recommandation de JUnit), jamais private.
* Arborescence de src/test/java calquée sur les paquets de src/main/java ; tests d'intégration suffixés IT.
* Un test vérifie un comportement : nom methode_scenario_resultatAttendu ou @DisplayName lisible, structure préparation, action, vérification.
* Tests unitaires sans contexte Spring (MockitoExtension, classe testée construite à la main) ; tranches (@WebMvcTest limité à un contrôleur, @DataJpaTest, @JsonTest, @RestClientTest) pour une couche ; @SpringBootTest réservé aux tests d'intégration (sans serveur par défaut ; webEnvironment = RANDOM_PORT pour un serveur réel, dont les transactions ne sont pas annulées par le @Transactional du test).
* Doublures de beans par @MockitoBean et @MockitoSpyBean de Spring Framework ; @MockBean de Spring Boot, déprécié puis retiré en Spring Boot 4, seulement dans un projet d'une version antérieure qui l'utilise déjà.
* Testcontainers : connexion par @ServiceConnection plutôt que par propriétés écrites à la main ; conteneurs déclarés comme beans Spring ou importés (@ImportTestcontainers) quand le contexte mis en cache doit rester utilisable.
* Tests paramétrés (@CsvSource, @MethodSource) plutôt que des copies d'un même test.
* Aucune dépendance à l'ordre d'exécution, à l'heure courante ou au réseau : horloge injectée (Clock), données fixes et fictives.
* Ne pas simuler la classe testée ni les objets de valeur ; vérifier les résultats et les exceptions (assertThatThrownBy) plutôt que les appels internes.
* Couverture selon le seuil du projet, à défaut 80 % des lignes (JaCoCo) en priorité sur services et domaine ; inutile sur accesseurs et configuration.
* Tout correctif s'accompagne d'un test qui échoue sans lui ; lancer les tests concernés après modification (./mvnw -q test -Dtest=..., ./gradlew test --tests ...) et rapporter le résultat réel.
