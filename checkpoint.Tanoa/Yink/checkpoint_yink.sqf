/* ArmA 3 Checkpoint script
 * by: Yink

 * This script can be used to create a checkpoint wherever you want.

 * needed: markers called spawn, checkpoint, check, check2, jail, and end.

 * "checkpoint" is the center of the checkpoint. its where cars will come and stop to be checked.
 * "spawn" is where the cars will spawn. put it around a hill or a bend down the road so the players cant see the car spawn.
 * "check" is where the first car in line will wait to be checked.
 * "check2" is basically there to gauge placement of the cars in line, by direction and distance. 
 *		for example, if theres 3 cars in line, the first car will be at "check", 2nd at "check2", and 
 *	 	3rd one equidistant (the distance from "check-">"check2") from the 2nd car. its good to have "check" and 
 * 		"check2"on a straight road.
 * "end" is the marker where the cars will drive if they've been cleared.
 * "jail" is where successfully arrested individuals will be held.

 * calling code:
 * array of arrays
 * 1. 5 default vehicles, change it to whatever vehicle you want, just make sure its all in the first array.
 * 2. east north and west are not used
 * 3. state the classname of the civilians. random clothing.
 * 4. not used
 * 5. the 5 marker names (probably dont change them, easier just to make them) and a variable reference to an object that 
 * 	serves as the "next car" button. in my mission i use a bar gate that is rotated up and down accordingly. 
 * 	(MUST HAVE ONE NAMED GATE, OR SCRIPT WONT BE PLAYABLE)

*/


grpEast = createGroup east;
missionNameSpace setVariable ["cars",[],true];
missionNameSpace setVariable ["cars1",[],true];

// function to create the car with bombs,weapons,passengers
_createCar = {
	// select passed parameteres and generate random numbers
	_cars       = _this select 0;
	_loc        = _this select 1;
	_man        = _this select 2;
	_run        = _this select 3;
	_spawn      = _this select 4 select 0;
	_jail       = _this select 4 select 1;
	_check      = _this select 4 select 2;
	_check2     = _this select 4 select 3;
	_checkpoint = _this select 4 select 4;
	_gate       = _this select 4 select 5;
	_func       = _this select 5;
	_side       = round(random 7);
	_bomb       = round(random 5);
	_wep        = round(random 4);
	_group      = grpNull;
	
	if (_side==3) then {
		_group  = grpEast;
		_man    = "I_C_Soldier_Bandit_8_F";
	} else {
		_group  = createGroup resistance;
		_group setBehaviour "CARELESS";
	};

	// create vehicle
	_car = _cars select (floor (random (count _cars)));
	_veh = createVehicle [_car, getMarkerPos _spawn, [], 0, "NONE"];
	
	_veh setDir (_veh getRelDir (getMarkerPos _check));
	if (_side != 3) then {
		missionNameSpace setVariable ["cars1", (missionNamespace getVariable "cars1") + [_veh], true];
	};
	
	// create units into _veh with event handlers
	for [{_i=1},{_i<=(ceil(random (_veh emptyPositions "CARGO")))},{_i = _i + 1}] do {                  
	
		_hasCargo = _veh emptyPositions "CARGO" > 0;
		
		if (_hasCargo) then {
			_unit = _group createUnit [
				format [_man,ceil(random 6)],
				[0,0,0],
				[],
				0,
				"CARGO"
			];
			_unit setUnitPos "UP";
			[_unit] joinSilent _group;
			if (isNull (driver _veh)) then {
				(_unit moveInDriver _veh);
			};
			_unit setVariable ["arrested",  false,  true];
			_unit setVariable ["veh",       _veh,   true];
			_unit setUnitPos "UP";
			_unit addMPEventHandler [
				"MPKilled",
				{
					_unit = _this select 0;
					moveOut _unit;
					hideBody _unit;
					if (((_unit getVariable "veh") getVariable "wep")) then {
						teamScore = teamScore + 1;
					} else {
						teamScore = teamScore - 1;
					};
				}
			];
			spawn1 = _spawn;
			jail    = _jail;
			publicVariable "jail";
			publicVariable "spawn1";
			
			_unit addEventHandler [
				"GetOutMan",
				{
					[
						_this select 0,
						{
							_unit = _this;
							_arrestNum = _unit addAction [
								"<t color='#FF0000'>Arrest</t>",
								{
									_unit   = _this select 0;
									_spawn  = (_this select 3) select 1;
									_jail   = (_this select 3) select 2;
									_veh    = _unit getVariable "veh";
									_wep    = _veh getVariable "wep";
									_unit setVariable ["wep",_wep,true];
									_bomb   = _veh getVariable "bomb";
									_run    = round(random 4);
									// remove action
									[
										_unit,
										{
											_id = _this getVariable "arrestNum";
											_this removeAction _id;
										}
									] remoteExec ["call1", 0];
									// run or be arrested 
									if (((_bomb)||(_wep))&&(_run==1)) then {        
										[
											[_unit, _spawn],
											{
												(_this select 0) switchMove "";
												(_this select 0) setUnitPos "UP";
												(_this select 0) switchMove "Stand";
												(_this select 0) doMove (getMarkerPos (spawn1));
											}
										] remoteExec ["call1", 0];  
									} else {
										// arrested
										[
											[_unit, _jail],
											{
												(_this select 0) switchMove "";
												(_this select 0) forceWalk true;
												(_this select 0) playActionNow "Stand";
												(_this select 0) setUnitPos "UP";
												unassignVehicle (_this select 0);
												hintSilent format["%1 is heading to the holding cell.",name (_this select 0)];
												(_this select 0) doMove (getMarkerPos (jail));
												(_this select 0) playActionNow "Stand";
												sleep 1;
												while {(((_this select 0) distance (getMarkerPos (jail)))>5)} do {
													(_this select 0) doMove (getMarkerPos (jail));
													sleep 1;
												};
												waitUntil {((_this select 0) distance (getMarkerPos (jail)))<5};
												waitUntil {unitReady (_this select 0)};
												(_this select 0) playAction "surrender";
												hintSilent format ["%1 has been arrested!", name (_this select 0)];
												arrested = arrested + [_this select 0];
												publicVariable "arrested";
											}
										] remoteExec ["call1", 0];  
									};
					
								},
								[objNull, spawn1, jail],
								0,
								true,
								true,
								"",
								"(alive _target)",
								3,
								false
							];
							_unit setVariable ["arrestNum",_arrestNum];
						}
					] remoteExec ["call1", 0];  
				}
			];
	
					
					
					
					
			if ((round (random 4)==1)&&((_wep == 1)||(_bomb == 1))) then {
				_unit addWeapon "hgun_P07_F";
				_unit addMagazine "16Rnd_9x21_Mag";
			};
		};
	};
	if (_side!=3) then {
		_veh setUnloadInCombat [FALSE,FALSE];
		{_x disableAI "AUTOCOMBAT"} forEach (crew _veh);
		{_x disableAI "FSM"} forEach (crew _veh);
	} else {
		_veh moveTo (getMarkerPos _checkpoint);
		_veh setUnloadInCombat [TRUE,TRUE];
	};
	
	takeAway = {
		_veh = _this;
		waitUntil {(_this distance (getMarkerpos "impound"))<20};
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
		_unit switchMove "";
		_unit assignAsDriver _veh;
		[_unit] orderGetIn true;
		waitUntil {(vehicle _unit)==_veh};
		_veh setDamage 0;
		sleep 2;
		_veh doMove (getMarkerPos "end");
		waitUntil {(_veh distance (getmarkerpos "end"))<100};
		if ((_veh getVariable "wep")) then {
			teamscore = teamscore + 2;
			deleteVehicle _veh;
		};
	};
	
	_veh addEventHandler [
		"getOut",
		{
			_veh = _this select 0;
			if ((count (crew _veh))==0)  then {
				if ((_veh distance (getMarkerpos "impound"))<20) then {
					_veh spawn takeAway;
				};
				missionNameSpace setVariable ["cars", (missionNamespace getVariable "cars") - [_veh], true];
				[
					_gate,
					player getVariable "gate"
				] remoteExec ["removeAction",0];
			};
		}
	];
	
	[
		[_veh,objNull, _spawn, _jail],
		(_func select 2)
	] remoteExec ["spawn",0];

	// add weapons if applicable and set vehicle variables
	if (_wep==1) then {
		_veh setVariable ["wep",    true,   true];
		_arr2 = ["arifle_AKM_F","arifle_AKS_F","launch_RPG7_F"];
		
		{
			_round = floor (random 3);
			_veh addItemCargoGlobal [_x, _round];
			
		} foreach _arr2;
		
	} else {
	
		_veh setVariable ["wep",    false,  true];
		
	};

	// create bomb if applicable and set vehicle variables
	if (_bomb == 1) then {
		_veh setVariable ["bomb",   true,   true];
		
		_bomb   = createVehicle [
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
				-1 + ((random 1 / 3)
			]
		];
	} else {
		_veh setVariable ["bomb",   false,  true];
	};

	_veh doMove (getMarkerPos _check);
	[_veh,_check,_side] spawn {
		_veh = _this select 0;
		_check = _this select 1;
		_side = _this select 2;
		waitUntil { (_veh distance (getMarkerPos _check))<450};
		if (_side != 3) then {
			missionNameSpace setVariable ["cars", (missionNamespace getVariable "cars") + [_veh], true];
		};
	};
	
	_veh spawn {
		waitUntil {(count (crew _this)) == 0};
		
		if (_this == (missionNameSpace getVariable "curCar")) then {
			missionNameSpace setVariable ["cur",true,true];
		};
		missionNameSpace setVariable ["cars", (missionNamespace getVariable "cars") - [_this], true];
	};
// return the car
_veh
};

/* Hold the driver for further questioning. No decisions have yet been made, no points awarded.
 *
 * "Are you detaining me, or am I free to go?"
 */
_detain = {

};

/* Add action that allows drivers to be arrested if they fail the checkpoint. 
 *
 */
_arrest = {
	_veh    = _this select 0;
	_player = _this select 1;
	_spawn  = _this select 2;
	_jail   = _this select 3;
	
	// create function for arresting, forces to surrender
	_arrested = {
		_unit   = _this select 0;
		_run    = _this select 1;
		_veh    = (_this select 0) getVariable "veh";
		_wep    = _veh getVariable "wep";
		_bomb   = _veh getVariable "bomb";
		_has_hgun = _unit hasWeapon "hgun_P07_F";

		if (!(_has_hgun) && !(_wep) && !(_bomb)) then {
			// Normal Civilian
			[	_unit,
				{
					doGetOut _this;
					[_this] joinSilent (createGroup resistance);
					(group _this) setBehaviour "CARELESS";
					waitUntil {vehicle _this == _this};
					sleep 1;
					_this switchMove "";
					unassignVehicle _this;
					(group _this) setBehaviour "CARELESS";
					_this playAction "surrender";
					_this setUnitPos "UP";
					sleep 1;
					hintSilent format ["%1 surrendered.", name _this];
				}
			] remoteExec ["call1", 0];
					
		} else {
			if (_run == 1 && !(_has_hgun)) then {
				// Driver wants to run and doesn't have a weapon.
				[
					_unit,
					{
						doGetOut _this;
						_this setUnitPos "UP";
						[_this] joinSilent (createGroup east);
						(group _this) setBehaviour "CARELESS";
						waitUntil {((vehicle _this) == _this)};
						_this switchMove "";
						_this doMove (getmarkerPos "spawn");
					}
				] remoteExec ["call1", 0];
			
				[
					_unit,
					{
						_id = player getVariable (str _this);
						_this removeAction _id;
					}
				] remoteExec ["call", 0];
			} else {
				if (_unit hasWeapon "hgun_P07_F") then {
					// Is armed and doesn't run
					[
						_unit,
						{
							doGetOut _this;
							_this setUnitPos "UP";
							[_this] joinSilent (createGroup east);
							(group _this) setCombatMode "RED";
							player addRating 7000;
							waitUntil {((vehicle _this) == _this)};
							_this setUnitPos "UP";
							_this switchMove "";
							_this doMove getPos _this;
							_this setpos getPos _this;
							sleep 1;
							hint format["%1 pulled out a firearm!",name _this];
						}
					] remoteExec ["call1", 0];
				} else {
					// if is not armed and doesnt run
					[	_unit,
						{
							doGetOut _this;
							waitUntil {((vehicle _this) == _this)};
							_this switchMove "";
							[_this] joinSilent (createGroup resistance);
							(group _this) setBehaviour "CARELESS";
							_this setUnitPos "UP";
							_this playAction "surrender";
							sleep 1;
							hintSilent format["%1 surrendered.",name _this];
						}
					] remoteExec ["call1", 0];
				};
			};
		};
	};  
	
	_run    = round (random 3);
	// create action for arresting, each passenger
	//[
		//[_surrender,_spawn,_jail,_veh,_run],
		//{
			// _surrender   = _this select 0;
			// _spawn       = _this select 1;
			// _jail        = _this select 2;
			// _veh     = _this select 3;
			// _run     = _this select 4;

		//}
	//] remoteExec ["spawn",0];
	
	// create vehicle action    
	_detainIndex = _veh addAction [
		"<t color='#C0C0C0'>Detain</t>",
		{
			_veh = _this select 0;
			_spawn = (_this select 3) select 1;
			_jail = (_this select 3) select 2;
			[
				_veh,
				{
					// _id = _this getVariable "detainNum";
					// _this removeAction _id;
				}
			] remoteExec ["call1", 0];
			missionNameSpace setVariable ["cur",true,true];
			player playAction "gestureGo";
			player say3D ["see_id", 25, 1];
			sleep 2;
			_run    = round (random 4);
			[	[_veh, (_this select 3) select 0, _run], 
				{
					{   
						nilValue = [_x,_this select 2] spawn (_this select 1);
						(group (_x)) leaveVehicle (_this select 0);
						_x setUnitPos "UP";
						doStop _x;
					} forEach (crew (_this select 0));
				}
			] remoteExec ["call1", 0];
		}, [_arrested,_spawn,_jail], 0, true, true, "", "((side (driver _target))==resistance)&&((count crew _target)>0)", 6, false ];
	
	[	[_veh, _detainIndex],
		{
			player setVariable[
			str (_this select 0),
			(_this select 1),
			false
			];
		}
	] remoteExec ["call", 0];
	
};
// clear the current veh that was called from _next
_clear  = {

};



/* Controls vehicle movement once unit enters the queue at the checkpoint.
 *
 */
_movement = {
	// moves the passed veh to correct position
	_movement = {
		_veh    = _this select 0;
		_count  = _this select 1;
		_check  = _this select 2 select 0;
		_check2 = _this select 2 select 1;
		_offset = [
			(((getMarkerPos _check) select 0) - ((getMarkerPos _check2) select 0)) * (((_count) - 0)*1),
			(((getMarkerPos _check) select 1) - ((getMarkerPos _check2) select 1)) * (((_count) - 0)*1),
			(getMarkerPos _check) select 2
		];
		doStop _veh;
		_veh doMove [0,0,0];
		_veh doMove [
			((getMarkerPos _check) select 0) - (_offset select 0),
			((getMarkerPos _check) select 1) - (_offset select 1),
			((getMarkerPos _check) select 2)
		];
		sleep 1;
	};

	// clear function
	_clear = {
		// TODO create clearance function, take in 'cur' from missionamespace and change it
		_veh    = _this select 0;
		_wep    = _veh getVariable "wep";
		_bomb   = _veh getVariable "bomb";
		[
			_veh, 
			{   _id = _this getVariable "clearNum";
				player removeAction _id; 
			},
		] remoteExec ["call1", 0];
		missionNameSpace setVariable ["cur",true,true];
		[
			_veh,
			(getMarkerPos "end")
		] remoteExec ["doMove",0];
		if (((_wep)||(_bomb))&&((side (driver _veh))==resistance)) then {
			teamScore = teamScore - 1;
			player playAction "gestureGoB";
			player say3D ["move_along", 25, 1];
		} else {
			teamScore = teamScore + 1;
			if ((_wep)||(_bomb)) then {
				teamScore = teamScore + 2;
			} else {
				player playAction "gestureGoB";
				player say3D ["move_along", 25, 1, // playSound3D [_soundToPlay, (player), false, getPos player, 50, 1, 25];
												   // Volume db+10, volume drops off to 0 at 50 meters from _sourceObject
			};
		};
		if ((_bomb)&&((side (driver _veh))==resistance)) then {
			(_this) select 0 setDamage 1;
		};
		
	};
// next car drives up
	_next = {
		_veh = (missionNameSpace getVariable "cars") select 0;

		missionNameSpace setVariable ["curCar",_veh];
		missionNameSpace setVariable ["cars",(missionNameSpace getVariable "cars") - [_veh], true];
		[
			((_this select 3) select 0),
			player getVariable "gate"
		] remoteExec ["removeAction",0];
		_clear = (_this select 3) select 2;
		missionNameSpace setVariable ["cur",false,true];
		((_this select 3) select 0) animate ["Door_1_rot", 1];
		sleep 0.75;
		(_this select 1) playAction "gestureFollow";
		sleep 1.25;
		[
			_veh,
			(getMarkerPos "checkpoint")
		] remoteExec ["doMove",0];
			
		waitUntil{(_veh distance (getmarkerpos "checkpoint"))<11.5};
		(_this select 1) playAction "gestureFreeze";
		((_this select 3) select 0) animate ["Door_1_rot", 0];
		
		[
			[_veh,_clear],
			{
				_clearNum = (_this select 0) addAction [
					"<t color='#FF8C00'>Car is Clear</t>",
					_this select 1,
					_this select 0,
					0,
					true,
					true,
					"",
					"(((unitReady _target)&&(!(missionNameSpace getVariable 'cur')))&&((side (driver _target))==resistance))",
					10,
					false
				];
				(_this select 0) setVariable ["clearNum", _clearNum];
			}
		] remoteExec ["call1",0];
		sleep (10 + round(random 10));
		_bomb = _veh getVariable "bomb";
		if (_bomb) then {
			_veh call _clear;
		};
	};
	
	

	// loops that controls the next car driving up, calls _next
	_nextReady = {
		_nextVeh = objNull;
		while {true} do {
			_next       = _this select 0;
			_gate       = _this select 1;
			_checkpoint = _this select 2;
			_clear      = _this select 3;
			waitUntil {(count (missionNameSpace getVariable "cars"))>0};
			
			// hint format["waituntil ready\n%1",(missionNameSpace getVariable "cars")];
			waitUntil {((unitReady ((missionNameSpace getVariable "cars") select 0))&&((((missionNameSpace getVariable "cars") select 0) distance _gate)<200))};
			[
				[_next,[_gate,_checkpoint,_clear]],
				{
					_gateNum = ((_this select 1) select 0) addAction [
						"<t color='#FFD700'>Next Car</t>",
						_this select 0,
						_this select 1,
						0,
						true,
						true,
						"",
						"((unitReady ((missionNameSpace getVariable 'cars') select 0))&&(missionNameSpace getVariable 'cur'))",
						20,
						false
					];
					player setVariable ["gate", _gateNum];
				}
			] remoteExec ["call",0];
			_arr1 = (missionNameSpace getVariable "cars");
			waitUntil {((missionNameSpace getVariable "cars") select 0)!=(_arr1 select 0)};
			// hint format[" added action, awaiting deletion\n%1",(missionNameSpace getVariable "cars")];
			sleep 1;
			if ((count (missionNameSpace getVariable "cars"))>1) then {
				_nextVeh = ((missionNameSpace getVariable "cars") select 1);
				waitUntil {((_nextVeh) == ((missionNameSpace getVariable "cars") select 0))||((count ((missionNameSpace getVariable "cars")))==0)};
			};
		};
	};
	
	_spawn      = _this select 0;
	_check      = _this select 2;
	_check2     = _this select 3;
	_checkpoint = _this select 4;
	_gate       = _this select 5;
	_veh        = objNull;
	_cur        = objNull;
	_queue      = [];
	
	[_next,_gate,_checkpoint,_clear] spawn _nextReady;
	
	while {true} do {
		_cars = missionNameSpace getVariable "cars";
		// hint format["%1\n%2\n428", (count (missionNameSpace getVariable "cars")),(count _cars)];
		waitUntil {(count (missionNameSpace getVariable "cars"))>0};
		{
			if (((_x getVariable "orders")==0)&&(alive (driver _x))&&((side driver _x)!=east)) then {
				_queue = _queue + [_x];
				_x setVariable ["orders",0];
			} else {
				_x doMove (getMarkerPos _checkpoint);
				missionNameSpace setVariable ["cars", missionNameSpace getVariable "cars" - [_x]];
			};
		} forEach _cars;
		// hint format["%1\n%2\n439", missionNameSpace getVariable "cars" select 0,(count _cars)];
		waitUntil {(count (missionNameSpace getVariable "cars"))!= (count _cars)};
		sleep 2;
		// hint format["%1\n%2\n4442", missionNameSpace getVariable "cars" select 0,(count _cars)];
		sleep 2;
		_cars = missionNameSpace getVariable "cars";
		{
			[_x, _forEachIndex,[_check,_check2]] call _movement;
		} forEach _cars;
	};
	
};


// vehicle spawn controller
_main_loop = {
	(_this select 4) spawn _movement;
	sleep 15;
	while { true } do {
		_cars = missionNameSpace getVariable "cars";
		_veh  = _this call ((_this select 5) select 0);
		sleep ((30-(count allPlayers) + (round (random (40 - ((count allPlayers)*2))))));
	};
};



// Finally, start the main loop
(_this + [[ _createCar, _detain, _arrest, _clear ]]) call _main_loop;