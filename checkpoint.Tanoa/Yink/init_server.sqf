[guard1,'WATCH1','ASIS'] remoteExec ['BIS_fnc_ambientAnim',0,true];
[guard1_2,'WATCH1','ASIS'] remoteExec ['BIS_fnc_ambientAnim',0,true];
[guard1_1,'WATCH1','ASIS'] remoteExec ['BIS_fnc_ambientAnim',0,true];
teamscore = 0;
arrested = [];

resistance setFriend [west,1];
west setFriend [resistance,1];
resistance setFriend [east,1];
east setFriend [resistance,1];
civilian setFriend [west,0];
east setFriend [west,0];
missionNameSpace setVariable ["cars",[],true];

truck action ["lightOn",  truck];
missionNameSpace setVariable ["cur",true,true];

_transport = {
	if (isServer) then {
		resistance setFriend [west,1];
		west setFriend [resistance,1];
		while {true} do {
			waitUntil{(count arrested)>3};
			hint "Heli is coming to pick up Prisoners!";
			jailer setFuel 1;
			jailer flyinheight 15;
			jailer domove (getPos helipad);
			waitUntil {unitReady jailer};
			jailer land "LAND";
			waitUntil {((getpos jailer) select 2)<10};
			arrested joinSilent (group (driver jailer));
			{
				_x switchMove "";
				_x assignAsCargo jailer;
				[_x] orderGetIn true;
			} forEach arrested;
			waitUntil{(count (crew jailer))==(4+(count arrested))};
			jailer domove (getMarkerPos "jailerM");
			waitUntil{(jailer distance (getMarkerPos "jailerM"))<150};
			{
				if (_x in (crew jailer)) then {
					deleteVehicle _x;
					if ((_x getVariable "wep")) then {
						teamscore = teamscore + 2;
					};
				};
			} forEach arrested;
		};
	};
};

_ambience = {
	while {true} do {
		sleep ((round (Random 18)) + 5);
		_randX 	= round (random 500);
		_randY	= round (random 500);
		
		_bomb = "Bo_GBU12_LGB_MI10" createVehicle [
			(((getmarkerpos "arty") select 0) + _randX) - 250,
			(((getmarkerpos "arty") select 1) + _randY) - 250,
			10
		];
	};
};

call1 = {
	//<param> call1 {code};
	(_this select 0) call (_this select 1);
};

[] spawn _transport;
[] spawn _ambience;

[
		[
			"C_Offroad_01_F",
			"C_Van_01_transport_F",
			"C_Offroad_02_Unarmed_F",
			"I_C_Offroad_02_Unarmed_F",
			"C_Truck_02_covered_F"
		],
		[
			"east",
			"north",
			"west"
		],
		"C_Man_Casual_%1_F_Tanoan",
		[
			"north",
			"end",
			"check3"
		],
		[
			"spawn",
			"jail",
			"check",
			"check2",
			"checkpoint",
			gate
		]
] execVM "Yink\checkpoint_yink.sqf";