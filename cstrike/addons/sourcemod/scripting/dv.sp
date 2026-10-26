#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <morecolors>

#define MAP_PREFIX "ba_jail_electric_razor_v6"
#define ASK_TIME 20
#define FREEZE_SAFETY 25.0

enum
{
	DUEL_ROULETTE, DUEL_ROULETTEC, DUEL_CUT, DUEL_CUTA, DUEL_LANCER, DUEL_AWP, DUEL_SCOUT, DUEL_PLANCHE, DUEL_BASKET,
	DUEL_ISO, DUEL_BROCHETTE,
	DUEL_COUNT
}

char DUEL_KEY[DUEL_COUNT][] = { "roulette", "roulettec", "cut", "cutaqua", "lancer", "awpunscop", "scoutunscop", "planche", "basket", "iso", "brochette" };
char DUEL_LABEL[DUEL_COUNT][] = { "Roulette normale", "Roulette chinoise", "Cut", "Cut aqua", "Lancer de Deagle", "Unscop awp", "Unscop scout", "Planche pirate", "Basket", "Isoloire", "Brochette" };
char DUEL_TITLE[DUEL_COUNT][] = { "ROULETTE", "ROULETTE CHINOISE", "CUT", "CUT AQUATIQUE", "LANCER DE DEAGLE", "AWP UNSCOP", "SCOUT UNSCOP", "PLANCHE PIRATE", "BASKET", "ISOLOIRE", "BROCHETTE" };
char DUEL_WEAPONS_T[DUEL_COUNT][] = { "weapon_deagle", "weapon_deagle", "weapon_knife", "weapon_knife", "weapon_deagle", "weapon_awp weapon_knife", "weapon_scout weapon_knife", "weapon_deagle", "weapon_deagle", "weapon_m249", "weapon_awp" };
char DUEL_WEAPONS_CT[DUEL_COUNT][] = { "weapon_deagle", "weapon_deagle", "weapon_knife", "weapon_knife", "weapon_deagle", "weapon_awp weapon_knife", "weapon_scout weapon_knife", "weapon_deagle", "weapon_deagle", "weapon_m249", "weapon_m4a1" };
int DUEL_HEALTH_T[DUEL_COUNT] = { 100, 100, 100, 100, 100, 100, 100, 100, 100, 200, 200 };
int DUEL_MIN_CT[DUEL_COUNT] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3 };
bool DUEL_NO_SCOPE[DUEL_COUNT] = { false, false, false, false, false, true, true, false, false, false, false };
bool DUEL_NO_AMMO[DUEL_COUNT] = { false, false, false, false, true, false, false, false, true, false, false };
float DUEL_POS_T[DUEL_COUNT][3] =
{
	{ -117.584900, -27.542044, 166.266113 }, { -1226.435059, 248.974121, 333.248260 }, { -783.076843, 1122.890869, 189.717834 },
	{ -102.747711, 2525.996338, 470.739746 }, { -209.728485, 646.808472, 352.354126 }, { -949.380859, -1322.519653, 170.988571 },
	{ -949.380859, -1322.519653, 170.988571 }, { -378.468689, 2407.950195, 245.158951 }, { -1131.6, -1851.8, 167.7 },
	{ -1306.829956, -1288.941162, 159.888565 }, { -1413.317139, -370.523987, 120.848633 }
};
float DUEL_POS_CT[DUEL_COUNT][3] =
{
	{ -89.117271, 461.912903, 207.890594 }, { -971.038757, 252.610458, 176.185608 }, { -915.521240, -279.360413, 192.057343 },
	{ 380.532867, 2541.498779, 386.600800 }, { -177.034500, 952.953674, 346.466919 }, { -699.704346, 1419.086060, 166.977066 },
	{ -699.704346, 1419.086060, 166.977066 }, { -376.232117, 2655.843262, 245.158951 }, { -1130.4, -1689.9, 167.7 },
	{ -1436.584717, -723.069275, 115.047409 }, { -565.548767, -375.095123, 172.647568 }
};

ConVar g_cvSoundAvailable;
ConVar g_cvSoundAccepted;
ConVar g_cvSoundRefused;
ConVar g_cvSoundDuel[DUEL_COUNT];
char g_SoundAvailable[PLATFORM_MAX_PATH];
char g_SoundAccepted[PLATFORM_MAX_PATH];
char g_SoundRefused[PLATFORM_MAX_PATH];
char g_SoundDuel[DUEL_COUNT][PLATFORM_MAX_PATH];

bool g_MapOk;
bool g_DvOpen;
bool g_Frozen;
bool g_InDuel[MAXPLAYERS + 1];
int g_DuelOf[MAXPLAYERS + 1];
int g_Round;
Handle g_FreezeTimer;

public Plugin myinfo =
{
	name = "*~ Plugin DV ~*",
	author = "Delachambre",
	description = "Dernière Volonté du dernier prisonnier",
	version = "2.0",
	url = ""
};

public void OnPluginStart()
{
	g_cvSoundAvailable = CreateConVar("sm_dv_son_dispo", "Jail/dv.wav", "Son quand la DV est disponible (vide : aucun)");
	g_cvSoundAccepted = CreateConVar("sm_dv_son_accepte", "Jail/dvacceptee.wav", "Son quand le prisonnier accepte sa DV (vide : aucun)");
	g_cvSoundRefused = CreateConVar("sm_dv_son_refuse", "Jail/dvrefusee.wav", "Son quand le prisonnier refuse sa DV (vide : aucun)");
	char name[64], description[128];
	for (int d = 0; d < DUEL_COUNT; d++)
	{
		FormatEx(name, sizeof(name), "sm_dv_son_%s", DUEL_KEY[d]);
		FormatEx(description, sizeof(description), "Son au début de la DV %s (vide : aucun)", DUEL_LABEL[d]);
		g_cvSoundDuel[d] = CreateConVar(name, "Jail/dvstart.wav", description);
	}
	AutoExecConfig(true, "dv");

	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	RegConsoleCmd("sm_dv", Command_Dv, "Dernière Volonté : choisir son duel (dernier prisonnier en vie)");
}

public void OnMapStart()
{
	char map[PLATFORM_MAX_PATH];
	GetCurrentMap(map, sizeof(map));
	g_MapOk = StrContains(map, MAP_PREFIX) == 0;
	g_FreezeTimer = null;
}

public void OnConfigsExecuted()
{
	LoadSound(g_cvSoundAvailable, g_SoundAvailable);
	LoadSound(g_cvSoundAccepted, g_SoundAccepted);
	LoadSound(g_cvSoundRefused, g_SoundRefused);
	for (int d = 0; d < DUEL_COUNT; d++)
	{
		LoadSound(g_cvSoundDuel[d], g_SoundDuel[d]);
	}
}

static void LoadSound(ConVar cvar, char sound[PLATFORM_MAX_PATH])
{
	cvar.GetString(sound, sizeof(sound));
	if (sound[0] == '\0')
	{
		return;
	}
	char path[PLATFORM_MAX_PATH];
	FormatEx(path, sizeof(path), "sound/%s", sound);
	AddFileToDownloadsTable(path);
	PrecacheSound(sound, true);
}

static void PlaySound(const char[] sound, float volume = 0.9)
{
	if (sound[0] != '\0')
	{
		EmitSoundToAll(sound, _, _, _, _, volume);
	}
}

public void OnClientDisconnect(int client)
{
	g_InDuel[client] = false;
	if (g_Frozen && client == LastPrisoner())
	{
		Unfreeze();
	}
}

int CountAlive(int team, int &last = 0)
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
		{
			count++;
			last = i;
		}
	}
	return count;
}

int LastPrisoner()
{
	int last = 0;
	return CountAlive(CS_TEAM_T, last) == 1 ? last : 0;
}

static void Announce()
{
	PrintCenterTextAll("===> DERNIÈRE VOLONTÉ <===");
	CPrintToChatAll("{red}===> DERNIÈRE VOLONTÉ <===");
	CPrintToChatAll("{red}===> Tapez !dv <===");
	CPrintToChatAll("{red}===> DERNIÈRE VOLONTÉ <===");
	ServerCommand("sm_tsay yellow Dernière Volonté !");
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_Round++;
	Unfreeze();
	for (int i = 1; i <= MaxClients; i++)
	{
		g_InDuel[i] = false;
	}
	g_DvOpen = g_MapOk && LastPrisoner() != 0;
	if (g_DvOpen)
	{
		Announce();
		PlaySound(g_SoundAvailable);
	}
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_DvOpen = false;
	Unfreeze();
	for (int i = 1; i <= MaxClients; i++)
	{
		g_InDuel[i] = false;
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (victim == 0)
	{
		return;
	}
	if (g_InDuel[victim])
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			g_InDuel[i] = false;
		}
		g_DvOpen = false;
	}
	if (g_Frozen && victim == LastPrisoner())
	{
		Unfreeze();
	}
	if (!g_MapOk || GetClientTeam(victim) != CS_TEAM_T)
	{
		return;
	}
	int last = LastPrisoner();
	if (last == 0 || g_DvOpen)
	{
		return;
	}
	g_DvOpen = true;
	Announce();
	PlaySound(g_SoundAvailable, 1.0);
	g_Frozen = true;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) > CS_TEAM_SPECTATOR)
		{
			SetEntityMoveType(i, MOVETYPE_NONE);
		}
	}
	delete g_FreezeTimer;
	g_FreezeTimer = CreateTimer(FREEZE_SAFETY, Timer_FreezeSafety);

	Menu menu = new Menu(Menu_Ask);
	menu.SetTitle("Voulez-vous votre Dernière Volonté ?");
	char info[16];
	FormatEx(info, sizeof(info), "o%d", g_Round);
	menu.AddItem(info, "Oui je veux !");
	FormatEx(info, sizeof(info), "n%d", g_Round);
	menu.AddItem(info, "Non je refuse !");
	menu.ExitButton = false;
	menu.Display(last, ASK_TIME);
}

public Action Timer_FreezeSafety(Handle timer)
{
	g_FreezeTimer = null;
	Unfreeze();
	return Plugin_Stop;
}

void Unfreeze()
{
	delete g_FreezeTimer;
	if (!g_Frozen)
	{
		return;
	}
	g_Frozen = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetEntityMoveType(i) == MOVETYPE_NONE)
		{
			SetEntityMoveType(i, MOVETYPE_WALK);
		}
	}
}

public int Menu_Ask(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[16];
		menu.GetItem(param2, info, sizeof(info));
		Unfreeze();
		if (StringToInt(info[1]) != g_Round || client != LastPrisoner())
		{
			return 0;
		}
		if (info[0] == 'o')
		{
			CPrintToChatAll("Le joueur %N \x04accepte sa DV !", client);
			PlaySound(g_SoundAccepted, 1.0);
			ShowDuelMenu(client);
		}
		else
		{
			CPrintToChatAll("Le joueur %N \x04refuse sa DV !", client);
			PlaySound(g_SoundRefused, 1.0);
			g_DvOpen = false;
		}
	}
	else if (action == MenuAction_Cancel)
	{
		Unfreeze();
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
	return 0;
}

static bool CanChoose(int client, bool quiet = false)
{
	char error[96];
	if (!g_MapOk)
	{
		strcopy(error, sizeof(error), "La DV n'existe que sur la map ba_jail_electric_razor_v6.");
	}
	else if (!IsPlayerAlive(client))
	{
		strcopy(error, sizeof(error), "Vous devez être vivant.");
	}
	else if (GetClientTeam(client) != CS_TEAM_T)
	{
		strcopy(error, sizeof(error), "Vous n'avez pas accès à cette commande.");
	}
	else if (!g_DvOpen || client != LastPrisoner())
	{
		strcopy(error, sizeof(error), "Vous n'êtes pas en dernière volonté.");
	}
	else if (g_InDuel[client])
	{
		strcopy(error, sizeof(error), "Vous êtes déjà en DV.");
	}
	else
	{
		return true;
	}
	if (!quiet)
	{
		CPrintToChat(client, "{red}%s", error);
	}
	return false;
}

public Action Command_Dv(int client, int args)
{
	if (client == 0 || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	if (CanChoose(client))
	{
		ShowDuelMenu(client);
	}
	return Plugin_Handled;
}

static void ShowDuelMenu(int client)
{
	if (!CanChoose(client))
	{
		return;
	}
	int guards = CountAlive(CS_TEAM_CT);
	char info[16];
	Menu menu = new Menu(Menu_Duel);
	menu.SetTitle("Choisis ta DV :");
	for (int d = DUEL_ISO; d < DUEL_COUNT; d++)
	{
		FormatEx(info, sizeof(info), "%d %d", g_Round, d);
		menu.AddItem(info, DUEL_LABEL[d], guards >= DUEL_MIN_CT[d] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	for (int d = 0; d < DUEL_ISO; d++)
	{
		FormatEx(info, sizeof(info), "%d %d", g_Round, d);
		menu.AddItem(info, DUEL_LABEL[d], guards >= DUEL_MIN_CT[d] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_Duel(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[16], parts[2][8];
		menu.GetItem(param2, info, sizeof(info));
		ExplodeString(info, " ", parts, sizeof(parts), sizeof(parts[]));
		int duel = StringToInt(parts[1]);
		if (StringToInt(parts[0]) != g_Round || duel < 0 || duel >= DUEL_COUNT || !CanChoose(client))
		{
			return 0;
		}
		if (CountAlive(CS_TEAM_CT) < DUEL_MIN_CT[duel])
		{
			CPrintToChat(client, "{red}Pas assez de gardiens en vie pour cette DV.");
			return 0;
		}
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		CPrintToChatAll("{blue}===> DV %s <===", DUEL_TITLE[duel]);
		PrintCenterTextAll("===> DV %s <===", DUEL_TITLE[duel]);
		if (duel >= DUEL_ISO)
		{
			StartGroupDuel(client, duel);
		}
		else
		{
			ShowGuardMenu(client, duel);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
	return 0;
}

static void ShowGuardMenu(int client, int duel)
{
	char info[24];
	Menu menu = new Menu(Menu_Guard);
	menu.SetTitle("Choisis le joueur :");
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT)
		{
			FormatEx(info, sizeof(info), "%d %d %d", g_Round, duel, GetClientUserId(i));
			char display[MAX_NAME_LENGTH];
			GetClientName(i, display, sizeof(display));
			menu.AddItem(info, display);
		}
	}
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_Guard(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[24], parts[3][12];
		menu.GetItem(param2, info, sizeof(info));
		ExplodeString(info, " ", parts, sizeof(parts), sizeof(parts[]));
		int duel = StringToInt(parts[1]);
		int guard = GetClientOfUserId(StringToInt(parts[2]));
		if (StringToInt(parts[0]) != g_Round || duel < 0 || duel >= DUEL_ISO || !CanChoose(client))
		{
			return 0;
		}
		if (guard == 0 || !IsPlayerAlive(guard) || GetClientTeam(guard) != CS_TEAM_CT)
		{
			CPrintToChat(client, "{red}Ce gardien n'est plus disponible.");
			ShowGuardMenu(client, duel);
			return 0;
		}
		Prepare(client, duel, true);
		Prepare(guard, duel, false);
		g_InDuel[client] = true;
		g_InDuel[guard] = true;
		PlaySound(g_SoundDuel[duel]);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
	return 0;
}

static void StartGroupDuel(int client, int duel)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT)
		{
			Prepare(i, duel, false);
			g_InDuel[i] = true;
		}
	}
	Prepare(client, duel, true);
	g_InDuel[client] = true;
	PlaySound(g_SoundDuel[duel]);
}

static void Prepare(int client, int duel, bool prisoner)
{
	g_DuelOf[client] = duel;
	TeleportEntity(client, prisoner ? DUEL_POS_T[duel] : DUEL_POS_CT[duel], NULL_VECTOR, NULL_VECTOR);
	Disarm(client);
	char weapons[4][32];
	int count = ExplodeString(prisoner ? DUEL_WEAPONS_T[duel] : DUEL_WEAPONS_CT[duel], " ", weapons, sizeof(weapons), sizeof(weapons[]));
	for (int w = 0; w < count; w++)
	{
		int weapon = GivePlayerItem(client, weapons[w]);
		if (weapon == -1)
		{
			continue;
		}
		SetEntityRenderColor(weapon, prisoner ? 255 : 0, prisoner ? 64 : 0, prisoner ? 64 : 205, 255);
		if (DUEL_NO_AMMO[duel] && HasEntProp(weapon, Prop_Send, "m_iClip1"))
		{
			SetEntProp(weapon, Prop_Send, "m_iClip1", 0);
			int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
			if (ammoType >= 0)
			{
				SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, ammoType);
			}
		}
	}
	SetEntityHealth(client, prisoner ? DUEL_HEALTH_T[duel] : 100);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!(buttons & IN_ATTACK2) || !g_InDuel[client] || !DUEL_NO_SCOPE[g_DuelOf[client]])
	{
		return Plugin_Continue;
	}
	int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	char classname[32];
	if (active != -1 && GetEntityClassname(active, classname, sizeof(classname))
	 && (StrEqual(classname, "weapon_awp") || StrEqual(classname, "weapon_scout")))
	{
		buttons &= ~IN_ATTACK2;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

static void Disarm(int client)
{
	for (int slot = 0; slot < 6; slot++)
	{
		int weapon;
		while ((weapon = GetPlayerWeaponSlot(client, slot)) != -1)
		{
			RemovePlayerItem(client, weapon);
			AcceptEntityInput(weapon, "Kill");
		}
	}
}
