#include <sourcemod>
#include <autoexecconfig>
#include <gamecms_system>

int ga_iProfileID[MAXPLAYERS + 1] = {-1, ...};
int ga_iProfileRating[MAXPLAYERS + 1] = {-1, ...};
char ga_sProfileName[MAXPLAYERS + 1][30];
int ga_iPlayerShilings[MAXPLAYERS + 1] = {0, ...};
int ga_iProfileSale[MAXPLAYERS + 1] = {0, ...};
int ga_iDiscount = 0;
Database g_hGameCMSDatabase = null;
ConVar gcv_sGameCMSDatabase;
char g_sGameCMSDatabaseName[60];
//bool g_bLateLoad = false;
char ga_sAuthType[MAXPLAYERS + 1][30];

#include "gamecms_system/Natives.sp"
#include "gamecms_system/Database.sp"

public Plugin myinfo =
{
	name = "GameCMS System",
	author = "BaFeR",
	description = "GameCMS System for server",
	version = "1.1 [PUBLIC]"
};

public void OnPluginStart()
{
	AutoExecConfig_SetFile("gamecms_system");
	gcv_sGameCMSDatabase = AutoExecConfig_CreateConVar("sm_gamecms_system_db", "gamecms", "Имя базы данных для подключения к GameCMS.");
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	gcv_sGameCMSDatabase.GetString(g_sGameCMSDatabaseName, sizeof(g_sGameCMSDatabaseName));
	SetDB();
}

public void OnConfigsExecuted()
{
	if (g_hGameCMSDatabase == null)
	{
		SetDB();
	}
}

public void SQLCallback_Check_Client_Rubles(Database db, DBResultSet results, const char[] error, int iClient)
{
	if (db == null)
	{
		SetDB();
	}
	if (results == null)
	{
		LogError(error);
		return;
	}

	if (!IsValidClient(iClient))
	{
		return;
	}
	else 
	{
		if(results.RowCount == 1 && results.FetchRow())
		{
			ga_iPlayerShilings[iClient] = results.FetchInt(0);
		}
	}
}

public OnClientAuthorized(iClient, const String:auth[])
{
	if (g_hGameCMSDatabase == INVALID_HANDLE)
		return;
	/* Do not check bots nor check player with lan steamid. */
	if (auth[0] == 'B' || auth[9] == 'L')
		return;
	
	strcopy(ga_sAuthType[iClient], sizeof(ga_sAuthType), auth[8]);
	char sQuery[300];
	Format(sQuery, sizeof(sQuery), "SELECT `shilings`, `id`, `login`, `proc`, `reit` FROM `users` WHERE `steam_id` REGEXP '^STEAM_[0-9]:%s$';", ga_sAuthType[iClient]);
	g_hGameCMSDatabase.Query(SQLCallback_GetClientInfo, sQuery, GetClientUserId(iClient));
}

public void SQLCallback_GetClientInfo(Database db, DBResultSet results, const char[] error, int data)
{
	if (db == null)
	{
		SetDB();
	}
	if (results == null)
	{
		LogError(error);
		return;
	}

	int iClient = GetClientOfUserId(data);
	if (results.RowCount == 1)
	{
		results.FetchRow();
		ga_iPlayerShilings[iClient] = results.FetchInt(0);
		ga_iProfileID[iClient] = results.FetchInt(1);
		results.FetchString(2, ga_sProfileName[iClient], sizeof(ga_sProfileName));
		ga_iProfileSale[iClient] = results.FetchInt(3);
		ga_iProfileRating[iClient] = results.FetchInt(4); 
	}
}

public void SQLCallback_GetGlobalDiscount(Database db, DBResultSet results, const char[] error, int data)
{
	if (db == null)
	{
		SetDB();
	}
	if (results == null)
	{
		LogError(error);
		return;
	}
	
	if (results.RowCount == 1)
	{
		results.FetchRow();
		ga_iDiscount = results.FetchInt(0);
	}
}

public Action SetClientRubles(int iClient, int shilings)
{
	char sQuery[300];
	
	ga_iPlayerShilings[iClient] = shilings;
	//char Balance[10];
	//Format(Balance, sizeof(Balance), "%i", shilings);
	
	Format(sQuery, sizeof(sQuery), "UPDATE `users` SET `shilings` = '%i' WHERE `steam_id` REGEXP '^STEAM_[0-9]:%s$';", shilings, ga_sAuthType[iClient]);
	g_hGameCMSDatabase.Query(SQLCallback_Void, sQuery);
	
	return;
}

public void OnClientDisconnect(int iClient)
{
	ga_iProfileID[iClient] = -1;
	ga_iProfileRating[iClient] = -1;
	ga_sProfileName[iClient] = "";
	ga_iPlayerShilings[iClient] = 0;
	ga_iProfileSale[iClient] = 0;
}

public void OnMapEnd()
{
	g_hGameCMSDatabase = null;
}

bool IsValidClient(int iClient, bool bAllowBots = false, bool bAllowDead = true)
{
	if (!(1 <= iClient <= MaxClients) || !IsClientInGame(iClient) || (IsFakeClient(iClient) && !bAllowBots) || IsClientSourceTV(iClient) || IsClientReplay(iClient) || (!bAllowDead && !IsPlayerAlive(iClient)))
	{
		return false;
	}
	return true;
}