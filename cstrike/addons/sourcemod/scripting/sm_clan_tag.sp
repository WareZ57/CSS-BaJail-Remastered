#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <cstrike>

ConVar g_cvLeader;
ConVar g_cvAdmin;
ConVar g_cvVip;
ConVar g_cvPrivate1;
ConVar g_cvPrivate2;

public Plugin myinfo =
{
	name = "ClanTag Status",
	author = "Steven",
	description = "Modifier les clan tags",
	version = "1.1",
	url = ""
};

public void OnPluginStart()
{
	g_cvVip = CreateConVar("sm_tm_vip", "Vip", "Tag pour les vip (flag : s)");
	g_cvAdmin = CreateConVar("sm_tm_admin", "Admin", "Tag pour les admins (flag : a)");
	g_cvLeader = CreateConVar("sm_tm_leader", "Leader", "Tag pour les leaders (flag : t)");
	g_cvPrivate1 = CreateConVar("sm_tm_perso1", "Private", "Perso (flag : q)");
	g_cvPrivate2 = CreateConVar("sm_tm_perso2", "Private2", "Perso 2 (flag : p)");
	AutoExecConfig(true, "plugin_clantag");
	HookEvent("player_spawn", Event_PlayerSpawn);
}

public void OnClientSettingsChanged(int client)
{
	ApplyTag(client);
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	ApplyTag(GetClientOfUserId(event.GetInt("userid")));
}

void ApplyTag(int client)
{
	if (client == 0 || !IsClientInGame(client) || IsFakeClient(client))
	{
		return;
	}
	int flags = GetUserFlagBits(client);
	char tag[64];
	if (flags & ADMFLAG_CUSTOM6)
	{
		g_cvLeader.GetString(tag, sizeof(tag));
	}
	else if (flags & ADMFLAG_RESERVATION)
	{
		g_cvAdmin.GetString(tag, sizeof(tag));
	}
	else if (flags & ADMFLAG_CUSTOM5)
	{
		g_cvVip.GetString(tag, sizeof(tag));
	}
	else if (flags & ADMFLAG_CUSTOM3)
	{
		g_cvPrivate1.GetString(tag, sizeof(tag));
	}
	else if (flags & ADMFLAG_CUSTOM2)
	{
		g_cvPrivate2.GetString(tag, sizeof(tag));
	}
	CS_SetClientClanTag(client, tag);
}
