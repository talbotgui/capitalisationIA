---
name: version
description: Affiche le canal (stable ou early access) et la version du plugin temoin chargés, et signale une activation simultanée des deux canaux. Utile dans les interfaces qui n'affichent pas le message de démarrage, comme l'extension VS Code.
allowed-tools: Bash(bash "${CLAUDE_SKILL_DIR}/../../scripts/afficher-canal.sh" --texte)
---

<!-- Fichier généré avec l'assistance de l'IA (Claude). -->

1. Exécuter : bash "${CLAUDE_SKILL_DIR}/../../scripts/afficher-canal.sh" --texte
2. Restituer le message produit tel quel, sans commentaire, y compris l'éventuelle alerte « ATTENTION ».
3. Si le script ne produit rien (jq absent), l'indiquer et proposer d'installer jq.

Ne modifier aucun fichier.
