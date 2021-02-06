void SetDB()
{
	if(g_hGameCMSDatabase == null)
	{
		Database.Connect(SQLCallback_GameCMSConnect, g_sGameCMSDatabaseName);
	}
}

public void SQLCallback_GameCMSConnect(Database db, const char[] error, any data)
{
	if (db == null)
	{
		SetFailState(error);
	}
	else
	{
		g_hGameCMSDatabase = db;	
		
		g_hGameCMSDatabase.SetCharset("utf8");
	}
}

public void SQLCallback_Void(Database db, DBResultSet results, const char[] error, int data)
{
	if (db == null)
	{
		LogError("Error (%i): %s", data, error);
	}
}