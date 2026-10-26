# CSS-BaJail-Remastered

Le pack **ba_jail** d'un serveur Counter-Strike: Source de 2012 : la map `ba_jail_electric_razor_v6`, ses skins, ses
sons et les plugins de la communauté de l'époque. Tout a été audité ligne par ligne, corrigé et porté pour
SourceMod 1.12. Même démarche que [CSS-RP-Remastered](https://github.com/WareZ57/CSS-RP-Remastered).

## Le mode

Des prisonniers (T) et des gardiens (CT), deux prisonniers pour un gardien.

- **Équipes** : le ratio 2 T pour 1 CT est tenu par TeamRatioControl, qui rééquilibre en fin de round. Pas de tir
  allié, pas de collision entre joueurs.
- **Skins** : gardien en policier, prisonnier en tenue de prison.
- **Ouverture des cellules** : annoncée dans le chat avec le nom de celui qui a appuyé sur le bouton.
- **Dernier CT** : annoncé avec un son ; il prend l'apparence d'un prisonnier (« espion »).
- **Dernière Volonté (DV)** : quand il ne reste qu'un prisonnier, tout le monde est gelé le temps qu'il réponde (20 s
  au plus), puis il choisit son duel avec `!dv`.
- **Cadeaux** : `!gift` donne aux prisonniers un bonus ou un malus au hasard, 3 fois par map.
- **Deagle magique** : un Deagle à une balle, très puissant, posé aux positions enregistrées par un admin.
- **Armurerie** : la config Stripper remplace les MAC-10 par des Deagle et ajoute 5 Scout, 5 M3, 5 P90 et 5 FAMAS ;
  elle cache aussi un G3SG1 (« Autonoob ») et 6 Elite (« Bateuse cachée »), comme le pack d'origine.
- **Serveur** : connexions annoncées avec le pays, filtre de pays (France, Belgique, Suisse, DOM-TOM, Canada), un mort
  qui se reconnecte ne réapparaît pas dans le même round, plaintes aux admins, tags de clan selon les droits.
- **Anti-cheat** : SMAC (le cœur et 13 modules) et Little Anti-Cheat.

### Les duels de la Dernière Volonté

| Duel | Armes | Contre |
|---|---|---|
| Roulette, Roulette chinoise, Planche pirate | Deagle | un gardien au choix |
| Lancer de Deagle, Basket | Deagle **vide** (on le lance) | un gardien au choix |
| Cut, Cut aqua | couteau | un gardien au choix |
| Unscop AWP, Unscop Scout | AWP ou Scout, couteau ; **lunette bloquée** | un gardien au choix |
| Isoloire | M249, le prisonnier a 200 PV | tous les gardiens (2 au moins) |
| Brochette | AWP et 200 PV pour le prisonnier, M4A1 pour les gardiens | tous les gardiens (3 au moins) |

Les positions des duels sont celles de `ba_jail_electric_razor_v6` : la DV n'est proposée que sur cette map.

## Contenu du dépôt

```
cstrike/
├── addons/sourcemod/
│   ├── plugins/               plugins compilés (SourceMod 1.12)
│   ├── scripting/             sources (et include/)
│   └── translations/
├── addons/stripper/maps/      modifications de la map (armurerie)
├── cfg/jailbreak_server.cfg   réglages de partie
├── cfg/sourcemod/             réglages des plugins
├── maps/                      ba_jail_electric_razor_v6 (.bsp et .nav)
├── materials/ models/         skins gardien et prisonnier
└── sound/                     sons de la DV et du dernier CT
```

## Installation

Prérequis : un serveur dédié Counter-Strike: Source (Linux ou Windows) avec
[Metamod:Source 1.12](https://www.sourcemm.net/downloads.php?branch=stable),
[SourceMod 1.12](https://www.sourcemod.net/downloads.php?branch=stable) et
[Stripper:Source 1.2](https://www.bailopan.net/stripper/) (Metamod). Testé avec SourceMod 1.12.0.7259, Metamod:Source
1.12.0-git1228 et Stripper:Source 1.2.2-git141.

1. **Fichiers** : copier le dossier `cstrike/` du dépôt par-dessus le dossier `cstrike/` du serveur.
2. **Réglages** : ajouter cette ligne à la fin de `cstrike/cfg/server.cfg` :
   ```
   exec jailbreak_server.cfg
   ```
3. **Map** : démarrer sur `ba_jail_electric_razor_v6` (`+map ba_jail_electric_razor_v6`) et la mettre seule dans
   `cstrike/cfg/mapcycle.txt`.
4. **Pays** (facultatif) : déposer une base GeoIP au format `.mmdb` dans `cstrike/addons/sourcemod/configs/geoip/`, par
   exemple [DB-IP Lite Country](https://db-ip.com/db/download/ip-to-country-lite) (gratuite). Sans elle, le filtre de
   pays laisse entrer tout le monde et les connexions sont annoncées sans pays.
5. **Téléchargements** : la map (4 Mo), les skins et les sons passent par le serveur de jeu ; un FastDL
   (`sv_downloadurl`) les rend plus rapides.

Vérification : `sm plugins list` doit lister 32 plugins en plus de ceux de SourceMod, dont `*~ Plugin DV ~*`, et
`meta list` doit montrer Stripper.

## Commandes

Dans le chat : `!commande`, ou `/commande` sans que le message s'affiche ; dans la console : `sm_commande`.

**Joueurs**

| Commande | Effet |
|---|---|
| `!dv` | choisir son duel, quand on est le dernier prisonnier en vie |
| `!plainte <message>` | plainte envoyée aux admins, une par minute |
| `!gift` | cadeau au hasard pour les prisonniers : PV, vitesse, dégâts, AWP, USP, kevlar, grenades, soin, balise, espion… ou aveuglement, feu, PV et vitesse en moins |
| `!medik`, `!spy`, `!balise <joueur>` | utiliser le cadeau reçu : soigner les alliés proches, skin espion, balise sur un joueur |
| `sm_rate <joueur>` | taux réseau d'un joueur |

**Admins**

| Commande | Droit | Effet |
|---|---|---|
| `sm_smite <joueur>` | `f` | tuer d'un éclair |
| `sm_spraytrace`, `sm_removespray`, `sm_adminspray <joueur>` | `d` | auteur d'un spray, l'effacer, le reproduire ; menu de punition |
| `sm_evildeagle 0/1`, `sm_evildeagle_show`, `_save`, `_remove` | `m` | Deagle magique : activer, voir, enregistrer ou retirer ses positions |
| menu `!admin` → Spawn Tools 7 | `m` | ajouter ou retirer des points d'apparition |
| `sm_ratelist` | admin | taux réseau de tous les joueurs |
| `smac_status`, `smac_addcmd`, `smac_removecmd`… | admin | état et réglages de SMAC |
| `lilac_ban_status` | console serveur | état des bannissements de Little Anti-Cheat |

**Tags de clan** selon les droits : `t` Leader, `a` Admin, `s` VIP, `q` et `p` tags perso (`plugin_clantag.cfg`). Les
plaintes arrivent aux admins qui ont le droit `f`, ou root.

## Réglages

| Fichier | Contenu |
|---|---|
| `cfg/jailbreak_server.cfg` | tir allié, équilibrage, voix ; ratio 2:1 (`sm_trc_*`) ; Deagle magique (`sm_evildeagle_*`) |
| `cfg/sourcemod/dv.cfg` | sons de la DV (`sm_dv_son_*`), créé au premier démarrage |
| `cfg/sourcemod/sm_dernier_ct.cfg` | annonce, son et espion du dernier CT |
| `cfg/sourcemod/plugin_gift.cfg` | cadeaux : pour qui, probabilités, nombre par map |
| `cfg/sourcemod/country_filter_2nd_edition.cfg` | pays autorisés |
| `cfg/sourcemod/simpleskins.cfg` | skins |
| `cfg/sourcemod/plugin_clantag.cfg` | tags de clan |
| `cfg/sourcemod/lilac_config.cfg` | Little Anti-Cheat (son contrôle des cvars est coupé : SMAC le fait déjà) |

**Little Anti-Cheat bannit définitivement par défaut** (`lilac_ban_length 0`).

## Audit et corrections

Aucune backdoor dans ce pack : pas de SteamID ni d'IP codés en dur, pas de droit admin caché, pas de connexion
extérieure. Les vrais problèmes étaient des bugs, tous corrigés (détail dans [CHANGELOG.md](CHANGELOG.md)) :

- **DV** : si le dernier prisonnier fermait la question, **tout le serveur restait gelé jusqu'à la fin du round** ; les
  menus restaient valables au round suivant ; actions sur des joueurs partis ; réglages impossibles (cvars avec des
  espaces).
- **Dernier CT** : un modèle non initialisé pouvait **faire planter le serveur**.
- **Ouverture des cellules** : visait un autre nom de map, donc ne marchait jamais.
- **Spray Trace** : punitions qui ciblaient le joueur par son pseudo, ban temporaire cassé, fuite de mémoire.

La map lance au chargement une commande serveur, `phys_pushscale 900` (réglage physique), sans danger.

Pas repris du pack : `rcon_lock` (il supprimait des fichiers de plugins), `smac_kac_banlist` (liste de bannis d'un
service fermé), les vieux binaires de SMAC et de Stripper.

Cinq plugins n'existaient qu'en binaire : `adminsmite`, `antirejoin`, `gift`, `noblock` et `ratechecker`. Ils ont été
inspectés (fonctions appelées, textes, commandes) et ne font rien d'anormal ; ils sont fournis tels quels.

## Crédits

- **Plugins** : Delachambre (DV) ; Steven (dernier CT, ouverture des cellules, plaintes, tags de clan) ; meng
  (SimpleSkins, TeamRatioControl, EvilDeagle, SpawnTools7) ; Fredd (CD Announcer) ; Bacardi (Country Filter) ;
  Nican132, CptMoore et Lebson506th (Spray Trace) ; exvel (Anti-Rejoin) ; Hipster (Admin Smite) ; sslice (No Block) ;
  pRED* (RateChecker) ; Raijojp (Global Gift).
- **Anti-cheat** : [SMAC](https://github.com/srcdslab/sm-plugin-SMAC) (SMAC Development Team, fork srcdslab) ;
  [Little Anti-Cheat](https://github.com/J-Tanzanite/Little-Anti-Cheat) (J_Tanzanite).
- **Includes** : morecolors (Dr. McKay), colors (exvel), convar_class (KiD).
- **Map, skins et sons** : leurs auteurs respectifs.
- **Remaster** (2026) : Panda.

## Licence

[GNU GPL v3](LICENSE) pour les plugins, comme SourceMod. La map, les skins et les sons restent la propriété de leurs
auteurs.
