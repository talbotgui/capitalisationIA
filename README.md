# capitalisationIA

Document généré avec l'assistance de l'IA (Claude).

## Sommaire

* [Présentation](#présentation)
* [Installation rapide](#installation-rapide)
* [Documentation](#documentation)
* [Organisation du dépôt](#organisation-du-dépôt)

## Présentation

Marketplace de plugins Claude Code partagés entre projets, sans aucune trace de configuration Claude Code dans les dépôts de code des projets. Deux canaux sont proposés : stable (capitalisation-ia, versions publiées) et early access (capitalisation-ia-early, chaque fusion sur main).

## Installation rapide

Depuis Git Bash, avec claude, git et jq disponibles :

```bash
git clone https://github.com/talbotgui/capitalisationIA.git
```

```bash
capitalisationIA/outils/installer.sh stable
```

Remplacer stable par early pour le canal early access. Le détail figure dans la [documentation utilisateur](docs/produit/utilisateur.md).

## Documentation

* [Documentation utilisateur](docs/produit/utilisateur.md) : installation, canaux, plugins, dépannage.
* [Documentation mainteneur](docs/produit/mainteneur/index.md) : paramétrage GitHub, publication, tests, conventions.
* [Plan de démarrage](docs/projet/01_planDeDemarrage.md) et documents de projet dans [docs/projet](docs/projet/).

## Organisation du dépôt

* .claude-plugin/marketplace.json : catalogue stable.
* canaux/early-access/.claude-plugin/marketplace.json : catalogue early access.
* plugins/ : un dossier par plugin.
* outils/ : installation, publication, contrôles de cohérence.
* tests/ : tests bats.
* docs/produit/ : documentation du produit ; docs/projet/ : plans et rapports.
* .github/workflows/ : validation (PR et main) et publication (déclenchement manuel).
