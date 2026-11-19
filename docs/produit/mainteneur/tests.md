# Tests et contrôles en local

Document généré avec l'assistance de l'IA (Claude), à relire et valider.

## Sommaire

* [Commandes](#commandes)

Retour à l'[accueil de la documentation mainteneur](index.md).

## Commandes

Prérequis : bats, shellcheck, jq et la CLI claude.

* shellcheck : git ls-files -z '*.sh' | xargs -0 shellcheck
* catalogues : claude plugin validate --strict canaux/early-access et claude plugin validate --strict . (sans --strict tant que le catalogue stable est vide)
* plugins : claude plugin validate plugins/<nom>
* cohérence : outils/verifier-coherence.sh
* tests : bats tests/

Les tests de outils/installer.sh s'exécutent sur une copie locale du dépôt et une configuration Claude Code isolée (CLAUDE_CONFIG_DIR) : ils ne touchent pas la configuration du poste et n'accèdent pas au réseau. Ils sont ignorés si la CLI claude est absente.

La version de Claude Code utilisée par la CI (CLAUDE_CODE_VERSION dans validation.yml) doit être égale à VERSION_MIN_CLAUDE de outils/installer.sh ; la CI le contrôle.
