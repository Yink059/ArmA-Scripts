[] spawn
{
	waitUntil {!isNull player && player == player};
	waitUntil{!isNil "BIS_fnc_init"};	
		
	[] call TG_fnc_squadUI;
	[] spawn TG_fnc_revive;
	//[] spawn TG_fnc_arsenal;
	//[] call TG_fnc_groupManager;
};