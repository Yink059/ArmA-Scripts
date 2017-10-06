teamScore = 0;
publicVariable "teamScore";
arrested = [];
sleep 15;
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
				};
			} forEach arrested;
		};
	};
};

_ambience = {
	while {true} do {
		sleep ((round (Random 25)) + 5);
		_randX 	= round (random 500);
		_randY	= round (random 500);
		
		_bomb = "Bo_GBU12_LGB_MI10" createVehicle [
			(((getmarkerpos "arty") select 0) + _randX) - 250,
			(((getmarkerpos "arty") select 1) + _randY) - 250,
			10
		];
	};
};

[] spawn _transport;
[] spawn _ambience;



waitUntil {(!isNull player)||(isServer)};


player disableNVGEquipment true;
hq setVariable ["Global", false, true];
hq setVariable ["passedArr", [], true];
[guard1,'WATCH1','ASIS'] remoteExec ['BIS_fnc_ambientAnim',0,true];
[guard1_2,'WATCH1','ASIS'] remoteExec ['BIS_fnc_ambientAnim',0,true];
[guard1_1,'WATCH1','ASIS'] remoteExec ['BIS_fnc_ambientAnim',0,true];
arrested = [];


arrest = {
	_car	= _this select 1;
	_caller	= _this select 2;
	_arr	= _this select 3;
	_car setVariable ["crew",(crew _car)];
	{
		_x setVariable ["arrest1", 0];
	} forEach (crew _car);
	
	removeArrest = {
		(_this select 1) removeAction (player getVariable "detainNum");
	};
	_detainNum = _car addAction [
		"<t color='#C0C0C0'>Detain</t>",
		{

			_arr = (_this select 3) select 0;
			_car = (_this select 3) select 1;
			_car setVariable ["Next",true];
			hint format["%1\n\n%2",_car,_arr];
			_detain = (_this select 0) getVariable "detain";
			if ((((_arr select 0)==1)||((_arr select 1)==1))&&(_detain==0)) then {
				(_this select 0) doMove (getMarkerPos "end");
			} else {
				if (1<0) then {
					//(_this select 0) doMove (getMarkerPos "end");
				} else {
					{
						_x setVariable ["arrest1",1];
					} forEach (crew (_this select 0));
					_removeAction1 = {
						(_this select 1) playAction "stand";
						(_this select 1) switchMove "stop";
						(_this select 1) removeAction (player getVariable "arrestNum");
						waitUntil {((_this select 1) distance (getmarkerPos "jail"))<3};
						(_this select 1) playAction "surrender";
					};
					_arrestAction = {
						_arrests = [];
						_car = _this select 1;
						{
							(group _x) leaveVehicle _car;
							doGetOut _x;
							_x forceWalk true;
							doStop _x;
							sleep 3;
							_x setpos (Getpos _x);
							_surrender = round(random 1);
							_x playActionNow "surrender";
							
							_arrestNum = _x addAction [
								"Arrest",
								{
									sleep 1;
									hintSilent format ["Arresting %1...", name (_this select 0)];
									if (((round (random 2))!=1)||(!((((_this select 0) getVariable "veh") getVariable "wep")==1))) then {
										(_this select 0) playAction "stand";
										(_this select 0) switchMove "";
										(_this select 0) doMove (getmarkerpos "jail");
										hq setVariable ["passedArr",[removeAction1,(_this select 0),_this select 2],true];
										hq setVariable ["Global", true, true];
										sleep 0.2;
										hint str (_This select 0);
										waitUntil {((_this select 0) distance (getmarkerPos "jail"))<3};
										(_this select 0) playAction "surrender";
										arrested = arrested + [(_this select 0)];
										publicVariable "arrested";
										hint format["%1\nArrested!", name (_this select 0)];
										if ((((_this select 0) getVariable "veh") getVariable "wep")==1) then {
											teamscore = teamscore + 2;
										};
										if ((((_this select 0) getVariable "veh") getVariable "bomb")==1) then {
											teamscore = teamscore + 3;
										};
									} else {
										(_this select 0) switchMove "";
										(_this select 0) forceWalk false;
										if ((_this select 3)==1) then {
											_group = createGroup east;
											[(_this select 0)] joinSilent _group;
										} else {
											(_this select 0) doMove (getMarkerPos "test");
										};
									};
								},
								_surrender,
								0,
								true,
								true,
								"",
								"true",
								3,
								false
							];
							player setVariable ["arrestNum",_arrestNum,true];
						} forEach (_car getVariable "crew");
					};
					hq setVariable ["passedArr",[_arrestAction,_car],true];
					sleep 1;
					hq setVariable ["Global", true, true];
					sleep 1;
					hq setVariable ["passedArr",[_removeArrest,_car],true];
					hq setVariable ["Global", true, true];
				};
			};
		},
		[_arr,_car],
		0,
		true,
		true,
		"",
		"true",
		5
	];
	_car addEventHandler [
		"getOut",
		{
			_car = _this select 0;
			_unit = _this select 2;
			if ((_unit getVariable "arrest1")==0) then {
				hq setVariable ["passedArr",[arrestAction,_car],true];
	sleep 1;
				hq setVariable ["Global", true, true];
			};
			if ((count (crew _car))==0) then {
				hq setVariable ["passedArr",[removeArrest,_car],true];
				sleep 1;
				hq setVariable ["Global", true, true];
			};
		}	
	];
	player setVariable ["detainNum",_detainNum,true];
};

global1 = {
	while {alive player} do {
		waitUntil {((str(hq getVariable "Global"))=="true")};	
		sleep 1;
		(hq getVariable "passedArr") spawn ((hq getVariable "passedArr") select 0);
		sleep 1;
		hq setVariable ["Global", false, true];
		//hq setVariable ["Global", true, true];
	};
};
player addRating 999;
hq setVariable ["Global", false, true];
_handle = [] spawn global1;
gate allowDamage false;
player addScore 999;

player removePrimaryWeaponItem "acc_pointer_IR";
player addPrimaryWeaponItem "acc_flashlight";


player setVariable ["cars",[],true];
player action ["lightOn",  truck];

if (isServer) then
{
	execVM "car.sqf";
};
nul = [] execVM "intro\intro.sqf";
sleep 21;
	leader1 setpos (getMarkerPos "p1");
	engi1 setpos (getMarkerPos "p2");
	medi1 setpos (getMarkerPos "p3");
	mark1 setpos (getMarkerPos "p4");
	
hintSilent "init.sqf loaded Successfully!";
//this addaction ["test","car.sqf"];
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