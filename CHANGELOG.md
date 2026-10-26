# Historique des versions

Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).

## [1.0.0] - 2026-10-26

Remaster du pack ba_jail de 2012 pour SourceMod 1.12.

### Corrigé

- **DV** (réécrite) : tout le serveur restait gelé si le dernier prisonnier fermait la question « Voulez-vous votre
  DV ? » (menu sans fin) ; elle expire maintenant après 20 s et tout le monde est dégelé quoi qu'il arrive (refus,
  fermeture, mort, déconnexion, fin de round). Les menus gardés ouverts restaient valables plus tard : le choix est
  revérifié (même round, dernier prisonnier vivant, gardien vivant). Plus d'action sur un gardien parti ni sur un
  index jamais rempli (Isoloire, Brochette), plus d'entités 316 et 319 colorées en dur. Cvars des sons renommées
  (`sm_dv_son_*`) : leurs noms contenaient des espaces.
- **Dernier CT** : crash du serveur possible (modèle non initialisé quand aucun prisonnier n'était en vie).
- **Ouverture des cellules** : visait la map `_v6_a3` au lieu de `_v6`, donc ne faisait rien ; bouton cherché avec une
  tolérance, activateur vérifié.
- **Plaintes** : `!plainte` ne marchait pas dans le chat, les admins root ne recevaient rien, « Unknown command »
  après l'envoi, couleurs du joueur interprétées, délai non remis à zéro pour un nouveau joueur.
- **Tags de clan** : la config n'était jamais appliquée ; tag posé par l'extension cstrike (l'ancien include reposait
  sur une signature disparue).
- **Spray Trace** : punitions ciblées par pseudo (risque d'injection et de mauvaise cible), maintenant par `#userid` ;
  ban temporaire jamais appliqué ; handles de cvars fermés à tort ; fuite des menus.
- **CD Announcer** : chemin du journal doublé (erreur à chaque démarrage), code pays (GeoIP2).
- **Country Filter** : code pays (GeoIP2).
- **EvilDeagle, SpawnTools7** : dossier de sauvegarde créé sans droit d'écriture ; `RemoveEdict` remplacé.
- **SimpleSkins** : joueur invalide à l'apparition.
- Fonctions obsolètes remplacées (`GetClientAuthString`, `FindSendPropOffs`, `GetMaxClients`) : tout compile sans
  avertissement.

### Ajouté

- DV : Lancer de Deagle et Basket se jouent avec un Deagle vide ; lunette bloquée dans les duels « unscope ».
- Cadeaux activés pour les prisonniers (dans le pack, tous les `gift_*_who` valaient 0 : personne n'y avait droit).
- SMAC à jour (fork srcdslab) et Little Anti-Cheat 1.7.4.
- Réglages réunis dans `cfg/jailbreak_server.cfg` ; fichier `.nav` de la map pour les bots.
- Compilation automatique des plugins (GitHub Actions).

### Retiré

- `rcon_lock` (supprimait des fichiers de plugins), `smac_kac_banlist` (service fermé), anciens SMAC et Stripper.
