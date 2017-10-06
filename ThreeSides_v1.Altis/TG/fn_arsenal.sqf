/* -------------------------------------------------------------------

File: arsenalbox.sqf

Author: intel64gamer

Description: Adds an Arsenal with the specific (limited) gear to a specific type of ammobox. Code will only run on the client.

Usage: Put the following Line in the init.sqf
null = execVM "arsenalbox.sqf";


------------------------------------------------------------------- */
if (isDedicated) exitWith {};
/* ---- Config ---- */

//Type of ammobox e.g. "Box_NATO_Wps_F"
_boxtype = "B_supplyCrate_F";

//Array of available Gear e.g. ["arifle_MX_F","arifle_MX_SW_F","arifle_MXC_F"]
_availableWeapons = [
							"arifle_MX_F",
							"arifle_MX_Black_F",
							"arifle_MXC_F",
							"arifle_MXC_Black_F",
							"arifle_MX_GL_F",
							"arifle_MX_GL_Black_F",
							"arifle_MX_SW_F",
							"arifle_MX_SW_Black_F",
							"LMG_Mk200_BI_F",
							"srifle_DMR_02_F",
							"srifle_DMR_03_khaki_F",
							"srifle_DMR_03_woodland_F",
							"srifle_DMR_03_multicam_F",
							"MMG_01_tan_F",
							"MMG_02_camo_F",
							"MMG_02_black_F",
							"MMG_02_sand_F",
							"arifle_SDAR_F",
							"srifle_dmr_02_F",
							"srifle_dmr_03_F",
							"srifle_DMR_04_F",
							"srifle_dmr_05_blk_f",
							"srifle_DMR_05_tan_f",
							"srifle_dmr_06_camo_f",
							"arifle_Mk20_plain_F",
							"arifle_Mk20C_plain_F",
							"arifle_Mk20_GL_plain_F",


							"hgun_P07_F",
							"hgun_Pistol_heavy_01_MRD_F",

							"SMG_01_F",
							"SMG_02_F",

							"launch_NLAW_F",
							"launch_B_Titan_short_F",
							"launch_B_Titan_F",
							"launch_RPG32_F",

							"Binocular",
							"Laserdesignator",
							"Rangefinder"];

_availableMagazines = [
							"30Rnd_65x39_caseless_mag",
							"30Rnd_65x39_caseless_mag_Tracer",
							"20Rnd_556x45_UW_mag",
							"30Rnd_556x45_Stanag",
							"30Rnd_556x45_Stanag_Tracer_Red",
							"30Rnd_556x45_Stanag_Tracer_Green",
							"30Rnd_556x45_Stanag_Tracer_Yellow",
							
							"30Rnd_45ACP_Mag_SMG_01",
							"30Rnd_45ACP_Mag_SMG_01_tracer_green",
							"30Rnd_9x21_Mag",

							"100Rnd_65x39_caseless_mag",
							"100Rnd_65x39_caseless_mag_Tracer",
							"200Rnd_65x39_cased_Box_Tracer",
							"200Rnd_65x39_cased_Box",
							"150Rnd_93x64_Mag",

							"10Rnd_338_Mag",
							"10Rnd_127x54_Mag",
							"10Rnd_93x64_DMR_05_Mag",
							"130Rnd_338_Mag",
							"20Rnd_762x51_Mag",

							"16Rnd_9x21_Mag",
							"11Rnd_45ACP_Mag",

							"NLAW_F",
							"Titan_AP",
							"Titan_AT",
							"Titan_AA",
							"RPG32_F",
							"RPG32_HE_F",

							"HandGrenade",
							"MiniGrenade",

							"SmokeShell",
							"SmokeShellBlue",
							"SmokeShellGreen",
							"SmokeShellOrange",
							"SmokeShellPurple",
							"SmokeShellRed",
							"SmokeShellYellow",

							"B_IR_Grenade",

							"Chemlight_green",
							"Chemlight_red",
							"Chemlight_blue",
							"Chemlight_yellow",

							"DemoCharge_Remote_Mag",
							"APERSBoundingMine_Range_Mag",
							"APERSMine_Range_Mag",
							"APERSTripMine_Wire_Mag",
							"ATMine_Range_Mag",
							"ClaymoreDirectionalMine_Remote_Mag",
							"SLAMDirectionalMine_Wire_Mag",
							"SatchelCharge_Remote_Mag",

							"3Rnd_HE_Grenade_shell",
							"3Rnd_SmokeRed_Grenade_shell",
							"3Rnd_SmokeGreen_Grenade_shell",
							"3Rnd_SmokeBlue_Grenade_shell",
							"3Rnd_SmokeOrange_Grenade_shell",
							"3Rnd_SmokePurple_Grenade_shell",
							"3Rnd_SmokeRed_Grenade_shell",
							"3Rnd_SmokeYellow_Grenade_shell",
							"3Rnd_UGL_FlareWhite_F",
							"3Rnd_UGL_FlareGreen_F",
							"3Rnd_UGL_FlareRed_F",
							"3Rnd_UGL_FlareYellow_F",
							"3Rnd_UGL_FlareCIR_F",
							"1Rnd_HE_Grenade_shell",
							"1Rnd_Smoke_Grenade_shell",
							"1Rnd_SmokeBlue_Grenade_shell",
							"1Rnd_SmokeGreen_Grenade_shell",
							"1Rnd_SmokeOrange_Grenade_shell",
							"1Rnd_SmokePurple_Grenade_shell",
							"1Rnd_SmokeRed_Grenade_shell",
							"1Rnd_SmokeYellow_Grenade_shell",
							"UGL_FlareWhite_F",
							"UGL_FlareGreen_F",
							"UGL_FlareRed_F",
							"UGL_FlareYellow_F",
							"UGL_FlareCIR_F",
							
							"Laserbatteries"];

_availableItems = ["optic_Holosight",
						"optic_Hamr",
						"optic_Aco",
						"optic_Aco_smg",
						"optic_Holosight_smg",
						"optic_Aco_grn",
						"Optic_Arco",
						"Optic_Hamr",
						"Optic_MRCO",
						"optic_SOS",
						"optic_DMS",
						"optic_LRPS",
						"optic_Nightstalker",
						"optic_Holosight",
						"optic_Aco_smg",
						"optic_ACO_grn_smg",
						"optic_AMS_snd",
						"optic_tws",
						"optic_tws_mg",
						"optic_MRD",

						"muzzle_snds_H",
						"muzzle_snds_L",
						"muzzle_snds_acp",
						"muzzle_snds_H_SW",
						"muzzle_snds_B",
						"muzzle_snds_338_sand",
						"muzzle_snds_338_black",
						

						"acc_flashlight",
						"acc_pointer_IR",
						"bipod_01_F_snd",
						"bipod_01_F_mtp",
						"bipod_01_F_blk",
						"bipod_03_F_blk",

						"H_Bandanna_mcamo",
						"H_Watchcap_blk",
						"H_Booniehat_mcamo",
						"H_Cap_tan_specops_US",
						"H_HelmetB",
						"H_HelmetB_desert",
						"H_HelmetB_light",
						"H_HelmetB_light_desert",
						"H_HelmetB_light_grass",
						"H_HelmetB_snakeskin",
						"H_HelmetB_grass",
						"H_HelmetSpecB_paint2",
						"H_HelmetSpecB_blk",
						"U_B_Wetsuit",

						"G_Combat",
						"G_Aviator",
						"G_Spectacles",
						"G_Sport_Blackred",
						"G_Tactical_Clear",
						"G_Balaclava_blk",
						"G_Balaclava_combat",
						"G_Bandanna_beast",
						"G_Bandanna_tan",
						"G_Diving",

						"V_Chestrig_rgr",
						"V_TacVest_khk",
						"V_PlateCarrier3_rgr",
						"V_PlateCarrierGL_rgr",
						"V_PlateCarrierSpec_rgr",
						"V_PlateCarrier2_rgr",
						"V_PlateCarrier1_rgr",
						"U_B_CombatUniform_mcam",
						"U_B_CombatUniform_mcam_tshirt",
						"V_BandollierB_rgr",
						"V_Rangemaster_belt",
						"V_RebreatherB",

						"ItemMap",
						"ItemRadio",
						"ItemWatch",
						"ItemCompass",
						"ItemGPS",
						"B_UavTerminal",
						"Medikit",
						"ToolKit",
						"MineDetector",

						"FirstAidKit",
						"NVGoggles"];
_availableBackpacks = [
						"B_AssaultPack_mcamo",
						"B_AssaultPack_rgr",
						"B_Kitbag_rgr",
						"B_Kitbag_mcamo",
						"B_Carryall_mcamo",
						"B_Bergen_mcamo",
						"B_TacticalPack_mcamo"
						];

//Interval at which the scripts checks whether to add/remove the action. Anything between 1 to 5 seconds should be fine and not impact client performance.
_interval = 5;

//Code is Client Side Only

_actionadded = false;
_action = -100;

[missionNamespace,_availableWeapons,true] call BIS_fnc_addVirtualWeaponCargo;
[missionNamespace,_availableMagazines,true] call BIS_fnc_addVirtualMagazineCargo;
[missionNamespace,_availableItems,true] call BIS_fnc_addVirtualItemCargo;
[missionNamespace,_availableBackpacks,true] call BIS_fnc_addVirtualBackpackCargo;

while {true} do 
{
	if ((typeOf cursorTarget) == _boxtype && (cursorTarget distance player) <= 5) then 
	{
		if (!_actionadded) then 
		{
			_action = player addAction ["<t color='#FF0000'>Arsenal</t>", { [] spawn BIS_fnc_arsenal }];
			_actionadded = true;
		};
	} 
	else 
	{
		if (_actionadded) then 
		{
			player removeAction _action;
			_actionadded = false;
		};
	};

	sleep _interval;
}; 