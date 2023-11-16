#include <sourcemod>
#include <sdktools>

Handle join_timer[32+1];

int player_team[32+1];
int timer_count[32+1];

public Plugin myinfo = {
	name = "NT Rejoin",
	description = "Use !re to rejoin server, then join spec to automatically join the team you were on before",
	author = "bauxite",
	version = "0.1.7",
	url = "https://github.com/bauxiteDYS/SM-NT-ReJoin",
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_re", Cmd_Retry);
}

public Action Cmd_Retry(int client, int args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "This command cannot be used by the server.");
		return Plugin_Handled;
	}
	
	player_team[client] = GetClientTeam(client);
 
	ReconnectClient(client);

	join_timer[client] = CreateTimer(0.75, Timer_ReJoin, client, TIMER_REPEAT);
	
	return Plugin_Handled;
}

public Action Timer_ReJoin(Handle timer, int client)
{
	timer_count[client]++;
	
	if (!IsValidHandle(timer)
	{
    		return Plugin_Stop;
	}
	
	if (IsClientInGame(client))
	{
		if (GetClientTeam(client) == 2 || GetClientTeam(client) == 3)
		{	
			timer_count[client] = 0;
		
			return Plugin_Stop;
		}
	
		if (GetClientTeam(client) == 1)
		{
			FakeClientCommand(client, "jointeam %d", player_team[client]);
			timer_count[client] = 0;
		
			return Plugin_Stop;
		}
	}
	
	if (timer_count[client] == 30) 
	{
		timer_count[client] = 0;

		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}
