/*

looping script>>

create car
	type
	decide on side
	bombs
	number of passengers

moving function
	move to location
	reassert
*/
sleep 25;
_createCar = {

	_cars 	= _this select 0;
	_locs 	= _this select 1;
	_man	= _this select 2;
	_run	= _this select 3;
	_group	= grpNull;
	_side	= round(random 3);
	_bomb	= ceil(random 6);
	_wep	= round(random 3);
	
	if (_side==3) then {
			_group	= createGroup east;
			_man	= "I_C_Soldier_Bandit_8_F";
		} else {
			_group	= createGroup resistance;
		};
		sleep 2;
	
	_car	= _cars select (floor (random (count _cars)));
	_loc	= _locs select (floor (random (count _locs)));
	
	_veh	= createVehicle [
		_car,
		getMarkerPos "test",
		[],
		0,
		"NONE"
	];
	
	_cCount	= round(random 2)-1;
	_veh setVariable ["bomb",_bomb,true];
	_veh setDir 200;
	_unit = _group createUnit [
		format [_man,ceil(random 6)],
		[0,0,0],
		[],
		0,
		"NONE"
	];
	[_unit] joinSilent _group;
	_unit setVariable ["arrest1", 0,true];
	_unit moveInDriver _veh;
	_unit action ["lightOn",  _veh];
	_veh setVariable ["Next", false,true];
	_veh setVariable ["detain", round(random 2),true];
	if (round (random 1)==1) then {
		_unit addWeapon "Weapon_hgun_P07_F";
		_unit addMagazine "16Rnd_9x21_Mag";
	};

	for [{_i=0},{_i<_cCount},{_i = _i + 1}] do {
	
		_hasCargo = _veh emptyPositions "CARGO" > 0;
		
		if (_hasCargo) then {
			_unit = _group createUnit [
				format [_man,ceil(random 6)],
				[0,0,0],
				[],
				0,
				"CARGO"
			];
			_unit setVariable ["arrest1", 0,true];
			[_unit] joinSilent _group;
			if (round (random 1)==1) then {
				_unit addWeapon "Weapon_hgun_P07_F";
				_unit addMagazine "16Rnd_9x21_Mag";
			};
		};
	};

	if (_wep==1) then {
		_veh setVariable ["wep",	true,	true];
		_arr2 = ["arifle_AKM_F","arifle_AKS_F","launch_RPG7_F"];
		{
			_round = floor (random 3);
			_veh addItemCargoGlobal [_x, _round];
		} foreach _arr2;
	} else {
		_veh setVariable ["wep",	false,	true];
	};
	{
		_x setVariable ["veh",_veh,true];
		_x addMPEventHandler [
			"MPKilled",
			{
				_unit = _this select 0;
				moveOut _unit;
				hideBody _unit;
				if (((_unit getVariable ("veh")) getVariable "wep")==1) then {
					teamScore = teamScore + 1;
				} else {
					teamScore = teamScore - 1;
				};
			}
		
		];
		
	} forEach (crew _veh);
	
	
	_veh setVariable ["crew",(crew _veh),true];
	hq setVariable ["passedArr",[arrest,_veh,player,[_bomb,_wep]],true];
	sleep 0.1;
	hq setVariable ["Global", true, true];
	
	
	_veh setVariable ["player",player,true];
	_veh addEventHandler [
		"getOut",
		{
			((_this select 0) getVariable "player") setVariable [
				"cars",
				(((_this select 0) getVariable "player") getVariable "cars") - [_this select 0],
				true
			];
		}
	];
	
	if (((side _unit))==resistance) then {
	
		_veh doMove (getMarkerPos "check");
	} else {
		_veh doMove (getMarkerPos "check3");
	};
	
	waituntil{(_veh distance (getMarkerPos "check"))<200};
	_veh setSpeedMode "LIMITED";
	_count 		= 0;
	_offset 	= 0;
	
	if (((side _unit))==resistance) then {
			player setVariable ["cars",(player getVariable "cars") + [_veh]];
	
		
		_count = (count (player getVariable "cars"));
		_offset = [
			(((getMarkerPos "check") select 0) - ((getMarkerPos "check2") select 0)) * ((_count) - 1),
			(((getMarkerPos "check") select 1) - ((getMarkerPos "check2") select 1)) * ((_count) - 1),
			(getMarkerPos "check") select 2
		];
		_veh doMove [
			((getMarkerPos "check") select 0) - (_offset select 0),
			((getMarkerPos "check") select 1) - (_offset select 1),
			((getMarkerPos "check") select 2)
		];
	} else {
		_veh doMove (getMarkerPos "end");
	};
	
	waituntil{(_veh distance (getMarkerPos "check"))<300};
	_group setSpeedMode "LIMITED";
	if ((((side _unit))==east)&&((round random 1)==0)) then {
		{
			(group _x) leaveVehicle _veh;
			doGetOut _x;
		} foreach (crew _veh);
	};
	
		
	
	
	if (_bomb == 1) then {
	
		_bomb	= createVehicle [
			"IEDUrbanSmall_F",
			[0,0,0],
			[],
			0,
			"NONE"
		];
		
		_bomb attachTo [
			_veh,
			[
				(random 1.25)-0.625,
				((random 1.6) * (-1)),
				-1 + ((random 1)/3)
			]
		];
	};
	
	waitUntil{(count (crew _veh))==0};
	_veh setVariable ["bomb",999,true];
	sleep 5;
	_unit = (createGroup west) createUnit [
		"B_T_soldier_F",
		[0,0,0],
		[],
		0,
		"NONE"
	];
	{
		_unit removeWeaponGlobal _x;
	} forEach (weapons _unit);

	removeAllAssignedItems _unit;
	_unit allowDamage false;
	_unit setPos (getMarkerPos "spawner");
	sleep 10;
	_unit switchMove "";
	_unit assignAsDriver _veh;
	[_unit] orderGetIn true;
	waitUntil {unitReady _unit};
	_veh setDamage 0;
	waitUntil {(vehicle _unit)==_veh};
	gate animate ["Door_1_rot", 1];
	sleep 2;
	_veh doMove (getMarkerPos "end");
	waitUntil {(_veh distance (getmarkerpos "end"))<100};
	if ((_veh getVariable "wep")==1) then {
		teamscore = teamscore + 2;
		deleteVehicle _veh;
	};

};





_queue = {
	_current = objNull;
	_car = objNull;
	
	while {alive player} do {
		_car 	= (player getVariable "cars") select 0;
		_count 	= (count (player getVariable "cars"));
		
		waitUntil{((count (player getVariable "cars"))>0)};
		
		_car 	= (player getVariable "cars") select 0;
		_bomb	= _car getVariable "bomb";
		_run	= _this select 0;
		_wep	= _car getVariable "wep";
		_car setVariable ["Clear", false,true];
		if (((side (driver _car)))==resistance) then {
			waitUntil{(_car distance (getMarkerPos "check"))<100};
			waitUntil {unitReady _car};
			player addAction [
				"<t color='#FFD700'>Next</t>",
				{
					gate animate ["Door_1_rot", 1];
					sleep 0.75;
					player playAction "gestureFollow";
					sleep 1.25;
					_car	= (_this select 3) select 2;
					(_this select 0) removeAction (_this select 2);
					_car domove (getmarkerpos "checkpoint");
					player setVariable ["cars", (player getVariable "cars")- [_car],true];
					{
					
						_count = (count (player getVariable "cars"));
						_offset = [
							(((getMarkerPos "check") select 0) - ((getMarkerPos "check2") select 0)) * ((_count) - 1),
							(((getMarkerPos "check") select 1) - ((getMarkerPos "check2") select 1)) * ((_count) - 1),
							(getMarkerPos "check") select 2
						];
						_x doMove [0,0,0];
						_x doMove [
							((getMarkerPos "check") select 0) - (_offset select 0),
							((getMarkerPos "check") select 1) - (_offset select 1),
							((getMarkerPos "check") select 2)
						];
						sleep 0.5;
					} forEach (player getVariable "cars");
					if (((round(random 2))==2)&&(((_this select 3) select 3)==1)) then {
						_car doMove (getMarkerPos (((_this select 3) select 1) select (round(random 2))));
						(_car) setVariable ["Next", true,true];
						waitUntil{(_car distance (getmarkerpos "checkpoint"))<13.5};
						player playAction "gestureFreeze";
						gate animate ["Door_1_rot", 0];
					} else {
						_car addAction [
							"<t color='#FFD700'>Clear</t>",
							{
								
								(_this select 0) setVariable ["Next", true,true];
								player playAction "gestureGo";
								sleep 0.75;
								(_this select 0) domove (getmarkerpos "end");
								(_this select 0) removeAction (_this select 2);
								(_this select 0) setVariable ["Clear", true,true];
								if ((_this select 3)==1) then {
									if ((alive (driver (_this select 0)))&&((side (driver (_this select 0)))!=west)) then {
									_bomb1 = "SatchelCharge_Remote_Ammo_Scripted" createVehicle getpos (_this select 0);
									_bomb1 setDamage 1;
									};
									waitUntil {((getpos _car) distance (getmarkerpos "end"))<100};
									if ((_car getVariable "wep")==1) then {
										teamscore = teamscore + 2;
										deleteVehicle _veh;
									};
								} else {
									teamScore = teamScore + 1;
									publicVariable "teamScore";
								};
							},
							(_this select 3) select 0,
							0,
							true,
							true,
							"",
							"(count (crew _this))>0",
							9,
							false
						];

						waitUntil{(_car distance (getmarkerpos "checkpoint"))<13.5};
						player playAction "gestureFreeze";
						sleep 1;
						gate animate ["Door_1_rot", 0];
						if (((_this select 3) select 0)==1) then {
							sleep ((round random 10) + 7);
							if ((alive (driver _car))&&((side (driver (_car)))!=west))  then {
							_bomb1 = "SatchelCharge_Remote_Ammo_Scripted" createVehicle getpos (_this select 0);
							_bomb1 setDamage 1;
							};
						};
					};
					
				},
				[_bomb,_run, _car, _wep],
				0,
				true,
				true,
				"",
				"true",
				25,
				false
			];
			
				waitUntil{((_car getVariable "Next"))};
			
			
			
		};
		
	};
};
	
_loop = [["north","end","north"]] spawn _queue;

while {true} do {
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
		]
	] spawn _createCar;

	sleep (random [0,30, 40]);
};

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
