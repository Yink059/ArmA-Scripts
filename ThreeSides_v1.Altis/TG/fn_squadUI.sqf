/*	AUTHORS: 					Butler, |TG| B, Dslyecxi
	VERSION (YYYY_MM_DD): 	2015_03_24	
	USAGE:						[] call TG_fnc_squadUI; */

if (isDedicated) exitWith {}; //do not run it on the dedicated server

#define  HUD_ASSIGNEDTEAM "ST_STHud_assignedTeam"

// [] spawn ST_STHud_AssignedTeamWatcher -> nothing
ST_STHud_AssignedTeamWatcher =
{
    // Nothing to do in SP
    if (!isMultiplayer) exitWith {};

    // Before we start the main loop, check to see if any units have had their
    // team assigned e.g. via unit init and push that into our system.
    if (leader(player) == player) then
    {
        {
            private "_unit";
            _unit = _x;

            // Update the shared data if it doesn't match the data from the engine
            if (assignedTeam(_unit) != (_unit call ST_STHud_assignedTeam)) then
            {
                _unit setVariable [HUD_ASSIGNEDTEAM, assignedTeam(_unit), true];
            };
        } forEach(units(player));
    };

    while {true} do
    {
        // Wait until player is group leader
        waitUntil {sleep 2; leader(player) == player};

        // Ensure the engine is using the latest values from the shared version
        // This preserves team assignments when the group's leader changes
        {
            private "_unit";
            _unit = _x;

            _unit assignTeam (_unit call ST_STHud_assignedTeam);
        } forEach(units(player));

        // While the unit remains the group leader, ensure all other team
        // members are using the values set locally.
        while {leader(player) == player} do
        {
            {
                private "_unit";
                _unit = _x;

                // Update the shared data if it doesn't match the data from the engine
                if (assignedTeam(_unit) != (_unit call ST_STHud_assignedTeam)) then
                {
                    _unit setVariable [HUD_ASSIGNEDTEAM, assignedTeam(_unit), true];
                };
            } forEach(units(player));
            sleep 5;
        };
    };
};

// unit call ST_STHud_assignedTeam -> "MAIN" etc.
ST_STHud_assignedTeam =
{
    private "_unit";
    _unit = _this;

    // Nothing to do in SP
    if (!isMultiplayer) exitWith {assignedTeam(_unit)};

    // Assume MAIN if not defined, which avoids any complex behaviour
    _assigned_team = _unit getVariable [HUD_ASSIGNEDTEAM, "MAIN"];

    // Early exit if not using teams
    if (_assigned_team == "MAIN") exitWith {"MAIN"};

    // Special behaviour when checking the unit colour of the player
    if (_unit == player) then
    {
        // If we've changed groups since last check, discard our existing team
        private "_last_group";
        _last_group = player getVariable ["ST_STHud_lastGroup", grpNull];
        if (group(player) != _last_group) then
        {
            _last_group = group(player);
            player setVariable ["ST_STHud_lastGroup", _last_group, false];

            // TODO: Should we broadcast this or just let the clients figure
            // this out independently?
            _unit setVariable [HUD_ASSIGNEDTEAM, "MAIN", true];
            _assigned_team = "MAIN";
        };
    };
    _assigned_team;
};

FN_TG_SQUAD_UI_MAPMARKERS = 
{
	private ["_marker","_markerNumber", "_markerName", "_getNextMarker","_vehicle", "_str", "_txt"];
	_getNextMarker = //Helping function to create or update position of the marker.
	{
		private ["_marker"];
		
		_markerNumber = _markerNumber + 1;
		_marker = format["um%1",_markerNumber];
		
		if(getMarkerType _marker == "") then {createMarkerLocal [_marker, _this];} 
		else 										{_marker setMarkerPosLocal _this;};
		
		_marker;
	};

	while {true} do //The Main loop
	{
		waitUntil {sleep 1;	(visibleMap or visibleGPS);}; //wait until map or gps is open
		_markerNumber = 0;
		
		_occupiedVics = [];
		
		{//for each group member
			if (isPlayer _x) then {
				_vehicle = vehicle _x; 
			
				if(_vehicle != _x) then	//if the _x is in a vehicle create a listed names in there.
				{			
					if (!(_vehicle in _occupiedVics)) then {_occupiedVics pushBack _vehicle;};
				}
				else 
				{
					_pos = getPosATL _vehicle;
					_txt = name _x;
					_marker = _pos call _getNextMarker;
					_marker setMarkerSizeLocal [0.4, 0.4];
					if(!visibleGPS || visibleMap) then{_marker setMarkerTextLocal _txt;} else {_marker setMarkerTextLocal "";};
					
					if (_x == leader player) then 
					{
						_marker setMarkerDirLocal getDir _vehicle;
						_marker setMarkerColorLocal "ColorBrown";
						_marker setMarkerTypeLocal "mil_arrow2";
					}
					else
					{
						_marker setMarkerDirLocal getDir _vehicle;
						_stgi_color = _x call ST_STHud_assignedTeam;
						switch (_stgi_color) do
						{
							case "MAIN": 	{_marker setMarkerColorLocal "Default";};
							case "RED": 	{_marker setMarkerColorLocal "ColorRed";};
							case "GREEN": {_marker setMarkerColorLocal "ColorGreen";};
							case "BLUE": 	{_marker setMarkerColorLocal "ColorBlue";};
							case "YELLOW":{_marker setMarkerColorLocal "ColorYellow";};
						}; 
						_marker setMarkerTypeLocal "mil_arrow";
					};
				};
			};
		} forEach units(player);

		if (leader player == player) then 		// if the player is the leader of the squad
		{
			{
				if (side _x == side player) then
				{
					if(isPlayer (leader _x)) then
					{
						if((leader _x) != player) then
						{
							_vehicle = vehicle (leader _x); 
							if(_vehicle != (leader _x)) then	//if the _x is in a vehicle create a listed names in there.
							{
								if (!(_vehicle in _occupiedVics)) then {_occupiedVics pushBack _vehicle;};
							}
							else
							{
								_pos = getPosATL _vehicle;
								_marker = _pos call _getNextMarker;
								_marker setMarkerColorLocal "ColorBrown";
								_txt = format["%1 [%2]",(name _vehicle),(groupID (_x))];
								if(!visibleGPS || visibleMap) then{_marker setMarkerTextLocal _txt;} else {_marker setMarkerTextLocal "";};
								_marker setMarkerSizeLocal [0.4, 0.4];
								_marker setMarkerDirLocal getDir _vehicle;
								_marker setMarkerTypeLocal "mil_arrow2";
							};	
						};
					};
				};			
			}forEach allGroups;
		};
		
		{
			_aVic = _x;
			_str = ""; _txt = "";		

			{
				if(group _x == group player) then
				{								
					if(_foreachindex == ((count (crew (vehicle _x))) - 1)) then 
					{
						_str = format["%1",name _x];	
					} 	
					else 
					{ 
						_str = format["%1, ",name _x];
					};				
					_txt = _txt + _str;
				};
				
				if (leader player == player and leader _x == _x and leader _x != player) then
				{
					if(_foreachindex == ((count (crew (vehicle _x))) - 1)) then 
					{
						_str = format["%1 [%2]", name _x, groupID (group _x)];
					} 	
					else 
					{ 
						_str = format["%1 [%2], ", name _x,(groupID (group _x))];
					};				
					_txt = _txt + _str;				
				};			
			}forEach crew (_aVic);
			
			_pos = getPosATL _aVic;
			_marker = _pos call _getNextMarker;
			if(!visibleGPS || visibleMap) then{_marker setMarkerTextLocal _txt;} else {_marker setMarkerTextLocal "";};
			_marker setMarkerColorLocal "ColorOrange";
			_marker setMarkerSizeLocal [0.7, 0.7];
			_marker setMarkerTypeLocal "n_inf";
		}forEach _occupiedVics;

		_markerNumber = _markerNumber + 1;
		_marker = format["um%1",_markerNumber];	
		
		while {(getMarkerType _marker) != ""} do 
		{	
			deleteMarkerLocal _marker;
			_markerNumber = _markerNumber + 1;
			_marker = format["um%1",_markerNumber];
		};	
	};
};

FN_TG_SQUAD_UI_NAMETAGS = 
{
	waitUntil {!(isNull (findDisplay 46))};
	systemChat "Squad Name Tag initialized. Keybinding: ""Tactical View; Default: DEL[NUMPAD]""";
	
	while {true} do
	{
		waitUntil {(inputAction "tacticalView")>0};
	
		_idx = addMissionEventHandler ["Draw3D", {
			
			_occupiedVics = [];
			
			{//for each group member
				if (isPlayer _x) then {
					_vehicle = vehicle _x; 
				
					if(_vehicle != _x) then	//if the _x is in a vehicle create a listed names in there.
					{			
						if (!(_vehicle in _occupiedVics)) then {_occupiedVics pushBack _vehicle;};
					}
					else 
					{
						if (_x != player) then 
						{
							_playerPos = getPosATL _x;
							_dist = player distance _x;
							_dir = ([player, _x] call BIS_fnc_relativeDirTo) + 180;
							_h = (_playerPos select 2) + ((_dist/30) + 2);
							_str = name _x;
							_color = [1, 1, 1, 1];
							
							if (_x == leader player) then 
							{
								if(_dist < 60) then 
								{	
									_fade = 1;
									_color = [0.6, 0.3, 0, _fade];
									drawIcon3D ["", _color, [_playerPos select 0,_playerPos select 1,_h], 0, 0, _dir, _str, 2, 0.03, "PuristaLight" ];
								} 
								else	
								{	
									if (_dist < 76) then 
									{
										_fade = (((_dist - 60) - 11) * (-1) )/10;
										_color = [0.6, 0.3, 0, _fade];
										drawIcon3D ["", _color, [_playerPos select 0,_playerPos select 1,_h], 0, 0, _dir, _str, 2, 0.03, "PuristaLight" ];
									};
								};
							}
							else
							{
								if(_dist < 30) then 
								{
									_fade = 1;
									
									_stgi_color = _x call ST_STHud_assignedTeam;
									switch (_stgi_color) do
									{
										case "MAIN": 	{_color = [1,1,1,_fade];};
										case "RED": 	{_color = [1,0,0,_fade];};
										case "GREEN": {_color = [0,1,0,_fade];};
										case "BLUE": 	{_color = [0,0,1,_fade];};
										case "YELLOW":{_color = [1,1,0,_fade];};
									};
									drawIcon3D ["", _color, [_playerPos select 0,_playerPos select 1,_h], 0, 0, _dir, _str, 2, 0.03, "PuristaLight" ];
								} 
								else	
								{
									if (_dist < 46) then 
									{
										_fade = (((_dist - 30) - 11) * (-1) )/10;
										_stgi_color = _x call ST_STHud_assignedTeam;
										switch (_stgi_color) do
										{
											case "MAIN": 	{_color = [1,1,1,_fade];};
											case "RED": 	{_color = [1,0,0,_fade];};
											case "GREEN": {_color = [0,1,0,_fade];};
											case "BLUE": 	{_color = [0,0,1,_fade];};
											case "YELLOW":{_color = [1,1,0,_fade];};
										};
										drawIcon3D ["", _color, [_playerPos select 0,_playerPos select 1,_h], 0, 0, _dir, _str, 2, 0.03, "PuristaLight" ];
									};
								}; //set fade
							};
						};
						
					};
				};
			} forEach units(player);
			
			if (leader player == player) then 		// if the player is the leader of the squad
			{
				{
					if (side _x == side player) then
					{
						if(isPlayer (leader _x)) then
						{
							if((leader _x) != player) then
							{
								_vehicle = vehicle (leader _x); 
								if(_vehicle != (leader _x)) then	//if the _x is in a vehicle create a listed names in there.
								{
									if (!(_vehicle in _occupiedVics)) then {_occupiedVics pushBack _vehicle;};
								}
								else
								{
									_playerPos = getPosATL (leader _x);
									_dist = player distance (leader _x);
									_dir = ([player, (leader _x)] call BIS_fnc_relativeDirTo) + 180;
									_h = (_playerPos select 2) + ((_dist/30) + 2);
									_str = format["%1 [%2]",(name (leader _x)),(groupID _x)];								
									if(_dist < 60) then 
									{
										_fade = 1;
										_color = [0.6, 0.3, 0, _fade];
										drawIcon3D ["", _color, [_playerPos select 0,_playerPos select 1,_h], 0, 0, _dir, _str, 2, 0.03, "PuristaLight" ];
									} 
									else	
									{
										if (_dist < 76) then 
										{
											_fade = (((_dist - 60) - 11) * (-1) )/10;
											_color = [0.6, 0.3, 0, _fade];
											drawIcon3D ["", _color, [_playerPos select 0,_playerPos select 1,_h], 0, 0, _dir, _str, 2, 0.03, "PuristaLight" ];
										};
									};
								};	
							};
						};
					};			
				}forEach allGroups;	
			};
			
			{
				_aVic = _x;
				_str = ""; _txt = "";
				
				{
					if(group _x == group player and _x != player) then
					{								
						if(_foreachindex == ((count (crew (vehicle _x))) - 1)) then 
						{
							_str = format["%1",name _x];	
						} 	
						else 
						{ 
							_str = format["%1, ",name _x];
						};
						_txt = _txt + _str;
					};
					
					if (leader player == player and leader _x == _x and leader _x != player) then
					{
						if(_foreachindex == ((count (crew (vehicle _x))) - 1)) then 
						{
							_str = format["%1 [%2]", name _x, groupID (group _x)];
						} 	
						else 
						{ 
							_str = format["%1 [%2], ", name _x,(groupID (group _x))];
						};				
						_txt = _txt + _str;				
					};			
				}forEach crew (_aVic);
				
				_pos = getPosATL _aVic;
				_dist = player distance _aVic;
				_dir = ([player, _aVic] call BIS_fnc_relativeDirTo) + 180;
				_h = (_pos select 2) + ((_dist/30) + 3);
				if(_dist < 60) then 
				{
					_fade = 1;
					_color = [1, 0.64, 0, _fade];
					drawIcon3D ["", _color, [_pos select 0,_pos select 1,_h], 0, 0, _dir, _txt, 2, 0.035, "PuristaLight" ];
				}
				else	
				{	
					if (_dist < 76) then 
					{
						_fade = (((_dist - 60) - 11) * (-1) )/10;
						_color = [1, 0.64, 0, _fade];			
						drawIcon3D ["", _color, [_pos select 0,_pos select 1,_h], 0, 0, _dir, _txt, 2, 0.035, "PuristaLight" ];
					};
				};
			}forEach _occupiedVics;
		}];
		
		sleep 40;	
		removeMissionEventHandler ["Draw3D",_idx];
		sleep 2;
	};
};

[] spawn ST_STHud_AssignedTeamWatcher;
[] spawn FN_TG_SQUAD_UI_MAPMARKERS;
[] spawn FN_TG_SQUAD_UI_NAMETAGS;