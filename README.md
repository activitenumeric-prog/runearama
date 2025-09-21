# RanaramaLike Prototype (Godot 4)

## Lancer
1) Ouvre Godot 4 et "Import" ce dossier.
2) La scène principale est `scenes/Main.tscn` (déjà référencée comme Main).
3) Appuie sur ▶ pour jouer.

## Commandes
- Déplacement : ZQSD ou flèches
- Attaque (tir basique) : Espace
- Lancer sort : E
- Changer de sort : C / X (préc./suiv.)

## Contenu
- Génération procédurale simple (drunkard walk) avec murs instanciés.
- Joueur et ennemis (poursuite, PV, mort).
- Projectiles avec dégâts.
- Système de magie basé Resource (`resources/spells/Bolt.tres`), via `scripts/Spell.gd` et `scripts/Caster.gd`.
- HUD (PV, Mana, Score, Vies).

## Brancher le sort
- Dans `Player` → `Caster`, ajoute un élément dans `spells` et sélectionne `resources/spells/Bolt.tres`.

## Notes sur les erreurs possibles
- Messages `Couldn't find preset.* include_filter` : ils viennent souvent d'un `export_presets.cfg` manquant/obsolète. Ils sont **sans impact** pour jouer dans l'éditeur. Tu peux les ignorer tant que tu n'exportes pas le projet.