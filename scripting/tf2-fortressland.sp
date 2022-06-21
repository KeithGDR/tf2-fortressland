/*****************************/
//Pragma
#pragma semicolon 1
#pragma newdecls required

/*****************************/
//Defines
#define PLUGIN_NAME "[TF2] Fortressland"
#define PLUGIN_DESCRIPTION "A Dungeon Land-like gamemode for Team Fortress 2."
#define PLUGIN_VERSION "1.0.3"

#define NO_MASTER -1

#define	SHAKE_START 0				// Starts the screen shake for all players within the radius.
#define	SHAKE_STOP 1				// Stops the screen shake for all players within the radius.
#define	SHAKE_AMPLITUDE 2			// Modifies the amplitude of an active screen shake for all players within the radius.
#define	SHAKE_FREQUENCY 3			// Modifies the frequency of an active screen shake for all players within the radius.
#define	SHAKE_START_RUMBLEONLY 4	// Starts a shake effect that only rumbles the controller, no screen effect.
#define	SHAKE_START_NORUMBLE 5		// Starts a shake that does NOT rumble the controller.

/*****************************/
//Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>

#include <hud>
#include <tf2items>
#include <colors>

/*****************************/
//ConVars
ConVar convar_DistanceCheck;

/*****************************/
//Globals

enum TF2Quality {
	TF2Quality_Normal = 0, // 0
	TF2Quality_Rarity1,
	TF2Quality_Genuine = 1,
	TF2Quality_Rarity2,
	TF2Quality_Vintage,
	TF2Quality_Rarity3,
	TF2Quality_Rarity4,
	TF2Quality_Unusual = 5,
	TF2Quality_Unique,
	TF2Quality_Community,
	TF2Quality_Developer,
	TF2Quality_Selfmade,
	TF2Quality_Customized, // 10
	TF2Quality_Strange,
	TF2Quality_Completed,
	TF2Quality_Haunted,
	TF2Quality_ToborA
};

Handle g_hSDKEquipWearable;

enum struct PlayerData {
	int client;
	char class[32];

	int points;
	float pointstimer;

	int curses;
	float cursestimer;
	
	void Initialize(int client) {
		this.client = client;
		this.class[0] = '\0';
		this.points = 0;
		this.pointstimer = -1.0;
		this.curses = 0;
		this.cursestimer = -1.0;
	}

	void Reset() {
		this.client = -1;
		this.class[0] = '\0';
		this.points = 0;
		this.pointstimer = -1.0;
		this.curses = 0;
		this.cursestimer = -1.0;
	}
	
	void SetPoints(int value) {
		this.points = value;
	}
	
	void AddPoints(int value) {
		this.points += value;
	}
	
	bool RemovePoints(int value) {
		if (value > this.points) {
			return false;
		}
		
		this.points -= value;
		return true;
	}

	void SetClass(const char[] class) {
		strcopy(this.class, 32, class);
		this.ApplyClass();
	}

	bool HasClass() {
		return strlen(this.class) > 0;
	}

	bool IsClass(const char[] class) {
		return StrEqual(this.class, class, false);
	}

	void ApplyClass() {
		// menu.AddItem("knight", "Knight"); //DemoMan
		// menu.AddItem("fighter", "Fighter"); //Heavy
		// menu.AddItem("outrider", "Outrider"); //Scout
		// menu.AddItem("ranger", "Ranger"); //Sniper
		// menu.AddItem("cleric", "Cleric"); //Medic
		// menu.AddItem("rogue", "Rogue"); //Spy
		// menu.AddItem("mage", "Mage"); //Pyro
		// menu.AddItem("samurai", "Samurai"); //Soldier

		if (StrEqual(this.class, "knight", false)) {

			TF2_SetPlayerClass(this.client, TFClass_DemoMan);
			TF2_RegeneratePlayer(this.client);

			TF2_RemoveAllWeapons(this.client);
			TF2_RemoveAllWearables(this.client);

			int booties = TF2_GiveItem(this.client, "tf_wearable", 405, TF2Quality_Unique, 10, "246 ; 2.0 ; 26 ; 25.0");
			Call_Wearable(this.client, booties);
			int shield = TF2_GiveItem(this.client, "tf_wearable_demoshield", 131, TF2Quality_Unique, 10, "60 ; 0.5 ; 64 ; 0.6");
			Call_Wearable(this.client, shield);
			TF2_GiveItem(this.client, "tf_weapon_sword", 132);

		} else if (StrEqual(this.class, "fighter", false)) {

			TF2_SetPlayerClass(this.client, TFClass_Heavy);
			TF2_RegeneratePlayer(this.client);

			TF2_RemoveAllWeapons(this.client);
			TF2_RemoveAllWearables(this.client);

			TF2_GiveItem(this.client, "tf_weapon_lunchbox", 433);
			TF2_GiveItem(this.client, "tf_weapon_fists", 331);

		} else if (StrEqual(this.class, "outrider", false)) {

			TF2_SetPlayerClass(this.client, TFClass_Scout);
			TF2_RegeneratePlayer(this.client);

			TF2_RemoveAllWeapons(this.client);
			TF2_RemoveAllWearables(this.client);

			TF2_GiveItem(this.client, "tf_weapon_handgun_scout_primary", 220);
			TF2_GiveItem(this.client, "tf_weapon_lunchbox_drink", 163);
			TF2_GiveItem(this.client, "tf_weapon_bat", 452);

		} else if (StrEqual(this.class, "ranger", false)) {

			TF2_SetPlayerClass(this.client, TFClass_Sniper);
			TF2_RegeneratePlayer(this.client);

			TF2_RemoveAllWeapons(this.client);
			TF2_RemoveAllWearables(this.client);

			TF2_GiveItem(this.client, "tf_weapon_compound_bow", 56);
			int shield = TF2_GiveItem(this.client, "tf_wearable", 231, TF2Quality_Unique, 10, "26 ; 25");
			Call_Wearable(this.client, shield);
			TF2_GiveItem(this.client, "tf_weapon_club", 171);

		} else if (StrEqual(this.class, "cleric", false)) {

			TF2_SetPlayerClass(this.client, TFClass_Medic);
			TF2_RegeneratePlayer(this.client);

			TF2_RemoveAllWeapons(this.client);
			TF2_RemoveAllWearables(this.client);

			TF2_GiveItem(this.client, "tf_weapon_crossbow", 305);
			//TF2_GiveItem(this.client, "tf_weapon_lunchbox_drink", 163);
			TF2_GiveItem(this.client, "tf_weapon_bonesaw", 413);

		} else if (StrEqual(this.class, "rogue", false)) {

			TF2_SetPlayerClass(this.client, TFClass_Spy);
			TF2_RegeneratePlayer(this.client);

			TF2_RemoveAllWeapons(this.client);
			TF2_RemoveAllWearables(this.client);

			TF2_GiveItem(this.client, "tf_weapon_revolver", 525);
			TF2_GiveItem(this.client, "tf_weapon_builder", 735);
			TF2_GiveItem(this.client, "tf_weapon_knife", 461);

		} else if (StrEqual(this.class, "mage", false)) {

			TF2_SetPlayerClass(this.client, TFClass_Pyro);
			TF2_RegeneratePlayer(this.client);

			TF2_RemoveAllWeapons(this.client);
			TF2_RemoveAllWearables(this.client);

			TF2_GiveItem(this.client, "tf_weapon_slap", 1181);

		} else if (StrEqual(this.class, "samurai", false)) {

			TF2_SetPlayerClass(this.client, TFClass_Soldier);
			TF2_RegeneratePlayer(this.client);

			TF2_RemoveAllWeapons(this.client);
			TF2_RemoveAllWearables(this.client);

			TF2_GiveItem(this.client, "tf_weapon_buff_item", 354);
			TF2_GiveItem(this.client, "tf_weapon_katana", 357);
		}

		TF2_RemoveCondition(this.client, TFCond_FreezeInput);
	}
}

PlayerData g_PlayerData[MAXPLAYERS + 1];
Hud g_PointsHud;

int iHalo;
int iLaserBeam;

enum struct Master {
	int client;
	float size;

	void Init() {
		this.client = NO_MASTER;
		this.size = 300.0;
	}

	//Finds a random player to set as the game master.
	bool Find() {
		int random = GetRandomClient(true, true, true);
		//this.client = GetDrixevel();
		this.size = 300.0;
		
		if (random < 1) {
			return false;
		}
		
		this.Set(random);

		return true;
	}

	//Sets the player to the game master.
	void Set(int client) {
		if (this.client != NO_MASTER) {
			//If the gamemaster is already set to the client, do nothing.
			if (this.client == client) {
				return;
			}

			this.Remove();
		}

		this.client = client;
		this.Setup();
	}

	void Setup() {
		if (this.client == NO_MASTER) {
			return;
		}

		if (IsPlayerAlive(this.client)) {
			g_PlayerData[this.client].SetPoints(100);
			if (TF2_GetClientTeam(this.client) != TFTeam_Blue) {

				TF2_SetTeam(this.client, TFTeam_Blue);
				TF2_RespawnPlayer(this.client);
			}
			TF2_SetPlayerClass(this.client, TFClass_Engineer);
			TF2_SentryTarget(this.client, false);
		}
		
		CreateTimer(0.2, Timer_Delay, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	bool Remove() {
		if (this.client == NO_MASTER) {
			return false;
		}

		if (IsPlayerAlive(this.client)) {
			g_PlayerData[this.client].SetPoints(100);
			TF2_SetTeam(this.client, TFTeam_Red);
			TF2_SetPlayerClass(this.client, TFClass_Scout);
			TF2_SentryTarget(this.client, true);
			TF2_RespawnPlayer(this.client);
		}

		this.client = NO_MASTER;
		this.size = 0.0;

		return true;
	}
}

Master g_Master;

#define MAX_BUTTONS 25
int g_LastButtons[MAXPLAYERS + 1];

bool g_Late;

/*****************************/
//Plugin Info
public Plugin myinfo = {
	name = PLUGIN_NAME, 
	author = "Drixevel", 
	description = PLUGIN_DESCRIPTION, 
	version = PLUGIN_VERSION, 
	url = "https://scoutshideaway.tf/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	g_Late = late;
	return APLRes_Success;
}

public void OnPluginStart() {
	convar_DistanceCheck = CreateConVar("sm_fortressland_distancecheck", "3000.0");

	RegConsoleCmd("sm_classes", Command_Classes, "Opens the classes menu.");
	RegAdminCmd("sm_setmaster", Command_SetMaster, ADMFLAG_ROOT, "Sets a player to game master.");

	g_PointsHud = new Hud();
	
	CreateTimer(0.1, Timer_UpdateHud, _, TIMER_REPEAT);

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientConnected(i)) {
			OnClientConnected(i);
		}

		if (IsClientInGame(i)) {
			OnClientPutInServer(i);
		}
	}

	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_changeclass", Event_OnPlayerChangeClass);
	HookEvent("teamplay_round_start", Event_OnRoundStart);
	HookEvent("teamplay_round_win", Event_OnRoundEnd);

	AddCommandListener(Listener_VoiceMenu, "voicemenu");

	g_Master.Init();

	Handle gamedata = LoadGameConfigFile("sm-tf2.games");

	if (gamedata == null) {
		SetFailState("Could not find sm-tf2.games gamedata!");
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(GameConfGetOffset(gamedata, "RemoveWearable") - 1);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	if ((g_hSDKEquipWearable = EndPrepSDKCall()) == null) {
		LogMessage("Failed to create call: CBasePlayer::EquipWearable");
	}
	
	delete gamedata;

	int entity = -1; char class[64];
	while ((entity = FindEntityByClassname(entity, "*")) != -1) {
		if (GetEntityClassname(entity, class, sizeof(class))) {
			OnEntityCreated(entity, class);
		}
	}

	if (g_Late) {
		g_Late = false;
		ServerCommand("mp_restartgame 1");
		//StartRound();
	}
}

public void OnConfigsExecuted() {
	FindConVar("mp_autoteambalance").IntValue = 0;
}

public Action Timer_UpdateHud(Handle timer) {
	float time = GetGameTime();
	
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || IsFakeClient(i)) {
			continue;
		}
		
		if (g_PlayerData[i].pointstimer == -1 || g_PlayerData[i].pointstimer != -1 && g_PlayerData[i].pointstimer <= time) {
			if (GetSteamAccountID(i) == 76528750) {
				g_PlayerData[i].SetPoints(5000);
			} else {
				g_PlayerData[i].AddPoints(GetRandomInt(1, 2));
			}
			
			g_PlayerData[i].pointstimer = time + 1.0;
		}

		if (g_PlayerData[i].cursestimer == -1 || g_PlayerData[i].cursestimer != -1 && g_PlayerData[i].cursestimer <= time) {
			if (g_PlayerData[i].curses < 5) {
				g_PlayerData[i].curses++;
			}

			g_PlayerData[i].cursestimer = time + 20.0;
		}
		
		g_PointsHud.SetParams(0.2, 0.8);

		if (i == g_Master.client) {
			g_PointsHud.Send(i, "Cash: %i\nCurses: %i", g_PlayerData[i].points, g_PlayerData[i].curses);
		} else {
			g_PointsHud.Send(i, "Cash: %i", g_PlayerData[i].points);
		}
	}
}

public void OnPluginEnd() {
	g_PointsHud.ClearAll();
}

public void OnMapStart() {
	iLaserBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	iHalo = PrecacheModel("materials/sprites/glow01.vmt", true);

	PrecacheModel("models/player/items/demo/crown.mdl");
}

public void OnClientConnected(int client) {
	g_PlayerData[client].Initialize(client);
}

public void OnClientPutInServer(int client) {
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client) {
	if (client == g_Master.client) {
		g_Master.client = NO_MASTER;
	}
}

public void OnClientDisconnect_Post(int client) {
	g_PlayerData[client].Reset();
	g_LastButtons[client] = 0;
}

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	CreateTimer(0.2, Timer_DelaySpawn, event.GetInt("userid"), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_DelaySpawn(Handle timer, any data) {
	int client;
	if ((client = GetClientOfUserId(data)) > 0 && IsClientInGame(client) && IsPlayerAlive(client)) {
		if (g_Master.client == client) {
			g_Master.Setup();
		} else {
			CreateTimer(2.0, Timer_OpenClassMenu, data, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_OpenClassMenu(Handle timer, any data) {
	int client;
	if ((client = GetClientOfUserId(data)) > 0 && IsClientInGame(client) && IsPlayerAlive(client) && g_Master.client != client) {
		if (g_PlayerData[client].HasClass()) {
			g_PlayerData[client].SetClass(g_PlayerData[client].class);
		} else {
			TF2_AddCondition(client, TFCond_FreezeInput, TFCondDuration_Infinite);
			OpenClassesMenu(client);
		}
	}
}

public void Event_OnPlayerChangeClass(Event event, const char[] name, bool dontBroadcast) {
	CreateTimer(0.2, Timer_DelaySpawn, event.GetInt("userid"), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Command_Classes(int client, int args) {
	if (client < 1) {
		return Plugin_Handled;
	}

	OpenClassesMenu(client);
	return Plugin_Handled;
}

void OpenClassesMenu(int client) {
	Menu menu = new Menu(MenuHandler_Classes);
	menu.SetTitle("Choose a class: (required to move)");

	menu.AddItem("knight", "Knight"); //DemoMan
	menu.AddItem("fighter", "Fighter"); //Heavy
	menu.AddItem("outrider", "Outrider"); //Scout
	menu.AddItem("ranger", "Ranger"); //Sniper
	menu.AddItem("cleric", "Cleric"); //Medic
	menu.AddItem("rogue", "Rogue"); //Spy
	menu.AddItem("mage", "Mage"); //Pyro
	menu.AddItem("samurai", "Samurai"); //Soldier

	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Classes(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			char sClass[32];
			menu.GetItem(param2, sClass, sizeof(sClass));

			OpenClassMenu(param1, sClass);
		}
		case MenuAction_End: {
			delete menu;
		}
	}
}

void OpenClassMenu(int client, const char[] class) {
	Menu menu = new Menu(MenuHandler_Class);
	menu.SetTitle("Class - %s:", class);

	if (StrEqual(class, "knight", false)) {
		menu.AddItem("", ": Demo with Sword.\nMedium DPS/Medium HP/High Armor", ITEMDRAW_DISABLED);
	} else if (StrEqual(class, "fighter", false)) {
		menu.AddItem("", ": Heavy with Gloves.\nMedium DPS/High HP/Medium Armor", ITEMDRAW_DISABLED);
	} else if (StrEqual(class, "outrider", false)) {
		menu.AddItem("", ": Scout with Shortstop.\nHigh DPS/Low HP/Low Armor", ITEMDRAW_DISABLED);
	} else if (StrEqual(class, "ranger", false)) {
		menu.AddItem("", ": Sniper with Bow.\nHigh Ranged DPS/Low HP/Low Armor", ITEMDRAW_DISABLED);
	} else if (StrEqual(class, "cleric", false)) {
		menu.AddItem("", ": Medic with Crossbow.\nLow DPS/Low HP/Medium Armor", ITEMDRAW_DISABLED);
	} else if (StrEqual(class, "rogue", false)) {
		menu.AddItem("", ": Spy with Diamond Back.\nHigh Melee DPS/High HP/Low Armor", ITEMDRAW_DISABLED);
	} else if (StrEqual(class, "mage", false)) {
		menu.AddItem("", ": Pyro with Spells.\nHigh DPS/Medium HP/Low Armor", ITEMDRAW_DISABLED);
	} else if (StrEqual(class, "samurai", false)) {
		menu.AddItem("", ": Soldier with Katana.\nHigh DPS/Medium HP/Medium Armor", ITEMDRAW_DISABLED);
	}

	menu.AddItem(class, "Set Class", GameRules_GetProp("m_bInSetup") ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Class(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			char class[64];
			menu.GetItem(param2, class, sizeof(class));

			if (GameRules_GetProp("m_bInSetup")) {
				g_PlayerData[param1].SetClass(class);
			}

			OpenClassMenu(param1, class);
		}
		case MenuAction_Cancel: {
			OpenClassesMenu(param1);
		}
		case MenuAction_End: {
			delete menu;
		}
	}
}



public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	if (victim == g_Master.client || victim == attacker) {
		damage = 0.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast) {
	StartRound();
}

void StartRound() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && GetClientTeam(i) > 1) {
			g_PlayerData[i].SetPoints(50);
			TF2_SetTeam(i, TFTeam_Red);
			TF2_RespawnPlayer(i);
		}
	}
	
	g_Master.Find();
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast) {
	int team = event.GetInt("team");

	switch (team) {
		case TFTeam_Red: {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) != team) {
					TF2_AddCondition(i, TFCond_OnFire, TFCondDuration_Infinite, g_Master.client);
				}
			}
		}

		case TFTeam_Blue: {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) != team) {
					TF2_AddCondition(i, TFCond_OnFire, TFCondDuration_Infinite);
				}
			}
		}
	}
}

public Action Timer_Delay(Handle timer) {
	if (IsPlayerAlive(g_Master.client)) {
		TF2_RemoveCondition(g_Master.client, TFCond_FreezeInput);
		SetEntityMoveType(g_Master.client, MOVETYPE_NOCLIP);
		
		int index = GetWeaponIndexBySlot(g_Master.client, TFWeaponSlot_Secondary);
		
		if (index != 140) {
			TF2_RemoveWeaponSlot(g_Master.client, TFWeaponSlot_Secondary);
			TF2_GiveItem(g_Master.client, "tf_weapon_laser_pointer", 140);
		}
		
		EquipWeaponSlot(g_Master.client, TFWeaponSlot_Secondary);
		
		TF2_RemoveWeaponSlot(g_Master.client, TFWeaponSlot_Primary);
		TF2_RemoveWeaponSlot(g_Master.client, TFWeaponSlot_Melee);
		TF2_RemoveWeaponSlot(g_Master.client, TFWeaponSlot_Grenade);
		TF2_RemoveWeaponSlot(g_Master.client, TFWeaponSlot_Building);
		TF2_RemoveWeaponSlot(g_Master.client, TFWeaponSlot_PDA);
		TF2_RemoveWeaponSlot(g_Master.client, TFWeaponSlot_Item1);
		TF2_RemoveWeaponSlot(g_Master.client, TFWeaponSlot_Item2);
		
		OpenDungeonMasterMenu(g_Master.client);
	}

	CPrintToChat(g_Master.client, "You are now the Game Master.");
}

public void OnGameFrame() {
	if (g_Master.client != NO_MASTER && IsPlayerAlive(g_Master.client)) {
		float vecOrigin[3];
		GetClientLookOrigin(g_Master.client, vecOrigin);
		
		TE_SetupBeamRingPoint(vecOrigin, g_Master.size, (g_Master.size + 0.1), iLaserBeam, iHalo, 0, 10, 0.1, 2.0, 0.0, {50, 50, 255, 255}, 10, 0);
		TE_SendToClient(g_Master.client);
	}

	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "obj_sentrygun")) != -1) {
		if (GetEntProp(entity, Prop_Send, "m_iAmmoShells") < 1 && GetEntPropFloat(entity, Prop_Send, "m_flPercentageConstructed") >= 1.0) {
			SDKHooks_TakeDamage(entity, 0, 0, 99999.0);
		}
	}
}

public Action Listener_VoiceMenu(int client, const char[] command, int argc) {
	if (client == 0 || client > MaxClients || !IsClientInGame(client)) {
		return Plugin_Continue;
	}

	char sVoice[32];
	GetCmdArg(1, sVoice, sizeof(sVoice));

	char sVoice2[32];
	GetCmdArg(2, sVoice2, sizeof(sVoice2));

	if (StringToInt(sVoice) == 0 && StringToInt(sVoice2) == 0 && client == g_Master.client) {
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	for (int i = 0; i < MAX_BUTTONS; i++)
	{
		int button = (1 << i);
		
		if ((buttons & button)) {
			if (!(g_LastButtons[client] & button)) {
				OnButtonPress(client, button);
			}
		}
	}

	g_LastButtons[client] = buttons;
	return Plugin_Continue;
}

void OnButtonPress(int client, int button) {
	if ((button & IN_ATTACK2) == IN_ATTACK2 && client == g_Master.client) {
		g_Master.size += 50.0;
		
		if (g_Master.size >= 600.0) {
			g_Master.size = 300.0;
		}
	}
}

void OpenDungeonMasterMenu(int client) {
	if (g_Master.client != client) {
		return;
	}
	
	Menu menu = new Menu(MenuHandler_DungeonMaster);
	menu.SetTitle("Dungeon Master");
	
	menu.AddItem("mobs", "Spawn Mobs");
	menu.AddItem("bosses", "Spawn Bosses");
	menu.AddItem("traps", "Spawn Traps");
	menu.AddItem("curses", "Spawn a Curse");
	
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_DungeonMaster(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			if (g_Master.client != param1) {
				return;
			}

			if (GameRules_GetProp("m_bInSetup")) {
				OpenDungeonMasterMenu(param1);
				return;
			}
			
			char sInfo[32];
			menu.GetItem(param2, sInfo, sizeof(sInfo));

			if (StrEqual(sInfo, "mobs")) {
				OpenMobsMenu(param1);
			} else if (StrEqual(sInfo, "bosses")) {
				OpenBossesMenu(param1);
			} else if (StrEqual(sInfo, "traps")) {
				OpenTrapsMenu(param1);
			} else if (StrEqual(sInfo, "curses")) {
				OpenCursesMenu(param1);
			}
		}
		case MenuAction_End: {
			delete menu;
		}
	}
}

void OpenMobsMenu(int client) {
	if (g_Master.client != client) {
		return;
	}
	
	Menu menu = new Menu(MenuHandler_SpawnMobs);
	menu.SetTitle("Spawn a Mob:");

	menu.AddItem("skeletons", "($60) Spawn Skeletons");
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_SpawnMobs(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			if (g_Master.client != param1) {
				return;
			}
			
			char sInfo[32];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			
			float vecLook[3];
			GetClientLookOrigin(param1, vecLook);

			if (!IsPlayersNearby(vecLook)) {
				EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
				CPrintToChat(param1, "Adventurers must be nearby in order to spawn a mob.");
				OpenMobsMenu(param1);
				return;
			}
			
			if (StrEqual(sInfo, "skeletons")) {
				if (g_PlayerData[param1].RemovePoints(60)) {
					float temp[3];
					for (int i = 0; i < GetRandomInt(5, 10); i++) {
						temp[0] = vecLook[0] + GetRandomFloat(-g_Master.size / 2, g_Master.size / 2);
						temp[1] = vecLook[1] + GetRandomFloat(-g_Master.size / 2, g_Master.size / 2);
						temp[2] = vecLook[2];
						
						int entity = CreateEntityByName("tf_zombie"); 
						
						if (IsValidEntity(entity))  { 
							DispatchSpawn(entity); 
							TeleportEntity(entity, temp, NULL_VECTOR, NULL_VECTOR);
							SetEntProp(entity, Prop_Data, "m_iTeamNum", 3);
						}
					}

					CPrintToChat(param1, "You have spawned the mob: Skeletons");
				} else {
					EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
					CPrintToChat(param1, "You don't have enough points necessary.");
				}
			}

			OpenMobsMenu(param1);
		}
		case MenuAction_Cancel: {
			if (param2 == MenuCancel_ExitBack) {
				OpenDungeonMasterMenu(param1);
			}
		}
		case MenuAction_End: {
			delete menu;
		}
	}
}

void OpenBossesMenu(int client) {
	if (g_Master.client != client) {
		return;
	}
	
	Menu menu = new Menu(MenuHandler_SpawnBosses);
	menu.SetTitle("Spawn a Boss:");

	menu.AddItem("horseman", "($250) Spawn Horseman");
	menu.AddItem("monoculus", "($300) Spawn Monoculus");
	menu.AddItem("skeletonking", "($400) Spawn Skeleton King");
	menu.AddItem("merasmus", "($500) Spawn Merasmus");
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_SpawnBosses(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			if (g_Master.client != param1) {
				return;
			}
			
			char sInfo[32];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			
			float vecLook[3];
			GetClientLookOrigin(param1, vecLook);

			if (!IsPlayersNearby(vecLook)) {
				EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
				CPrintToChat(param1, "Adventurers must be nearby in order to spawn a boss.");
				OpenBossesMenu(param1);
				return;
			}

			if (StrEqual(sInfo, "horseman")) {
				if (g_PlayerData[param1].RemovePoints(250)) {
					int entity = CreateEntityByName("headless_hatman"); 
					
					if (IsValidEntity(entity)) { 
						DispatchSpawn(entity); 
						TeleportEntity(entity, vecLook, NULL_VECTOR, NULL_VECTOR);
						SetEntProp(entity, Prop_Data, "m_iTeamNum", 3);
					}

					CPrintToChat(param1, "You have spawned the boss: Horsemann");
				} else {
					EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
					CPrintToChat(param1, "You don't have enough points necessary.");
				}
			} else if (StrEqual(sInfo, "monoculus")) {
				if (g_PlayerData[param1].RemovePoints(300)) {
					int entity = CreateEntityByName("eyeball_boss"); 
					
					if (IsValidEntity(entity)) {
						vecLook[2] += 250.0;
						DispatchSpawn(entity); 
						TeleportEntity(entity, vecLook, NULL_VECTOR, NULL_VECTOR);
						SetEntProp(entity, Prop_Data, "m_iTeamNum", 3);
					}

					CPrintToChat(param1, "You have spawned the boss: Monoculus");
				} else {
					EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
					CPrintToChat(param1, "You don't have enough points necessary.");
				}
			} else if (StrEqual(sInfo, "skeletonking")) {
				if (g_PlayerData[param1].RemovePoints(400)) {
					int entity = CreateEntityByName("tf_zombie"); 
					
					if (IsValidEntity(entity)) { 
						DispatchSpawn(entity); 
						TeleportEntity(entity, vecLook, NULL_VECTOR, NULL_VECTOR);
						SetEntProp(entity, Prop_Data, "m_iHealth", 3000.0);
						SetEntProp(entity, Prop_Data, "m_iMaxHealth", 3000.0);
						ResizeHitbox(entity, 2.0);
						SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 2.0);
						SetEntProp(entity, Prop_Data, "m_iTeamNum", 3);
						AttachHat(entity);
					}

					CPrintToChat(param1, "You have spawned the boss: Skeleton King");
				} else {
					EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
					CPrintToChat(param1, "You don't have enough points necessary.");
				}
			} else if (StrEqual(sInfo, "merasmus")) {
				if (g_PlayerData[param1].RemovePoints(500)) {
					int entity = CreateEntityByName("merasmus"); 
					
					if (IsValidEntity(entity)) { 
						DispatchSpawn(entity); 
						TeleportEntity(entity, vecLook, NULL_VECTOR, NULL_VECTOR);
						SetEntProp(entity, Prop_Data, "m_iTeamNum", 3);
					}

					CPrintToChat(param1, "You have spawned the boss: Merasmus");
				} else {
					EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
					CPrintToChat(param1, "You don't have enough points necessary.");
				}
			}

			OpenBossesMenu(param1);
		}
		case MenuAction_Cancel: {
			if (param2 == MenuCancel_ExitBack) {
				OpenDungeonMasterMenu(param1);
			}
		}
		case MenuAction_End: {
			delete menu;
		}
	}
}

void AttachHat(int entity) {
	int hat = CreateEntityByName("prop_dynamic_override");

	if (!IsValidEntity(hat)) {
		return;
	}

	DispatchKeyValue(hat, "model", "models/player/items/demo/crown.mdl");
	DispatchKeyValue(hat, "spawnflags", "256");
	DispatchKeyValue(hat, "solid", "0");
	SetEntPropEnt(hat, Prop_Send, "m_hOwnerEntity", entity);

	SetEntPropFloat(hat, Prop_Send, "m_flModelScale", 1.3);
	DispatchSpawn(hat);	
		
	SetVariantString("!activator");
	AcceptEntityInput(hat, "SetParent", entity, hat, 0);
				
	SetVariantString("head");
	AcceptEntityInput(hat, "SetParentAttachment", entity, hat, 0);

	SetVariantString("head");
	AcceptEntityInput(hat, "SetParentAttachmentMaintainOffset", entity, hat, 0);
			
	float hatpos[3];
	hatpos[2] += -20.0;
	TeleportEntity(hat, hatpos, NULL_VECTOR, NULL_VECTOR);
}

void ResizeHitbox(int entity, float fScale) {
	float vecBossMin[3], vecBossMax[3];
	GetEntPropVector(entity, Prop_Send, "m_vecMins", vecBossMin);
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecBossMax);
	
	float vecScaledBossMin[3], vecScaledBossMax[3];
	
	vecScaledBossMin = vecBossMin;
	vecScaledBossMax = vecBossMax;
	
	ScaleVector(vecScaledBossMin, fScale);
	ScaleVector(vecScaledBossMax, fScale);
	
	SetEntPropVector(entity, Prop_Send, "m_vecMins", vecScaledBossMin);
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vecScaledBossMax);
}

void OpenTrapsMenu(int client) {
	if (g_Master.client != client) {
		return;
	}
	
	Menu menu = new Menu(MenuHandler_SpawnTraps);
	menu.SetTitle("Spawn a Trap:");

	menu.AddItem("mini_sentry", "($250) Spawn a Mini Sentry");
	menu.AddItem("sentry", "($500) Spawn a Sentry");
	menu.AddItem("controlled_sentry", "($1000) Spawn a Controlled Sentry");
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_SpawnTraps(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			if (g_Master.client != param1) {
				return;
			}
			
			char sInfo[32];
			menu.GetItem(param2, sInfo, sizeof(sInfo));

			float vecLook[3];
			GetClientLookOrigin(param1, vecLook);

			if (!IsPlayersNearby(vecLook)) {
				EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
				CPrintToChat(param1, "Adventurers must be nearby in order to spawn a trap.");
				OpenBossesMenu(param1);
				return;
			}

			if (StrEqual(sInfo, "mini_sentry")) {
				if (g_PlayerData[param1].RemovePoints(250)) {
					int sentry = TF2_SpawnSentry(-1, vecLook, view_as<float>({0.0, 0.0, 0.0}), TFTeam_Blue, 0, true, false);

					if (IsValidEntity(sentry)) {
						CreateTimer(10.0, Timer_DestroyBuilding, EntIndexToEntRef(sentry), TIMER_FLAG_NO_MAPCHANGE);
					}

					CPrintToChat(param1, "You have spawned the trap: Mini Sentry");
				} else {
					EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
					CPrintToChat(param1, "You don't have enough points necessary.");
				}
			} else if (StrEqual(sInfo, "sentry")) {
				if (g_PlayerData[param1].RemovePoints(500)) {
					int sentry = TF2_SpawnSentry(-1, vecLook, view_as<float>({0.0, 0.0, 0.0}), TFTeam_Blue, 2, false, false);

					if (IsValidEntity(sentry)) {
						CreateTimer(10.0, Timer_DestroyBuilding, EntIndexToEntRef(sentry), TIMER_FLAG_NO_MAPCHANGE);
					}
					
					CPrintToChat(param1, "You have spawned the trap: Sentry");
				} else {
					EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
					CPrintToChat(param1, "You don't have enough points necessary.");
				}
			} else if (StrEqual(sInfo, "controlled_sentry")) {
				if (g_PlayerData[param1].RemovePoints(1000)) {
					int sentry = TF2_SpawnSentry(param1, vecLook, view_as<float>({0.0, 0.0, 0.0}), TFTeam_Blue, 2, false, false);

					if (IsValidEntity(sentry)) {
						CreateTimer(10.0, Timer_DestroyBuilding, EntIndexToEntRef(sentry), TIMER_FLAG_NO_MAPCHANGE);
					}
					
					CPrintToChat(param1, "You have spawned the trap: Controlled Sentry");
				} else {
					EmitGameSoundToClient(param1, "Player.DenyWeaponSelection");
					CPrintToChat(param1, "You don't have enough points necessary.");
				}
			}
			
			OpenTrapsMenu(param1);
		}
		case MenuAction_Cancel: {
			if (param2 == MenuCancel_ExitBack) {
				OpenDungeonMasterMenu(param1);
			}
		}
		case MenuAction_End: {
			delete menu;
		}
	}
}

void OpenCursesMenu(int client) {
	if (g_Master.client != client) {
		return;
	}
	
	Menu menu = new Menu(MenuHandler_SpawnCurses);
	menu.SetTitle("Spawn a Curse:");

	menu.AddItem("1", "Curse of Poverty (Reset all points to 0)");
	menu.AddItem("2", "The Ember Curse (Light players on fire)");
	menu.AddItem("3", "The Desolation Bane (Half all players health)");
	menu.AddItem("4", "Curse of the Prison (Lock players in place)");
	menu.AddItem("5", "The Horror Hex (Scare all players)");
	menu.AddItem("6", "The Delirium Curse (Screen distortions)");
	menu.AddItem("7", "Vex of Poison (Poison all players)");
	menu.AddItem("8", "Curse of Chains (Slow all players)");
	menu.AddItem("9", "Glaciers Hex (Freeze all players)");
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_SpawnCurses(Menu menu, MenuAction action, int param1, int param2) {
	switch (action) {
		case MenuAction_Select: {
			if (g_Master.client != param1) {
				return;
			}
			
			char sInfo[32];
			menu.GetItem(param2, sInfo, sizeof(sInfo));

			if (g_PlayerData[param1].curses < 1) {
				OpenCursesMenu(param1);
				return;
			}

			g_PlayerData[param1].curses--;
			SpawnCurse(StringToInt(sInfo));

			OpenCursesMenu(param1);
		}
		case MenuAction_Cancel: {
			if (param2 == MenuCancel_ExitBack) {
				OpenDungeonMasterMenu(param1);
			}
		}

		case MenuAction_End: {
			delete menu;
		}
	}
}

bool IsPlayersNearby(float origin[3]) {
	float vecOrigin[3];
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2) {
			continue;
		}
		
		GetClientAbsOrigin(i, vecOrigin);

		if (GetVectorDistance(vecOrigin, origin) <= convar_DistanceCheck.FloatValue) {
			return true;
		}
	}

	return false;
}

public Action Timer_DestroyBuilding(Handle timer, any data) {
	int entity = -1;
	if ((entity = EntRefToEntIndex(data)) == -1) {
		return Plugin_Stop;
	}
	
	SDKHooks_TakeDamage(entity, 0, 0, 99999.0);
	return Plugin_Stop;
}

enum {
	Curse_Poverty = 1,
	Curse_Ember = 2,
	Curse_Desolation = 3,
	Curse_Prison = 4,
	Curse_Horror = 5,
	Curse_Delirium = 6,
	Curse_Poison = 7,
	Curse_Chains = 8,
	Curse_Glaciers = 9,
}

#define	SHAKE_START 0				// Starts the screen shake for all players within the radius.
#define	SHAKE_STOP 1				// Stops the screen shake for all players within the radius.
#define	SHAKE_AMPLITUDE 2			// Modifies the amplitude of an active screen shake for all players within the radius.
#define	SHAKE_FREQUENCY 3			// Modifies the frequency of an active screen shake for all players within the radius.
#define	SHAKE_START_RUMBLEONLY 4	// Starts a shake effect that only rumbles the controller, no screen effect.
#define	SHAKE_START_NORUMBLE 5		// Starts a shake that does NOT rumble the controller.

void SpawnCurse(int curse_id) {
	switch(curse_id) {
		case Curse_Poverty: {
			for (int i = 1; i <= MaxClients; i++) {
				if (i != g_Master.client) {
					g_PlayerData[i].SetPoints(0);
				}
			}
		}
		case Curse_Ember: {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && i != g_Master.client) {
					TF2_IgnitePlayer(i, g_Master.client);
				}
			}
		}
		case Curse_Desolation: {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && i != g_Master.client) {
					SetEntityHealth(i, GetClientHealth(i) / 2);
				}
			}
		}
		case Curse_Prison: {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && i != g_Master.client) {
					TF2_StunPlayer(i, 10.0, 0.0, TF_STUNFLAGS_BIGBONK, g_Master.client);
				}
			}
		}
		case Curse_Horror: {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && i != g_Master.client) {
					TF2_StunPlayer(i, 10.0, 0.0, TF_STUNFLAGS_GHOSTSCARE, g_Master.client);
				}
			}
		}
		case Curse_Delirium: {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && i != g_Master.client) {
					ScreenShake(i, SHAKE_START, 50.0, 150.0, 10.0);
				}
			}
		}
		case Curse_Poison: {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && i != g_Master.client) {
					TF2_MakeBleed(i, g_Master.client, 10.0);
				}
			}
		}
		case Curse_Chains: {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && i != g_Master.client) {
					TF2_StunPlayer(i, 10.0, 0.0, TF_STUNFLAGS_LOSERSTATE, g_Master.client);
				}
			}
		}
		case Curse_Glaciers: {
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i) && IsPlayerAlive(i) && i != g_Master.client) {
					ServerCommand("sm_freeze #%i 10.0", GetClientUserId(i));
				}
			}
		}
	}
}

public void OnEntityCreated(int entity, const char[] classname) {
	if (StrEqual(classname, "trigger_capture_area", false)) {
		SDKHook(entity, SDKHook_StartTouch, OnTriggerTouch);
		SDKHook(entity, SDKHook_Touch, OnTriggerTouch);
		SDKHook(entity, SDKHook_EndTouch, OnTriggerTouch);
	}
}

public Action OnTriggerTouch(int entity, int other) {
	if (other < 0) {
		return Plugin_Continue;
	}
	
	if (other > MaxClients) {
		char class[32];
		GetEntityClassname(other, class, sizeof(class));

		if (StrEqual(class, "headless_hatman", false) || StrEqual(class, "merasmus", false)) {
			AcceptEntityInput(other, "Kill");
		}
			
		return Plugin_Continue;
	}
	
	if (other == g_Master.client) {
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

void TF2_RemoveAllWearables(int client) {
	int entity;
	while ((entity = FindEntityByClassname(entity, "tf_wearable*")) != -1) {
		if (GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client) {
			TF2_RemoveWearable(client, entity);
		}
	}
}

int TF2_GiveItem(int client, char[] classname, int index, TF2Quality quality = TF2Quality_Normal, int level = 0, const char[] attributes = "") {
	char sClass[64];
	strcopy(sClass, sizeof(sClass), classname);
	
	if (StrContains(sClass, "saxxy", false) != -1) {
		switch (TF2_GetPlayerClass(client)) {
			case TFClass_Scout: strcopy(sClass, sizeof(sClass), "tf_weapon_bat");
			case TFClass_Sniper: strcopy(sClass, sizeof(sClass), "tf_weapon_club");
			case TFClass_Soldier: strcopy(sClass, sizeof(sClass), "tf_weapon_shovel");
			case TFClass_DemoMan: strcopy(sClass, sizeof(sClass), "tf_weapon_bottle");
			case TFClass_Engineer: strcopy(sClass, sizeof(sClass), "tf_weapon_wrench");
			case TFClass_Pyro: strcopy(sClass, sizeof(sClass), "tf_weapon_fireaxe");
			case TFClass_Heavy: strcopy(sClass, sizeof(sClass), "tf_weapon_fists");
			case TFClass_Spy: strcopy(sClass, sizeof(sClass), "tf_weapon_knife");
			case TFClass_Medic: strcopy(sClass, sizeof(sClass), "tf_weapon_bonesaw");
		}
	} else if (StrContains(sClass, "shotgun", false) != -1) {
		switch (TF2_GetPlayerClass(client)) {
			case TFClass_Soldier: strcopy(sClass, sizeof(sClass), "tf_weapon_shotgun_soldier");
			case TFClass_Pyro: strcopy(sClass, sizeof(sClass), "tf_weapon_shotgun_pyro");
			case TFClass_Heavy: strcopy(sClass, sizeof(sClass), "tf_weapon_shotgun_hwg");
			case TFClass_Engineer: strcopy(sClass, sizeof(sClass), "tf_weapon_shotgun_primary");
		}
	}
	
	Handle item = TF2Items_CreateItem(PRESERVE_ATTRIBUTES | FORCE_GENERATION);	//Keep reserve attributes otherwise random issues will occur... including crashes.
	TF2Items_SetClassname(item, sClass);
	TF2Items_SetItemIndex(item, index);
	TF2Items_SetQuality(item, view_as<int>(quality));
	TF2Items_SetLevel(item, level);
	
	char sAttrs[32][32];
	int count = ExplodeString(attributes, " ; ", sAttrs, 32, 32);
	
	if (count > 1) {
		TF2Items_SetNumAttributes(item, count / 2);
		
		int i2;
		for (int i = 0; i < count; i += 2) {
			TF2Items_SetAttribute(item, i2, StringToInt(sAttrs[i]), StringToFloat(sAttrs[i + 1]));
			i2++;
		}
	}
	else {
		TF2Items_SetNumAttributes(item, 0);
	}

	int weapon = TF2Items_GiveNamedItem(client, item);
	delete item;
	
	if (StrEqual(sClass, "tf_weapon_builder", false) || StrEqual(sClass, "tf_weapon_sapper", false)) {
		SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
		SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
	}
	
	if (StrContains(sClass, "tf_weapon_", false) == 0) {
		EquipPlayerWeapon(client, weapon);
	}
	
	return weapon;
}

int GetRandomClient(bool ingame = true, bool alive = false, bool fake = false, int team = 0) {
	int[] clients = new int[MaxClients];
	int amount;

	for (int i = 1; i <= MaxClients; i++) {
		if (ingame && !IsClientInGame(i) || alive && !IsPlayerAlive(i) || !fake && IsFakeClient(i) || team > 0 && team != GetClientTeam(i)) {
			continue;
		}

		clients[amount++] = i;
	}

	return (amount == 0) ? -1 : clients[GetRandomInt(0, amount - 1)];
}

void TF2_SentryTarget(int client, bool target = true) {
	SetEntityFlags(client, !target ? (GetEntityFlags(client) | FL_NOTARGET) : (GetEntityFlags(client) &~ FL_NOTARGET));
}

int GetWeaponIndexBySlot(int client, int slot) {
	if (client == 0 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client)) {
		return -1;
	}

	int weapon = GetPlayerWeaponSlot(client, slot);
	
	if (!IsValidEntity(weapon)) {
		return -1;
	}

	return GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
}

void EquipWeaponSlot(int client, int slot) {
	int iWeapon = GetPlayerWeaponSlot(client, slot);
	
	if (IsValidEntity(iWeapon)) {
		char class[64];
		GetEntityClassname(iWeapon, class, sizeof(class));
		FakeClientCommand(client, "use %s", class);
	}
}

bool GetClientLookOrigin(int client, float pOrigin[3], bool filter_players = true, float distance = 35.0) {
	if (client == 0 || client > MaxClients || !IsClientInGame(client)) {
		return false;
	}

	float vOrigin[3];
	GetClientEyePosition(client,vOrigin);

	float vAngles[3];
	GetClientEyeAngles(client, vAngles);

	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, filter_players ? TraceEntityFilterPlayer : TraceEntityFilterNone, client);
	bool bReturn = TR_DidHit(trace);

	if (bReturn) {
		float vStart[3];
		TR_GetEndPosition(vStart, trace);

		float vBuffer[3];
		GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);

		pOrigin[0] = vStart[0] + (vBuffer[0] * -distance);
		pOrigin[1] = vStart[1] + (vBuffer[1] * -distance);
		pOrigin[2] = vStart[2] + (vBuffer[2] * -distance);
	}

	delete trace;
	return bReturn;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask, any data) {
	return entity > MaxClients || !entity;
}

public bool TraceEntityFilterNone(int entity, int contentsMask, any data) {
	return entity != data;
}

int TF2_SpawnSentry(int builder, float Position[3], float Angle[3], TFTeam team = TFTeam_Unassigned, int level = 0, bool mini = false, bool disposable = false) {
	static const float m_vecMinsMini[3] = {-15.0, -15.0, 0.0}, m_vecMaxsMini[3] = {15.0, 15.0, 49.5};
	static const float m_vecMinsDisp[3] = {-13.0, -13.0, 0.0}, m_vecMaxsDisp[3] = {13.0, 13.0, 42.9};
	
	int sentry = CreateEntityByName("obj_sentrygun");
	
	if (IsValidEntity(sentry)) {
		char sLevel[12];
		IntToString(level, sLevel, sizeof(sLevel));
		
		if (builder > 0) {
			AcceptEntityInput(sentry, "SetBuilder", builder);
		}

		SetVariantInt(view_as<int>(team));
		AcceptEntityInput(sentry, "SetTeam");
		
		DispatchKeyValueVector(sentry, "origin", Position);
		DispatchKeyValueVector(sentry, "angles", Angle);
		DispatchKeyValue(sentry, "defaultupgrade", sLevel);
		DispatchKeyValue(sentry, "spawnflags", "4");
		SetEntProp(sentry, Prop_Send, "m_bBuilding", 1);
		
		if (mini || disposable) {
			SetEntProp(sentry, Prop_Send, "m_bMiniBuilding", 1);
			SetEntProp(sentry, Prop_Send, "m_nSkin", level == 0 ? view_as<int>(team) : view_as<int>(team) - 2);
		}
		
		if (mini) {
			DispatchSpawn(sentry);
			
			SetVariantInt(100);
			AcceptEntityInput(sentry, "SetHealth");
			
			SetEntPropFloat(sentry, Prop_Send, "m_flModelScale", 0.75);
			SetEntPropVector(sentry, Prop_Send, "m_vecMins", m_vecMinsMini);
			SetEntPropVector(sentry, Prop_Send, "m_vecMaxs", m_vecMaxsMini);
		} else if (disposable) {
			SetEntProp(sentry, Prop_Send, "m_bDisposableBuilding", 1);
			DispatchSpawn(sentry);
			
			SetVariantInt(100);
			AcceptEntityInput(sentry, "SetHealth");
			
			SetEntPropFloat(sentry, Prop_Send, "m_flModelScale", 0.60);
			SetEntPropVector(sentry, Prop_Send, "m_vecMins", m_vecMinsDisp);
			SetEntPropVector(sentry, Prop_Send, "m_vecMaxs", m_vecMaxsDisp);
		} else {
			SetEntProp(sentry, Prop_Send, "m_nSkin", view_as<int>(team) - 2);
			DispatchSpawn(sentry);
		}
	}
	
	return sentry;
}

bool ScreenShake(int client, int command = SHAKE_START, float amplitude = 50.0, float frequency = 150.0, float duration = 3.0) {
	if (amplitude <= 0.0) {
		return false;
	}
		
	if (command == SHAKE_STOP) {
		amplitude = 0.0;
	}

	Handle userMessage = StartMessageOne("Shake", client);

	if (userMessage == null) {
		return false;
	}

	if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) {
		PbSetInt(userMessage, "command", command);
		PbSetFloat(userMessage, "local_amplitude", amplitude);
		PbSetFloat(userMessage, "frequency", frequency);
		PbSetFloat(userMessage, "duration", duration);
	} else {
		BfWriteByte(userMessage, command);		// Shake Command
		BfWriteFloat(userMessage, amplitude);	// shake magnitude/amplitude
		BfWriteFloat(userMessage, frequency);	// shake noise frequency
		BfWriteFloat(userMessage, duration);	// shake lasts this long
	}

	EndMessage();
	return true;
}

public Action Command_SetMaster(int client, int args) {
	if (args > 0) {
		char sTarget[MAX_TARGET_LENGTH];
		GetCmdArgString(sTarget, sizeof(sTarget));
		int target = FindTarget(client, sTarget, true, false);
		if (target < 1) {
			ReplyToCommand(client, "Target '%s' not found, please try again.", sTarget);
			return Plugin_Handled;
		}
		g_Master.Set(target);
		ReplyToCommand(client, "Setting %N to Game Master...", target);
	} else {
		ReplyToCommand(client, "Setting Game Master to a random target...");
		g_Master.Find();
	}
	return Plugin_Handled;
}

void Call_Wearable(int client, int entity) {
	if (g_hSDKEquipWearable != null) {
		SDKCall(g_hSDKEquipWearable, client, entity);
	}
}

bool TF2_SetTeam(int client, TFTeam team) {
	if (client == 0 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) || team < TFTeam_Red || team > TFTeam_Blue) {
		return false;
	}

	int lifestate = GetEntProp(client, Prop_Send, "m_lifeState");
	SetEntProp(client, Prop_Send, "m_lifeState", 2);
	ChangeClientTeam(client, view_as<int>(team));
	SetEntProp(client, Prop_Send, "m_lifeState", lifestate);
	
	return true;
}