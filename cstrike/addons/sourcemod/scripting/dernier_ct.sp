#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <cstrike>

ConVar g_cvEnabled;
ConVar g_cvSound;
ConVar g_cvCenterMsg;
ConVar g_cvChatMsg;
ConVar g_cvSpy;
char g_Sound[PLATFORM_MAX_PATH];

public Plugin myinfo =
{
	name = "Plugin de dernier CT",
	author = "Steven",
	description = "Système de dernier ct",
	version = "1.1",
	url = ""
};

public void OnPluginStart()
{
	g_cvEnabled = CreateConVar("sm_dct_etat", "1", "Mode activé (1), ou désactivé (0)", _, true, 0.0, true, 1.0);
	g_cvSound = CreateConVar("sm_dct_sound", "dct.wav", "Son joué pour le dernier CT, dans sound/ (vide : aucun)");
	g_cvCenterMsg = CreateConVar("sm_dct_centermsg", "1", "Affiche un message au centre de l'écran", _, true, 0.0, true, 1.0);
	g_cvChatMsg = CreateConVar("sm_dct_chatmsg", "1", "Affiche un message dans le chat", _, true, 0.0, true, 1.0);
	g_cvSpy = CreateConVar("sm_dct_espion", "1", "Le dernier CT prend l'apparence d'un prisonnier", _, true, 0.0, true, 1.0);
	AutoExecConfig(true, "sm_dernier_ct");
	HookEvent("player_death", Event_PlayerDeath);
}

public void OnConfigsExecuted()
{
	g_cvSound.GetString(g_Sound, sizeof(g_Sound));
	if (g_Sound[0] != '\0')
	{
		char path[PLATFORM_MAX_PATH];
		FormatEx(path, sizeof(path), "sound/%s", g_Sound);
		AddFileToDownloadsTable(path);
		PrecacheSound(g_Sound, true);
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (!g_cvEnabled.BoolValue || victim == 0 || GetClientTeam(victim) != CS_TEAM_CT)
	{
		return;
	}
	int count = 0, last = 0, prisoner = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i))
		{
			continue;
		}
		if (GetClientTeam(i) == CS_TEAM_CT)
		{
			count++;
			last = i;
		}
		else if (GetClientTeam(i) == CS_TEAM_T && prisoner == 0)
		{
			prisoner = i;
		}
	}
	if (count != 1)
	{
		return;
	}
	bool spy = g_cvSpy.BoolValue && prisoner != 0;
	if (spy)
	{
		char model[PLATFORM_MAX_PATH];
		GetClientModel(prisoner, model, sizeof(model));
		SetEntityModel(last, model);
	}
	if (g_cvCenterMsg.BoolValue)
	{
		PrintCenterTextAll("==========> DERNIER CT <==========");
	}
	if (g_cvChatMsg.BoolValue)
	{
		PrintToChatAll("\x03======== DERNIER CT ========");
		PrintToChatAll("\x03Le dernier CT peut tuer tout le monde");
		if (spy)
		{
			PrintToChatAll("\x03Le dernier CT est un ESPION!!!");
		}
		PrintToChatAll("\x03======== DERNIER CT ========");
	}
	if (g_Sound[0] != '\0')
	{
		EmitSoundToAll(g_Sound, _, _, _, _, 0.9);
	}
}
