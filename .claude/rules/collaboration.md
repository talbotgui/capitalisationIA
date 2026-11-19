# Règles de collaboration

Fichier généré avec l'assistance de l'IA (Claude).

## Réponses et rédaction

* Réponses et documents concis, en français.
* Toute référence d'un document Markdown vers un autre est un lien cliquable (chemin relatif), avec ancre si elle vise un chapitre.

## Documentation

* Toute page Markdown du répertoire docs/ commence par un sommaire dont chaque entrée est un lien vers le chapitre correspondant.
* docs/ contient deux sous-répertoires :
  * docs/produit/ : documentation du produit (utilisateur, mainteneur) ;
  * docs/projet/ : plans et rapports.

## Plans et rapports

* Chaque plan est un fichier dédié de docs/projet/, dont le nom commence par un index à deux chiffres incrémenté à chaque nouveau plan : NN_nomDuPlan.md (exemple : 01_planDeDemarrage.md).
* Un plan découpé en grosses phases a un fichier par phase : NN_nomDuPlan_PP_nomDeLaPhase.md (exemple : 01_planDeDemarrage_00_fondation.md). Le fichier du plan référence les fichiers des phases par des liens.
* Un rapport n'est jamais rédigé dans le fichier d'un plan ou d'une phase : il fait l'objet d'un fichier séparé portant le même index que le plan, NN_rapport....md, et le même index de phase le cas échéant (exemple : 01_rapportDeDemarrage_00_fondation.md). Le plan ou la phase référence son rapport par un lien.
