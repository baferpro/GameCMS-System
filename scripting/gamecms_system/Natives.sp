public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int err_max)
{
	CreateNative("GameCMS_GetDatabase", Native_GetDatabase);
	CreateNative("GameCMS_Registered", Native_Registered);
	CreateNative("GameCMS_GetClientID", Native_GetClientID);
	CreateNative("GameCMS_GetClientRating", Native_GetClientRating);
	CreateNative("GameCMS_GetClientName", Native_GetClientName);
	CreateNative("GameCMS_GetClientRubles", Native_GetClientRubles);
	CreateNative("GameCMS_SetClientRubles", Native_SetClientRubles);
	CreateNative("GameCMS_GetClientDiscount", Native_GetClientDiscount);
	CreateNative("GameCMS_GetGlobalDiscount", Native_GetGlobalDiscount);
	CreateNative("GameCMS_SendNotification", Native_SendNotification);
	RegPluginLibrary("gamecms_system");
	return APLRes_Success;
}

public int Native_GetDatabase(Handle hPlugin, int iNumParams)
{
	return view_as<int>(CloneHandle(gcv_sGameCMSDatabase, hPlugin));
}

public int Native_Registered(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	if (!IsValidClient(iClient))
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid iClient index (%i)", iClient);
	if(ga_iProfileID[iClient] != -1)
		return 1;
	else
		return 0;
}

public int Native_GetClientID(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	if (!IsValidClient(iClient))
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid iClient index (%i)", iClient);
	return view_as<int>(ga_iProfileID[iClient]);
}

public int Native_GetClientRating(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	if (!IsValidClient(iClient))
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid iClient index (%i)", iClient);
	return view_as<int>(ga_iProfileRating[iClient]);
}

public int Native_GetClientName(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	if (!IsValidClient(iClient))
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid iClient index (%i)", iClient);
	SetNativeString(2, ga_sProfileName[iClient], GetNativeCell(3));
	return 0;
}

public int Native_GetClientRubles(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	if (!IsValidClient(iClient))
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid iClient index (%i)", iClient);
	return view_as<int>(ga_iPlayerShilings[iClient]);
}

public int Native_SetClientRubles(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	int Cash = GetNativeCell(2);
	if (!IsValidClient(iClient))
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid iClient index (%i)", iClient);
	SetClientRubles(iClient, Cash);
	return 0;
}

public int Native_GetClientDiscount(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	if (!IsValidClient(iClient))
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid iClient index (%i)", iClient);
	return view_as<int>(ga_iProfileSale[iClient]);
}

public int Native_GetGlobalDiscount(Handle plugin, int numParams)
{
	return view_as<int>(ga_iDiscount);
}

public int Native_SendNotification(Handle plugin, int numParams)
{
	char sMessage[256];
	int iClient = GetNativeCell(1);
	GetNativeString(2, sMessage, sizeof(sMessage));
	
	if (!IsValidClient(iClient))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid iClient index (%i)", iClient);
	}
	
	char sQuery[300], time[64];
	FormatTime(time, sizeof(time), "%Y-%m-%d %T");
	Format(sQuery, sizeof(sQuery), "INSERT INTO `notifications` (`message`,`date`,`user_id`,`status`,`type`) VALUES('%s','%s','%i','0','2');", sMessage, time, ga_iProfileID[iClient]);
	g_hGameCMSDatabase.Query(SQLCallback_Void, sQuery);
	
	return 0;
}