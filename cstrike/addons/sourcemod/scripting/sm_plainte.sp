#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <morecolors>

#define SOUND_PLAINTE "buttons/blip2.wav"
#define DELAY 60

int g_LastComplaint[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "Système de plainte",
	author = "Steven",
	description = "Permet aux utilisateurs de se plaindre",
	version = "1.1",
	url = ""
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_plainte", Command_Plainte, "Envoyer une plainte aux admins : !plainte <message>");
	RegConsoleCmd("plainte", Command_Plainte, "Envoyer une plainte aux admins : plainte <message>");
}

public void OnMapStart()
{
	PrecacheSound(SOUND_PLAINTE, true);
}

public void OnClientConnected(int client)
{
	g_LastComplaint[client] = 0;
}

public Action Command_Plainte(int client, int args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "[SM] Commande réservée aux joueurs.");
		return Plugin_Handled;
	}
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Utilisation : !plainte <message complet>");
		return Plugin_Handled;
	}
	int wait = g_LastComplaint[client] + DELAY - GetTime();
	if (wait > 0)
	{
		ReplyToCommand(client, "[SM] Vous devez attendre %d secondes avant de refaire une plainte.", wait);
		return Plugin_Handled;
	}
	g_LastComplaint[client] = GetTime();

	char message[192];
	GetCmdArgString(message, sizeof(message));
	StripQuotes(message);
	CRemoveTags(message, sizeof(message));
	LogAction(client, -1, "\"%L\" plainte : %s", client, message);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && CheckCommandAccess(i, "sm_plainte_admin", ADMFLAG_SLAY, true))
		{
			CPrintToChat(i, "{red} *** [PLAINTE] de {green}%N{red} :{default} %s", client, message);
			EmitSoundToClient(i, SOUND_PLAINTE);
		}
	}
	CPrintToChat(client, "{blue} *** Votre plainte a bien été envoyée, merci d'être patient...");
	return Plugin_Handled;
}
