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
- Système de magie basé Resource (`resources/spells/Bolt.tres`), via `scripts/Spell.gd` et `Caster.gd`.
- HUD (PV, Mana, Score, Vies).

## À brancher dans l’éditeur
- Dans `Player` → `Caster`, ajoute un élément dans `spells` et selectionne `resources/spells/Bolt.tres`.
  (On laisse volontairement ce branchement manuel pour que tu voies comment ajouter d'autres sorts plus tard.)

## Pistes d’extension
- Ajoute d'autres `Spell.tres` (aoe, cône, rayon).
- Différents types d'ennemis.
- Portes, clés, sortie de niveau conditionnée.
- Effets visuels (sprites, particules, sons).