# Rapport de la phase 1 : socle

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [État](#état)
* [Réalisé](#réalisé)
* [Écarts et choix de conception](#écarts-et-choix-de-conception)
* [Tests](#tests)
* [Critères de sortie](#critères-de-sortie)
* [Reste à faire](#reste-à-faire)

Rapport de la [phase 1](01_planDeDemarrage_01_socle.md) du [plan de démarrage](01_planDeDemarrage.md).

## État

Terminée (22/11/2026) : socle 1.0.0 publié en stable (tag socle--v1.0.0), critères de sortie atteints, validés par le mainteneur.

## Réalisé

* Plugin socle, référencé dans le catalogue early access et publié en stable en 1.0.0 :
  * hook UserPromptSubmit journaliser-prompt.sh, adapté de suiviProjets (même format d'entrée), journal hors projet en mode 600, dossiers en mode 700 ;
  * hook SessionStart (startup) purger-journaux.sh : rétention de 90 jours, paramétrable par CAPIA_RETENTION_JOURS ;
  * bibliothèque lib/commun.sh : normalisation du remote, identifiant de projet, coupe-circuit, contrôle d'instance active ;
  * skills conventions-commits et redaction-markdown ;
  * agent explorateur-code, version générique de celui de suiviProjets.
* [Documentation utilisateur](../produit/utilisateur.md) : plugin socle, [journal des prompts](../produit/utilisateur.md#journal-des-prompts), [coupe-circuit](../produit/utilisateur.md#coupe-circuit).
* [Documentation mainteneur](../produit/mainteneur/conventions.md#bibliothèque-commune-des-hooks) : bibliothèque commune et normalisation du remote.

## Écarts et choix de conception

Choix validés par le mainteneur le 22/11/2026.

* Contrôle du canal actif : aucun « canal déclaré » n'existe dans les settings ; règle retenue : si un plugin est activé dans les deux canaux, seule l'instance stable s'exécute. Le plan est amendé en ce sens.
* Normalisation du remote : suppression des identifiants (jeton dans une URL https) et du port, rejet des formes non reconnues, ce qui évite tout chemin de journal hors du dossier prévu.
* Coupe-circuit : non appliqué à temoin, qui n'écrit rien et sert au diagnostic.
* Dossier des données : CLAUDE_CONFIG_DIR s'il est défini, ~/.claude sinon.
* Partage de la bibliothèque avec les autres plugins : le chemin de socle n'est pas connu d'un autre plugin ; mode d'accès (copie par plugin ou recherche de socle dans le cache) à arbitrer en phase 2.
* Journal technique de mesure du temps passé dans les hooks (section Exploitation du plan) : reporté à la préparation du pilote (phase 4).

## Tests

* 46 tests bats verts en local, dont 12 pour socle : formes de remote, identifiants et port supprimés, formes rejetées, repli sans remote, coupe-circuit, instance active, journal (contenu, droits, aucun fichier dans le projet fixture), entrée invalide, purge et rétention.
* Sur le poste du mainteneur (Git Bash), canaux early access puis stable : journal écrit hors projet avec ses droits, skills et agent opérationnels.
* shellcheck sans alerte ; claude plugin validate vert sur les deux plugins et les deux catalogues ; outils/verifier-coherence.sh vert.

## Critères de sortie

| Critère | État |
|---|---|
| Tests bats verts | atteint |
| Journal écrit hors projet avec les bons droits, purge vérifiée | atteint |
| Aucun fichier créé dans les projets fixtures | atteint |
| Installation par une tierce personne avec la seule documentation utilisateur | atteint |

## Reste à faire

Rien pour cette phase. Points reportés : accès des autres plugins à la bibliothèque commune ([phase 2](01_planDeDemarrage_02_reglesProjets.md)), journal technique de mesure des hooks ([phase 4](01_planDeDemarrage_04_pilote.md)).
