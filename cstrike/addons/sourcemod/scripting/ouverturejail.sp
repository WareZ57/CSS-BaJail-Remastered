#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <morecolors>

float BUTTON_ORIGIN[3] = { -1392.0, -516.5, 136.72 };
bool g_Opened;

public Plugin myinfo =
{
	name = "JailAnnounce",
	author = "Steven",
	description = "Annonce qui a ouvert les cellules sur la razor v6",
	version = "1.1",
	url = ""
};

public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_Opened = false;
	char map[PLATFORM_MAX_PATH];
	GetCurrentMap(map, sizeof(map));
	if (StrContains(map, "ba_jail_electric_razor_v6") != 0)
	{
		return;
	}
	int ent = -1;
	float origin[3];
	while ((ent = FindEntityByClassname(ent, "func_button")) != -1)
	{
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", origin);
		if (GetVectorDistance(origin, BUTTON_ORIGIN) < 1.0)
		{
			HookSingleEntityOutput(ent, "OnIn", Output_CellsOpened);
		}
	}
}

public void Output_CellsOpened(const char[] output, int caller, int activator, float delay)
{
	if (g_Opened || activator < 1 || activator > MaxClients || !IsClientInGame(activator))
	{
		return;
	}
	g_Opened = true;
	if (GetClientTeam(activator) == CS_TEAM_CT)
	{
		CPrintToChatAll("{blue}[OUVERTURE] Les cellules ont été ouvertes par %N", activator);
		CPrintToChatAll("{blue}[OUVERTURE] Écoutez bien les ordres des gardiens.");
	}
	else
	{
		CPrintToChatAll("{red}[OUVERTURE] Les cellules ont été ouvertes par %N", activator);
		CPrintToChatAll("{red}[OUVERTURE] Les prisonniers ont quartier libre !");
	}
	PrintCenterTextAll("Cellules ouvertes par %N", activator);
}
