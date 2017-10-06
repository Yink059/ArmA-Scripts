	[]execVM "briefing.sqf";
	player addItem "itemGPS";
	player assignItem "itemGPS";


if (isServer) then
{
	//initiate number of flag starting positions
	flagNumberOfStartingPositions = "NumberStartPositions" call BIS_fnc_getParamValue;
	//initiate number of respawn tickets
	numberRespawns = "NumberRespawnTickets" call BIS_fnc_getParamValue;
	[west,numberRespawns] call BIS_fnc_respawnTickets;
	[east,numberRespawns] call BIS_fnc_respawnTickets;
	_flg = [0]execVM "flag\resetFlag.sqf";
	flagCarrier = noOne;
	publicVariable "flagCarrier";
	flagOwnedBySide = "none";
	publicVariable "flagOwnedBySide";
	
};

[]execVM "flag\flagActions.sqf";
[]execVM "flag\monitorFlag.sqf";

//initiate mission timer
missionTimeout = "false";
publicVariable "missionTimeout";
missionTimeLimit = "MissionTimer" call BIS_fnc_getParamValue; //mission time limit
nul = [missionTimeLimit]execVM "missionTimer.sqf";

if (count playableUnits > 1) then {deleteVehicle otest;};