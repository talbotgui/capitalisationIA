---
name: conventions-commits
description: Conventions de rédaction des messages de commit et de mention d'origine IA des fichiers. À appliquer avant tout commit, et à la création ou modification substantielle d'un fichier avec l'assistance de l'IA.
---

<!-- Fichier généré avec l'assistance de l'IA (Claude). -->

En cas de contradiction avec le CLAUDE.md ou les règles du projet, ces derniers prévalent.

## Message de commit

* En français, à l'impératif ou en phrase nominale, première ligne de 72 caractères au plus, sans point final.
* Une ligne vide, puis un corps facultatif expliquant le pourquoi plutôt que le comment, un paragraphe par ligne.
* Un commit par sujet cohérent ; ne jamais mélanger reformatage et changement de comportement.
* Ne jamais committer de secret (.env, clés, jetons) ni de fichier généré par la construction.
* Ne pas pousser (git push) sans demande explicite de l'utilisateur.

## Mention d'origine IA

* Tout commit dont le contenu est substantiellement produit ou assisté par l'IA le mentionne dans son message (ligne Co-Authored-By ou mention explicite).
* Tout fichier substantiellement produit ou assisté par l'IA porte en en-tête une mention d'origine, dans un commentaire adapté au format : « Fichier généré avec l'assistance de l'IA (Claude). »
* Dispenses : fichier reproduisant tel quel la sortie d'un générateur officiel ; format sans commentaire possible (JSON strict), la mention dans le message de commit restant alors seule obligatoire.
* Ne pas ajouter la mention à un fichier existant pour une modification mineure.
