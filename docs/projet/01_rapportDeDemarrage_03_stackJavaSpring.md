# Rapport de la phase 3 : stack Java Spring

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [État](#état)
* [Prototype de chargement des règles de langage](#prototype-de-chargement-des-règles-de-langage)
* [Conclusion du prototype](#conclusion-du-prototype)

Rapport de la [phase 3](01_planDeDemarrage_03_stackJavaSpring.md) du [plan de démarrage](01_planDeDemarrage.md).

## État

En cours (26/11/2026) : prototype de début de phase réalisé, arbitrage du mainteneur attendu avant le développement de stack-java-spring.

## Prototype de chargement des règles de langage

Objectif : vérifier que des règles de langage portées par un plugin ne sont chargées que sur les fichiers concernés (point ouvert du [plan de démarrage](01_planDeDemarrage.md#points-ouverts)).

Protocole : Claude Code 2.1.332 en mode non interactif (claude -p), plugin de test chargé par --plugin-dir, projets fixtures Java (src/main/java/A.java) et TypeScript (src/a.ts). La règle de test impose un commentaire témoin en tête de tout fichier Java modifié ; la consigne donnée est « ajoute une méthode vide m() à A.java ». Mesure : présence du commentaire témoin après la session, quatre sessions par configuration.

| Configuration | Modèle | Règle appliquée |
|---|---|---|
| Skill avec paths: "**/*.java" | Haiku 5.5 | 3/4 |
| Skill sans paths | Haiku 5.5 | 4/4 |
| Skill avec paths ne correspondant à aucun fichier | Haiku 5.5 | 4/4 |
| Skill avec paths: "**/*.java" | Sonnet 5.5 | 1/4 |
| Hook PreToolUse (Read, Edit, Write) injectant la règle (additionalContext) au premier fichier .java de la session | Haiku 5.5 | 3/4 |
| Même hook | Sonnet 5.5 | 4/4 |
| Même hook, projet TypeScript | Haiku 5.5 | 0/4 (aucune injection, attendu) |

Constats :

* paths n'a aucun effet mesurable sur une skill de plugin : la skill figure dans la liste fournie au modèle dès le démarrage, y compris sur le projet TypeScript, et son activation est la même avec un motif correspondant, sans motif ou avec un motif ne correspondant à rien. L'activation dépend uniquement de la décision du modèle à partir de la description, et varie fortement selon le modèle.
* La description de chaque skill reste en permanence dans le contexte, sur tous les projets.
* Le hook injecte la règle de façon déterministe, uniquement sur les fichiers concernés, une fois par session (4 injections sur 4 sessions Java, aucune sur TypeScript), sans rien coûter sur les autres stacks. L'application de la règle injectée reste à l'appréciation du modèle, mais elle est nettement plus fiable (4/4 avec Sonnet).
* Le contexte injecté par un hook PreToolUse sur Read arrive avec le contenu du fichier lu, donc avant toute modification (l'outil Edit exige une lecture préalable).

Limites : échantillon réduit (quatre sessions par configuration), règle de test artificielle, version 2.1.332 et non 2.1.328.

## Conclusion du prototype

Les skills avec paths ne permettent pas de charger les règles de langage au plus juste : le plan amendé le 22/11/2026 (voir [Organisation des règles](01_planDeDemarrage.md#organisation-des-règles)) repose sur une hypothèse infirmée. Le mécanisme fiable est un hook d'injection de contexte, non bloquant, déclenché par le motif du fichier manipulé. Arbitrage demandé au mainteneur : voir la réponse associée à ce rapport.
