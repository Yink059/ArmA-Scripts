_run = true;

while {_run} do
{
	//conditions to reset flag location
	if (flagOwnedBySide == "west" && flagCarrier == noOne) then
	{
		if (side player == east && player distance flagTarget < 5.5) then
		{
			deleteVehicle flagTarget;
			flagCarrier = noOne;
			publicVariable "flagCarrier";
			flagOwnedBySide = "none";
			publicVariable "flagOwnedBySide";
			sleep .2;
			nul = [1]execVM "flag\resetFlag.sqf";
		};
	};
	if (flagOwnedBySide == "east" && flagCarrier == noOne) then
	{
		if (side player == west && player distance flagTarget < 5.5) then
		{
			deleteVehicle flagTarget;
			flagCarrier = noOne;
			publicVariable "flagCarrier";
			flagOwnedBySide = "none";
			publicVariable "flagOwnedBySide";
			sleep .2;
			nul = [1]execVM "flag\resetFlag.sqf";
		};
	};
	
	//conditions to end mission
	if (flagTarget distance (getMarkerPos "mrk_OpforWin") < 20) then
	{
		flagOwnedBySide = "eastWon";
		["Opfor has run the flag home!","hint",true,false] call BIS_fnc_MP;
		{_x allowDamage false;}forEach playableUnits;
		sleep 10;
		"end1" call BIS_fnc_endMission;
		_run = false;
	};
	if (flagTarget distance (getMarkerPos "mrk_BluforWin") < 20) then
	{
		flagOwnedBySide = "westWon";
		["Blufor has run the flag home!","hint",true,false] call BIS_fnc_MP;
		{_x allowDamage false;}forEach playableUnits;
		sleep 10;
		"end2" call BIS_fnc_endMission;
		_run = false;
	};
	if (missionTimeout == "true") then
	{
		"end5" call BIS_fnc_endMission;
		_run = false;
	};
		
	
	sleep 1;
	if (flagOwnedBySide == "westWon" || flagOwnedBySide == "eastWon") then {_run = false;};
};
		