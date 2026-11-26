# Rapport de la phase 3 : stack Java Spring

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [État](#état)
* [Prototype de chargement des règles de langage](#prototype-de-chargement-des-règles-de-langage)
* [Conclusion du prototype](#conclusion-du-prototype)
* [Réalisé](#réalisé)
* [Choix de conception](#choix-de-conception)
* [Tests](#tests)
* [Incident corrigé](#incident-corrigé)
* [Critères de sortie](#critères-de-sortie)
* [Reste à faire](#reste-à-faire)

Rapport de la [phase 3](01_planDeDemarrage_03_stackJavaSpring.md) du [plan de démarrage](01_planDeDemarrage.md).

## État

En cours (26/11/2026) : développements terminés sur la branche claude/keen-allen-agvylk, vérification sur le poste du mainteneur et publications à dérouler.

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

Les skills avec paths ne permettent pas de charger les règles de langage au plus juste : le plan amendé le 22/11/2026 (voir [Organisation des règles](01_planDeDemarrage.md#organisation-des-règles)) repose sur une hypothèse infirmée. Le mécanisme fiable est un hook d'injection de contexte, non bloquant, déclenché par le motif du fichier manipulé. Arbitrage du mainteneur (26/11/2026) : hook d'injection retenu, PreToolUse autorisé pour injecter du contexte, jamais pour bloquer. Le plan est amendé en conséquence.

## Réalisé

* Bibliothèque commune (socle 1.1.0, copiée dans regles-projets et stack-java-spring) : moteur capia_injecter_regles (en-tête paths, conversion des motifs, état par session), conversion des chemins Windows.
* socle : remise à zéro de l'état des règles après /clear ou compactage, purge des états de plus de 7 jours.
* Plugin stack-java-spring (CHANGELOG 0.1.0), référencé dans le catalogue early access, dépendant de socle :
  * hook PreToolUse injecter-regles.sh, règles regles/ : developpement, conception, tests, maven, gradle, spring-configuration ;
  * hook PostToolUse formater.sh : google-java-format, sinon Spotless Maven (mvnw ou mvn, hors ligne, fichier seul via spotlessFiles), sinon Spotless Gradle (gradlew ou gradle, hors ligne, spotlessIdeHook), délai de 50 secondes.
* regles-projets (0.1.0, non publié) : fichiers de règles du projet à en-tête paths injectés par motif.
* temoin 0.3.1 : correction de /temoin:canal (voir [Incident corrigé](#incident-corrigé)).
* outils/verifier-coherence.sh : en-tête paths obligatoire dans regles/*.md.
* Documentation : [règles injectées par motif](../produit/mainteneur/conventions.md#règles-injectées-par-motif-de-fichier) (mainteneur), [stack-java-spring](../produit/utilisateur.md#stack-java-spring) (utilisateur), plan amendé ([organisation des règles](01_planDeDemarrage.md#organisation-des-règles)).

## Choix de conception

* Analyse statique Java non réalisée dans le hook PostToolUse : aucun outil courant n'analyse un fichier isolé en quelques secondes (Checkstyle, SpotBugs, PMD via Maven ou Gradle portent sur le module) ; l'analyse reste portée par la CI des projets (point ouvert du plan).
* Règles de conception limitées au code principal (**/src/main/java/**/*.java), règles de test aux fichiers de test : un fichier de test ne reçoit pas les règles de conception.
* Formatage hors ligne (-o, --offline) : aucun téléchargement, conformément au plan ; un plugin Spotless absent du cache local donne une erreur sur la sortie d'erreur, sans effet sur la session.
* Le contexte injecté au premier Write d'un nouveau fichier arrive après l'écriture : limite acceptée, la règle s'applique aux modifications suivantes.

## Tests

* 78 tests bats verts en local, dont 14 pour stack-java-spring (injection par motif, une fois par session, réinjection après compactage, chemins Windows, fichiers hors projet ou d'une autre stack, coupe-circuit, instance early, aucune écriture dans le projet ; formatage par google-java-format, Spotless Maven avec ou sans wrapper, Spotless Gradle d'un module, absence d'outil, échec d'outil), 3 pour le moteur et la purge (socle), 2 pour regles-projets, 1 de cohérence et 1 de bascule de canal.
* Bout en bout avec Claude Code 2.1.332 (claude -p, Sonnet 5.5, plugins chargés par --plugin-dir, google-java-format simulé) : sur un projet Java, règles java-developpement et java-conception reçues et appliquées (Javadoc ajoutée selon la règle), formatage appelé sur le fichier modifié ; sur un projet TypeScript, aucune règle reçue.
* Durées mesurées : injection 0,06 à 0,08 s, formatage hors outil 0,03 s, pour des délais déclarés de 10 et 60 secondes.
* shellcheck sans alerte ; claude plugin validate vert sur les quatre plugins et les deux catalogues ; outils/verifier-coherence.sh vert.

## Incident corrigé

Le test de bascule de canal a échoué dès l'ajout de stack-java-spring : /temoin:canal désactivait les plugins par ordre alphabétique et la CLI refuse de désactiver socle tant que stack-java-spring, qui en dépend, est actif. Correction dans temoin 0.3.1 : désactivations et réactivations relancées tant qu'elles progressent, réactivations avant installations ; test ajouté (bascule early, stable, early avec plugins dépendants). Les postes ne sont pas touchés tant que stack-java-spring n'est pas fusionné, mais temoin 0.3.1 doit être publié en stable avant ou avec la première version de stack-java-spring.

## Critères de sortie

| Critère | État |
|---|---|
| Formatage effectif sur un projet Java fixture | atteint avec outil simulé ; à vérifier sur le poste du mainteneur avec un outil réel |
| Sortie silencieuse sur les autres stacks | atteint |
| Durée du hook inférieure au timeout déclaré | atteint (hors temps propre de l'outil de formatage, borné à 50 s) |
| Règles injectées sur un projet Java fixture, non injectées sur une autre stack | atteint (tests et bout en bout) |

## Reste à faire

1. Fusionner la branche claude/keen-allen-agvylk sur main (phases 2 et 3).
2. Publier temoin 0.3.1, puis socle 1.1.0, regles-projets 0.1.0 et stack-java-spring 0.1.0.
3. Sur le poste du mainteneur (Git Bash) : /temoin:canal early puis stable ; sur un projet Java réel, vérifier les règles reçues (« quelles règles java as-tu reçues ? ») et le formatage par l'outil du projet ; vérifier l'absence d'effet sur un projet non Java.
4. Compléter ce rapport et clore la phase.
