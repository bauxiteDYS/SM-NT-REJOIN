#include <sourcemod>
#include <sdktools>

int g_playerTeam[32+1];
int g_clientUserId[32+1];
bool g_retry[32+1];

public Plugin myinfo = {
	name = "NT Rejoin",
	description = "Use !retry or !rejoin to rejoin server, then join any team to automatically join the team you were on before",
	author = "bauxite",
	version = "0.2.1",
	url = "https://github.com/bauxiteDYS/SM-NT-ReJoin",
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_retry", Cmd_Retry);
	RegConsoleCmd("sm_rejoin", Cmd_Retry);
	AddCommandListener(OnTeam, "jointeam");
}

public Action Cmd_Retry(int client, int args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "This command cannot be used by the server.");
		return Plugin_Handled;
	}
	
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	g_playerTeam[client] = GetClientTeam(client);
	g_clientUserId[client] = GetClientUserId(client);
	g_retry[client] = true;
	ReconnectClient(client);
	return Plugin_Continue;
}

public Action OnTeam(int client, const char[] command, int argc)
{
	if(argc != 1 || !g_retry[client])
	{
		return Plugin_Continue;
	}
	
	if(!IsClientInGame(client))
	{
		return Plugin_Continue;
	}
	
	if(g_clientUserId[client] != GetClientUserId(client))
	{
		return Plugin_Continue;
	}
	
	int iTeam = GetCmdArgInt(1);
	if(iTeam >= 0 && g_playerTeam[client] > 0)
	{
		FakeClientCommandEx(client, "jointeam %d", g_playerTeam[client]);
		ResetClient(client);
		return Plugin_Handled;
	}
	
	ResetClient(client);
	return Plugin_Continue;
}

void ResetClient(int client)
{
	g_retry[client] = false;
	g_playerTeam[client] = 0;
}


// Backported from SourceMod/SourcePawn SDK for SM 1.8-1.10 compatibility.
// Used here under GPLv3 license: https://www.sourcemod.net/license.php
// SourceMod (C)2004-2023 AlliedModders LLC.  All rights reserved.

#if SOURCEMOD_V_MAJOR == 1 && SOURCEMOD_V_MINOR <= 10

/**
 * Retrieves a numeric command argument given its index, from the current
 * console or server command. Will return 0 if the argument can not be
 * parsed as a number. Use GetCmdArgIntEx to handle that explicitly.
 *
 * @param argnum        Argument number to retrieve.
 * @return              Value of the command argument.
 */

stock int GetCmdArgInt(int argnum)
{
    char str[12];
    GetCmdArg(argnum, str, sizeof(str));

    return StringToInt(str);
}

#endif
