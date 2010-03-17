#include <sourcemod>
#include <sdktools>
#include <attributes>
#include <colors>
#include <tf2_stocks>
#include <tf2_advanced>
#include <sdkhooks>

#pragma semicolon 1
#define PLUGIN_VERSION "0.1.0"

new g_bEffectsApplied[MAXPLAYERS+1] = {false,...};

////////////////////////
//P L U G I N  I N F O//
////////////////////////
public Plugin:myinfo =
{
	name = "tAttributes Mod, Effects",
	author = "Thrawn",
	description = "A plugin for tAttributes Mod, handling various effects for team fortress 2.",
	version = PLUGIN_VERSION,
	url = "http://thrawn.de"
}

//////////////////////////
//P L U G I N  S T A R T//
//////////////////////////
public OnPluginStart()
{
	HookEvent("player_spawn", Event_Player_Spawn);
	HookEvent("post_inventory_application", EventInventoryApplication,  EventHookMode_Post);
}

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    SDKHook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	new skillpoints = att_getClientStrength(attacker);
	if(skillpoints > 0)
	{
		damage *= (1.0 + skillpoints * 0.02);

		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action:OnWeaponSwitch(client, weapon)
{
	CreateTimer(0.1, Timer_ClassSpeed, client);

	return Plugin_Continue;
}

//////////////////////////
//E V E N T   H O O K S //
//////////////////////////
public EventInventoryApplication(Handle:hEvent, String:strName[], bool:bDontBroadcast)
{
	if(att_IsEnabled())
	{
		new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

		CreateTimer(0.2, Timer_ApplyEffects, client);
	}
}

public Action:Timer_ClassSpeed(Handle:timer, any:client) {
	applyClassSpeed(client);
}

public Action:Timer_ApplyEffects(Handle:timer, any:client) {
	applyEffects(client);
}

public Event_Player_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(att_IsEnabled())
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		applyEffects(client);
	}
}

stock applyEffects(client) {
	g_bEffectsApplied[client] = true;

	//Set Speed according to Dexterity
	applyClassSpeed(client);

	//Set Health according to Stamina
	//new iHealth = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	new iHealth = TF2_GetPlayerDefaultHealth(client);

	iHealth += att_getClientStamina(client) * 3;
	SetEntityHealth(client, iHealth);
	//SetEntProp(client, Prop_Send, "m_iHealth", iHealth);
}

stock increaseEffectDexterity(client, amount) {
	applyEffects(client);
}

public att_OnClientStrengthChange(iClient, iValue, iAmount) {
	//increaseEffectStrength(iClient, iAmount);
}

public att_OnClientStaminaChange(iClient, iValue, iAmount) {
	applyEffects(iClient);
}

public att_OnClientDexterityChange(iClient, iValue, iAmount) {
	applyEffects(iClient);
}


stock applyClassSpeed(client) {
	SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", TF2_GetPlayerClassSpeed(client) * (1.0 + att_getClientDexterity(client) * 0.02));
}