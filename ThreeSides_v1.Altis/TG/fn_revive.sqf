/********************************************
			FAR Revive 1.5
			INS revive 0.3.1
			SRS revive Jan. 29 2015
			TG Edit: 2015_02_23
			
Credits: 
	Naong for INS revive system
	Farooq for FAR revive system
	Monsoon for SRS revive system
	
	|TG| B for fusion of the three systems and 
		squashing existing bugs as well as add 
		enhancements	
*********************************************/

//------------------------------------------//
// Parameters - Feel free to edit these
//------------------------------------------//

// param added by Unk for TvT CTF
bleedoutTimer = "BleedOutTime" call BIS_fnc_getParamValue;
respawnAfterTime = "RespawnAfter" call BIS_fnc_getParamValue;

// Seconds until unconscious unit bleeds out and dies. Set to 0 to disable.
FAR_BleedOut 				= bleedoutTimer;	//Time before bleeding out and dying ***value from parameters description & init
FAR_MandatoryWait			= respawnAfterTime; //How long a player must wait before being able to suicide. Set it to 0 for non-respawn missions.  ***value from parameters description & init
FAR_reviveDuration 		= 30;	//How long does a revive take
FAR_medicAdvantage 		= 0.3;	//How much time medics need to revive. 1 = same as everybody... 0.5 = half the time. FAR_reviveDuration * FAR_medicAdvantage.
FAR_EnableDeathMessages 	= false;//Enable teamkill notifications
FAR_ReviveMode 			= 1; 	//0 = Only medics can revive;	1 = All units can revive;	2 = Same as 1 but a medikit is required to revive

FAR_medical_trucks = ["B_Truck_01_medical_F", "B_Slingload_01_Medevac_F"]; //used only along with FAR_ReviveMode = 0... If not medic anybody can revive when they are near these vehicles.

SRS_damageThreshold =  0.90;   // damage threshold before being knocked out (0->1)

//----Do Not Edit beyond this point, unless you know the deal----//

FAR_isDragging = false;
FAR_isDragging_EH = [];
FAR_deathMessage = [];
FAR_Debugging = false;

if (isDedicated) exitWith {};

FAR_Player_Actions = {
	if (alive player && player isKindOf "Man") then 
	{
		// addAction args: title, filename, (arguments, priority, showWindow, hideOnUse, shortcut, condition, positionInModel, radius, radiusView, showIn3D, available, textDefault, textToolTip)
		player addAction ["<t color=""#33CC33"">" + "Revive" + "</t>", "call FAR_handleAction", ["action_revive"], 10, true, true, "", "call FAR_Check_Revive"];
		player addAction ["<t color=""#FF33CC"">" + "Stabilize" + "</t>", "call FAR_handleAction", ["action_stabilize"], 10, true, true, "", "call FAR_Check_Stabilize"];
		player addAction ["<t color=""#0000FF"">" + "Drag" + "</t>", "call FAR_handleAction", ["action_drag"], 9, false, true, "", "call FAR_Check_Dragging"];
	};
};

FAR_handleAction = {
	private ["_params", "_action"];

	// Parameters passed by the action
	_params = _this select 3;
	_action = _params select 0;

	////////////////////////////////////////////////
	// Handle actions
	////////////////////////////////////////////////
	if (_action == "action_revive") then
	{
		[cursorTarget] spawn FAR_HandleRevive;
	};

	if (_action == "action_stabilize") then
	{
		[cursorTarget] spawn FAR_HandleStabilize;
	};	

	if (_action == "action_drag") then
	{	
		[cursorTarget] spawn FAR_Drag;
	};

	if (_action == "action_release") then
	{
		[] spawn FAR_Release;
	};	
};

INS_REV_FNCT_remote_exec = {
	private ["_unit", "_command", "_parameter"];
	_unit = _this select 1 select 0;
	_command = _this select 1 select 1;
	_parameter = _this select 1 select 2;
	
	if (_command == "switchMove") exitWith {
		_unit switchMove _parameter;
	};
	if (_command == "allowDamage") exitWith {
		if (_parameter) then {
			_unit allowDamage true;
			_unit setCaptive false;
		} else {
			_unit allowDamage false;
			_unit setCaptive true;
		};
	};
	
	if (local _unit) then 
	{
		switch (_command) do
		{
			//case "switchMove":	{_unit switchMove _parameter;};
			case "setDir":		{_unit setDir _parameter;};
			case "playMove":	{_unit playMove _parameter;};
			case "playMoveNow":	{_unit playMoveNow _parameter;};
			case "moveInCargo":	{_unit moveInCargo _parameter;};
		};
	};
};
"INS_REV_GVAR_remote_exec" addPublicVariableEventHandler INS_REV_FNCT_remote_exec;

// Switch move
// Usage : '[_unit, _move] call INS_REV_FNCT_switchMove;'
INS_REV_FNCT_switchMove = {
	private ["_unit","_move"];
	
	_unit = _this select 0;
	_move = _this select 1;
	
	//_unit switchMove _move;
	//processInitCommands;
	INS_REV_GVAR_remote_exec = [_unit, "switchMove", _move];
	publicVariable "INS_REV_GVAR_remote_exec";
	["INS_REV_GVAR_remote_exec", INS_REV_GVAR_remote_exec] spawn INS_REV_FNCT_remote_exec;
};

// Set allow damage
// Usage : '[_unit, _value] call INS_REV_FNCT_allowDamage;'
INS_REV_FNCT_allowDamage = {
	private ["_unit", "_value"];
	
	_unit = _this select 0;
	_value = _this select 1;
	
	INS_REV_GVAR_remote_exec = [_unit, "allowDamage", _value];
	publicVariable "INS_REV_GVAR_remote_exec";
	["INS_REV_GVAR_remote_exec", INS_REV_GVAR_remote_exec] spawn INS_REV_FNCT_remote_exec;
};

// Set dir
// Usage : '[_unit, _value] call INS_REV_FNCT_setDir;'
INS_REV_FNCT_setDir = {
	private ["_unit","_dir"];
	_unit = _this select 0;
	_dir = _this select 1;
	
	INS_REV_GVAR_remote_exec = [_unit, "setDir", _dir];
	publicVariable "INS_REV_GVAR_remote_exec";
	["INS_REV_GVAR_remote_exec", INS_REV_GVAR_remote_exec] spawn INS_REV_FNCT_remote_exec;
};

// Play move
// Usage : '[_unit, _move] call INS_REV_FNCT_playMoveNow;'
INS_REV_FNCT_playMove = {
	private ["_unit","_move"];
	_unit = _this select 0;
	_move = _this select 1;
	
	INS_REV_GVAR_remote_exec = [_unit, "playMove", _move];
	publicVariable "INS_REV_GVAR_remote_exec";
	["INS_REV_GVAR_remote_exec", INS_REV_GVAR_remote_exec] spawn INS_REV_FNCT_remote_exec;
};

// Play move now
// Usage : '[_unit, _move] call INS_REV_FNCT_playMoveNow;'
INS_REV_FNCT_playMoveNow = {
	private ["_unit","_move"];
	_unit = _this select 0;
	_move = _this select 1;
	
	INS_REV_GVAR_remote_exec = [_unit, "playMoveNow", _move];
	publicVariable "INS_REV_GVAR_remote_exec";
	["INS_REV_GVAR_remote_exec", INS_REV_GVAR_remote_exec] spawn INS_REV_FNCT_remote_exec;
};

// Move in cargo
// Usage : '[_unit, _vehicle] call INS_REV_FNCT_moveInCargo;'
INS_REV_FNCT_moveInCargo = {
	private ["_unit","_vehicle"];
	
	_unit = _this select 0;
	_vehicle = _this select 1;
	
	INS_REV_GVAR_remote_exec = [_unit, "moveInCargo", _vehicle];
	publicVariable "INS_REV_GVAR_remote_exec";
	["INS_REV_GVAR_remote_exec", INS_REV_GVAR_remote_exec] spawn INS_REV_FNCT_remote_exec;
};

FAR_HandleDamage_EH = 
{
	private ["_unit", "_killer", "_damage","_isUnconscious", "_bodyPart"];

	_unit 				= _this select 0;
	_bodyPart 			= _this select 1;
	_damage 			= _this select 2;	
	_killer 			= _this select 3;
	_isUnconscious 		= _unit getVariable "FAR_isUnconscious";
	
	_getTotalDamage = 
	{
		_curUnit = _this select 0;

		_head  = _curUnit getHit "head";
		_body  = _curUnit getHit "body";
		_legs  = _curUnit getHit "legs";
		_hands = _curUnit getHit "hands";

		_totalDamage = (_head * 0.4) + (_body * 0.4) + (_legs * 0.1) + (_hands * 0.1);

		if((_head >= SRS_damageThreshold) || (_body >= SRS_damageThreshold)) then{
			_totalDamage = SRS_damageThreshold;		
		};
		_totalDamage
	};
	
	_return = 0; //what is to be returned
	
	if (alive _unit && _isUnconscious == 0) then 
	{
		switch(_bodyPart) do
		{
			case "body":
			{
				_newDamage = (_unit getHit "body") + _damage;
				if(_newDamage > SRS_damageThreshold) then{
					_newDamage = SRS_damageThreshold;
				};
				_unit setHit ["body",_newDamage];
			};

			case "head":
			{
				_newDamage = (_unit getHit "head") + _damage;
				if(_newDamage > SRS_damageThreshold) then{
					_newDamage = SRS_damageThreshold;
				};
				_unit setHit ["head",_newDamage];
			};

			case "legs":
			{
				_newDamage = (_unit getHit "legs") + _damage;
				_unit setHit ["legs",_newDamage];
			};

			case "hands":
			{
				_newDamage = (_unit getHit "hands") + _damage;
				_unit setHit ["hands",_newDamage];
			};

			case "":
			{
				_newDamage = (damage _unit) + _damage;
				if(_newDamage > SRS_damageThreshold) then{
					_newDamage = SRS_damageThreshold;
				};
				_unit setHit ["body",_newDamage];
			};
			default {};
		};
		
		_return = [_unit] call _getTotalDamage;
		
		if(_return >= SRS_damageThreshold) then
		{
			_return = 0;
			
			if(_unit getVariable "FAR_isUnconscious" == 0) then
			{
				_unit setVariable ["FAR_isUnconscious", 1, true];
				[_unit, _killer] spawn FAR_Player_Unconscious;
			};
		};		
	};
	
	BIS_hitArray = _this; BIS_wasHit = True;
	_return	
};

// Check unit is underwater
// Usage(thread) : '[unit] call INS_REV_FNCT_is_underwater;'
// Return : boot
INS_REV_FNCT_is_underwater = {
	private ["_unit","_result"];
	_unit = _this select 0;
	_result = underwater _unit;
	_result
};

// Block respawn button
// Usage : 'spawn INS_REV_FNCT_respawnBlock;'
INS_REV_FNCT_respawnBlock = {
	private ["_ctrl","_enCtrl"];
	disableSerialization;
	
	while {!(call FAR_Check_Suicide) && player getVariable "FAR_isUnconscious" == 1} do 
	{
		waitUntil { !isNull (findDisplay 49)};

		if (!(call FAR_Check_Suicide) && player getVariable "FAR_isUnconscious" == 1) then
		{		
			_ctrl = (findDisplay 49) displayCtrl 1010; //respawn control
			_ctrl ctrlEnable false;
		};
		
		waitUntil {sleep 0.12; isNull (findDisplay 49)};
	};
};

// Check object is vehicle.
// Usage : '[object] call INS_REV_FNCT_is_vehicle;'
// Return : bool
INS_REV_FNCT_is_vehicle = {
	private ["_result", "_veh"];
	
	// Set variable
	_result = false;
	_veh = _this select 0;
	
	// Check object is vehicle
	if ((vehicle _veh isKindOf "LandVehicle" || vehicle _veh isKindOf "Air" || vehicle _veh isKindOf "Ship")) then {
		_result = true;
	};
	
	// Return value
	_result
};

// Get camera attach coordinate
// Usage : 'call INS_REV_FNCT_get_camAttachCoords;'
// Return : array
INS_REV_FNCT_get_camAttachCoords = {
	private ["_result","_xC","_yC","_zC"];
	
	_xC = INS_REV_GVAR_camRange * sin(INS_REV_GVAR_theta) * cos(INS_REV_GVAR_phi);
	_yC = INS_REV_GVAR_camRange * sin(INS_REV_GVAR_theta) * sin(INS_REV_GVAR_phi);
	_zC = INS_REV_GVAR_camRange * cos(INS_REV_GVAR_theta);
	_result = [_xC,_yC,_zC];
	
	_result
};

// Reset dead camera
// Usage : 'call INS_REV_FNCT_reset_camera;'
INS_REV_FNCT_reset_camera = {
	private ["_friendly","_camAttachCoords","_camStaticCoords"];
	
	//If not exitst INS_REV_GVAR_camPlayer, reset INS_REV_GVAR_camPlayer
	if (isNull INS_REV_GVAR_camPlayer) then {INS_REV_GVAR_camPlayer = player;};	
	//Set distance from the player or the vehicle that the player is in
	if ((vehicle INS_REV_GVAR_camPlayer) isKindOf "Man") then {INS_REV_GVAR_camRange = 5;} 
	else {	INS_REV_GVAR_camRange = (sizeOf typeOf vehicle INS_REV_GVAR_camPlayer) max 5;};
	
	// Set angle and coordinate
	INS_REV_GVAR_theta =  74;
	INS_REV_GVAR_phi   = -90;
	_camAttachCoords = call INS_REV_FNCT_get_camAttachCoords;
	_camStaticCoords = [((getPos vehicle INS_REV_GVAR_camPlayer) select 0) + (_camAttachCoords select 0),((getPos vehicle INS_REV_GVAR_camPlayer) select 1) + (_camAttachCoords select 1),((getPos vehicle INS_REV_GVAR_camPlayer) select 2) + (_camAttachCoords select 2)];
	
	// attatch camera to target
	if (INS_REV_GVAR_camPlayer isKindOf "Man" || [INS_REV_GVAR_camPlayer] call INS_REV_FNCT_is_vehicle) then {
		INS_REV_GVAR_dead_camera = "camera" camCreate _camStaticCoords;
		INS_REV_GVAR_dead_camera cameraEffect ["INTERNAL","Back"];
		INS_REV_GVAR_dead_camera CamSetTarget vehicle INS_REV_GVAR_camPlayer;
		INS_REV_GVAR_dead_camera camCommit 0;
		INS_REV_GVAR_dead_camera attachTo [vehicle INS_REV_GVAR_camPlayer, _camAttachCoords];
	} else {
		INS_REV_GVAR_dead_camera = "camera" camCreate _camStaticCoords;
		INS_REV_GVAR_dead_camera cameraEffect ["INTERNAL","Back"];
		INS_REV_GVAR_dead_camera CamSetTarget INS_REV_GVAR_camPlayer;
		INS_REV_GVAR_dead_camera camSetRelPos _camAttachCoords;
		INS_REV_GVAR_dead_camera camCommit 0;
	};
};

// Set respawn tag
// Usage(thread) : '_sctipt = unit spawn INS_REV_FNCT_dead_camera;'
INS_REV_FNCT_dead_camera = {
	private ["_unit","_camPlayer","_respawnDelay","_KH","_MH1","_to_be_Respawned_in","_doRespawn","_camAttachCoords","_vehicle","_ctrlText","_deadTime","_condition","_isTeleport"];
	disableserialization;
	
	// Set parameter to variable
	_unit 						= _this;
	
	// Set variable
	_camPlayer    				= objNull;
	INS_REV_GVAR_camMap			= false;
	INS_REV_GVAR_camPlayer   	= objNull;
	
	// Initialize dead camera
	call INS_REV_FNCT_reset_camera;
	
	showcinemaborder false;	// Disable cinema border
	
	// Initialize variable
	_camPlayer				= INS_REV_GVAR_camPlayer;	
	
	_unit = player;
	
	// Keyboard and mouse hooking
	waitUntil { !(isNull (findDisplay 46)) };
	
	_KH = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call INS_REV_FNCT_onKeyPress;"];
	_MH1 = (findDisplay 46) displayAddEventHandler ["MouseMoving", "_this call INS_REV_FNCT_onMouseMove;"];	
	
	// Loop while player is unconscious
	while {_unit getVariable "FAR_isUnconscious" == 1 && alive _unit} do {
		// If changed camera target, reset camera
		if (isNull INS_REV_GVAR_camPlayer || INS_REV_GVAR_camPlayer != _camPlayer) then {
			call INS_REV_FNCT_reset_camera;
			
			// Reset variables
			_camPlayer				= INS_REV_GVAR_camPlayer;
		};	
		
		// Moditor frequency
		sleep 0.2;	
	};
	
	// Remove display eventhander
	(findDisplay 46) displayRemoveEventHandler ["KeyDown",_KH];
	(findDisplay 46) displayRemoveEventHandler ["MouseMoving",_MH1];	
	
	// Terminate dead camera
	openMap [false,false];
	INS_REV_GVAR_dead_camera cameraEffect ["terminate","back"];
	camDestroy INS_REV_GVAR_dead_camera;
};

// KeyDown event handler
INS_REV_FNCT_onKeyPress = {
	private ["_handled","_list","_id","_size","_key","_leftTime","_respawnDelay"];
	
	scopeName "main";
	
	_key     = _this select 1;
	// _shift   = _this select 2;
	//_ctrl    = _this select 3;
	//_alt	 = _this select 4;
	_handled = false;
	_respawnDelay = call INS_REV_FNCT_getRespawnDelay;
	
	/*
	if (_key in actionKeys "tacticalView") then { hint "Tactical View is disabled in current mission."; _handled=true; };
	*/
	
	// if not alive player then exit function.
	if (!alive player) exitWith {};
	
	if (_key in (actionKeys 'showmap')) then {
		//if isNull respawnCamera exitWith {};
		INS_REV_GVAR_camMap = !INS_REV_GVAR_camMap;
		openMap [INS_REV_GVAR_camMap,INS_REV_GVAR_camMap];
		if INS_REV_GVAR_camMap then {
			mapAnimAdd [0,0.1,getPosATL INS_REV_GVAR_camPlayer];
			mapAnimCommit;
		};
	};
	
	switch _key do 
	{		
		//N key
		case 49: {
			//if (isNull respawnCamera) exitWith {};
			if (isNil "INS_REV_GVAR_camNVG") then { INS_REV_GVAR_camNVG = true; };
			camUseNVG INS_REV_GVAR_camNVG;
			INS_REV_GVAR_camNVG = !INS_REV_GVAR_camNVG;
		};		
	};
	
	_handled
};

// MouseMove event handler
INS_REV_FNCT_onMouseMove = {
	private ["_xS","_yS","_xC","_yC","_zC","_camAttachCoords"];
	
	// If not exist dead camera, exit
	if (isNull INS_REV_GVAR_dead_camera ) exitWith {};	
	_yS = (_this select 1);	
	_xS = (_this select 2);
	
	// Calculate theta
	INS_REV_GVAR_theta = INS_REV_GVAR_theta - _xS;
	if (INS_REV_GVAR_theta < 20) then {INS_REV_GVAR_theta = 20;};
	if (INS_REV_GVAR_theta > 160) then {INS_REV_GVAR_theta = 160;};
	
	// Calculate phi
	INS_REV_GVAR_phi = INS_REV_GVAR_phi - _yS;
	if (INS_REV_GVAR_phi < -270) then {INS_REV_GVAR_phi = -270;};
	if (INS_REV_GVAR_phi > 90) then {INS_REV_GVAR_phi = 90;};
	
	// Calculate cam attach coordinate
	_camAttachCoords = call INS_REV_FNCT_get_camAttachCoords;
	
	// If camPlayer is man or vehicle then attach camera.
	if (INS_REV_GVAR_camPlayer isKindOf "Man" || [INS_REV_GVAR_camPlayer] call INS_REV_FNCT_is_vehicle) then {
		INS_REV_GVAR_dead_camera attachTo [vehicle INS_REV_GVAR_camPlayer, _camAttachCoords];
	} else {
		// Or set camera
		detach INS_REV_GVAR_dead_camera;
		INS_REV_GVAR_dead_camera CamSetTarget vehicle INS_REV_GVAR_camPlayer;
		INS_REV_GVAR_dead_camera camSetRelPos _camAttachCoords;
		INS_REV_GVAR_dead_camera camCommit 0.5;
	};
};

INS_REV_FNCT_act_unload_body = {
	private ["_id","_player","_injured","_loaded_vehicle"];

	_player = player;
	_loaded_vehicle = (_this select 3) select 0;
	_injured = (_this select 3) select 1;
	_id = _this select 2;

	if (vehicle _injured == _loaded_vehicle) then {
		// Unload
		_injured action ["EJECT", vehicle _injured];
		
		// Swtich move
		if (_injured getVariable "FAR_isUnconscious" == 1) then 
		{
			[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_REV_FNCT_switchMove;
			while {animationState _injured != "AinjPpneMstpSnonWrflDnon"} do 
			{
				sleep 0.1;
				[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_REV_FNCT_switchMove;
			};
		};
		
		player groupchat format["'%1' unloaded from '%2'",name _injured, getText(configFile >> 'CfgVehicles' >> typeOf _loaded_vehicle >> 'displayname')];
	};

	// Remove unload action
	INS_REV_GVAR_del_unload = [_loaded_vehicle, _injured];
	publicVariable "INS_REV_GVAR_del_unload";
	["INS_REV_GVAR_del_unload", INS_REV_GVAR_del_unload] spawn INS_REV_FNCT_remove_unload_action;
	_loaded_vehicle removeAction _id;
};

INS_REV_FNCT_act_load_body = {

	private ["_player","_injured","_load_vehicle"];

	_player = player;
	_injured = (_this select 3) select 0;
	_load_vehicle = (_this select 3) select 1;

	if (!isNull _injured && alive _injured && _injured getVariable "FAR_isUnconscious" == 1) then {
		if (_load_vehicle emptyPositions "Cargo" > 0) then {
			// Load injured to vehicle
			detach _injured;
			[_injured, _load_vehicle] call INS_REV_FNCT_moveInCargo;
			//[_injured, "kia_hmmwv_driver"] call INS_REV_FNCT_switchMove;
			[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_REV_FNCT_switchMove;
			//[_injured, "kia_passenger_mrap_01_front"] call INS_REV_FNCT_switchMove;
			_player playMoveNow "AmovPknlMstpSrasWrflDnon";
			
			// Add unload action
			INS_REV_GVAR_add_unload = [_load_vehicle, _injured];
			publicVariable "INS_REV_GVAR_add_unload";
			["INS_REV_GVAR_add_unload", INS_REV_GVAR_add_unload] spawn INS_REV_FNCT_add_unload_action;
			
			sleep 0.5;
			
			// Check injured is loaded
			if (vehicle _injured != _injured) then {
				player groupchat format["'%1' loaded in '%2'",name _injured, getText(configFile >> 'CfgVehicles' >> typeOf _load_vehicle >> 'displayname')];
				
				FAR_isDragging = false;				
				_injured setVariable ["FAR_isDragged", 0, true];				
			} else {
				// Swtich move
				if (_injured getVariable "FAR_isUnconscious" == 1) then {
					[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_REV_FNCT_switchMove;
					while {animationState _injured != "AinjPpneMstpSnonWrflDnon"} do {
						sleep 0.1;
						[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_REV_FNCT_switchMove;
					};
					/*
					[_injured, "kia_passenger_mrap_01_front"] call INS_REV_FNCT_switchMove;
					while {animationState _injured != "kia_passenger_mrap_01_front"} do {
						sleep 0.1;
						[_injured, "kia_passenger_mrap_01_front"] call INS_REV_FNCT_switchMove;
					};
					*/
					
				};
				
				// Remove unload action
				INS_REV_GVAR_del_unload = [_load_vehicle, _injured];
				publicVariable "INS_REV_GVAR_del_unload";
				["INS_REV_GVAR_del_unload", INS_REV_GVAR_del_unload] spawn INS_REV_FNCT_remove_unload_action;
				
				player groupchat format["Failed loading",name _injured, getText(configFile >> 'CfgVehicles' >> typeOf _load_vehicle >> 'displayname')];
			};
			
		} else {
			player groupchat format["There's no cargo space in '%1'",getText(configFile >> 'CfgVehicles' >> typeOf _load_vehicle >> 'displayname')];
		};
	};

};


// Add unload action to vehicle
// Usage : '[unit, vehicle] call INS_REV_FNCT_add_unload_action;'
INS_REV_FNCT_add_unload_action = {
	private ["_vehicle", "_injured", "_id_action", "_loaded_list"];
	
	// Set variable
	_vehicle = (_this select 1) select 0;
	_injured = (_this select 1) select 1;
	
	// If vehicle is not null then add actions.
	if (!isNull _vehicle) then	{
		player reveal _vehicle;
		
		// Unload action
		_id_action = _vehicle addAction [
			format["Unload <t color='#bb3322'>%1</t>",name _injured],				/* Title */
			"call INS_REV_FNCT_act_unload_body",		/* Filename */
			[_vehicle, _injured],						/* Arguments */
			10,										/* Priority */
			false,									/* ShowWindow */
			true,									/* HideOnUse */
			"",										/* Shortcut */
			""	/* Condition */
		];
		if !(isNil {_vehicle getVariable "INS_REV_GVAR_loaded_list"}) then {
			_loaded_list = _vehicle getVariable "INS_REV_GVAR_loaded_list";
		} else {
			_loaded_list = [];
		};
		
		if (count _loaded_list > 0) then {
			_loaded_list set [count _loaded_list, [_injured, _id_action]];
		} else {
			_loaded_list = [[_injured, _id_action]];
		};
		_vehicle setVariable ["INS_REV_GVAR_loaded_list", _loaded_list, false];
	};
};

// Remove unload action
// Usage : '[vehicle, unit] call INS_REV_FNCT_remove_unload_action;'
INS_REV_FNCT_remove_unload_action = {
	private ["_vehicle","_injured", "_loaded_list","_i"];
	
	// Set variable
	_vehicle = (_this select 1) select 0;
	_injured = (_this select 1) select 1;
	
	// If vehicle is not null then remove actions
	if !(isNull _vehicle) then	{
		if !(isNil {_vehicle getVariable "INS_REV_GVAR_loaded_list"}) then {
			_loaded_list = _vehicle getVariable "INS_REV_GVAR_loaded_list";
			_i = 0;
			{
				if (_x select 0 == _injured) exitWith {
					_vehicle removeAction (_x select 1);
					_loaded_list set [_i, -1];
					_loaded_list = _loaded_list - [-1];
					if (count _loaded_list > 0) then {
						_vehicle setVariable ["INS_REV_GVAR_loaded_list", _loaded_list, false];
					} else {
						_vehicle setVariable ["INS_REV_GVAR_loaded_list", nil, false];
					};
				};
				_i = _i + 0;
			} forEach _loaded_list;
		};
	};
};


FAR_Player_Unconscious = {
	private["_unit", "_killer"];
	_unit = _this select 0;
	_killer = _this select 1;	
	
	// Death message
	//if (FAR_EnableDeathMessages && !isNil "_killer" && isPlayer _killer && _killer != _unit) then
	if (FAR_EnableDeathMessages) then
	{
		FAR_deathMessage = [_unit, _killer];
		publicVariable "FAR_deathMessage";
		["FAR_deathMessage", [_unit, _killer]] call FAR_public_EH;
	};
			
			
	if (isPlayer _unit) then
	{
		disableUserInput true;		
		titleText ["", "BLACK FADED"];
	};
	
	// Eject unit if inside vehicle
	if (vehicle _unit != _unit) then
	{
		//unAssignVehicle _unit;
		//_unit action ["eject", vehicle _unit];		
		moveOut _unit; // from vehicle restrictor script. Trying to fix the static weapon bug.
		
		sleep 2;
	};
	
	_unit setDamage 0.5;
    _unit setVelocity [0,0,0];
    _unit allowDamage false;
	_unit setCaptive true;
    _unit playMove "AinjPpneMstpSnonWrflDnon_rolltoback";

	sleep 4;
    
	if (isPlayer _unit) then
	{
		titleText ["", "BLACK IN", 1];
		disableUserInput false;
		//Fix for the keyboard sticking (player keeps moving after respawning or being revived)
		disableUserInput true;
		disableUserInput false;
	};
	
	_unit switchMove "AinjPpneMstpSnonWrflDnon";
	//_unit enableSimulation false;	
	
	[] spawn INS_REV_FNCT_respawnBlock;
	
	// Terminate existing dead camera thread
	terminate INS_REV_thread_dead_camera;
	
	// Start dead camera thread
	INS_REV_thread_dead_camera = player spawn INS_REV_FNCT_dead_camera;
	
	//_unit addEventHandler ["Fired", {deleteVehicle (_this select 6);}]; // stop the grenade throwing
	
	// Call this code only on players
	if (isPlayer _unit) then 
	{
		_bleedOut 			= time + FAR_BleedOut;
		FAR_SuicideOption 	= time + FAR_MandatoryWait;
		
		while { !isNull _unit && alive _unit && _unit getVariable "FAR_isUnconscious" == 1 && _unit getVariable "FAR_isStabilized" == 0 && (FAR_BleedOut <= 0 || time < _bleedOut) } do
		{
			if (round (FAR_SuicideOption - time) > 0 && FAR_MandatoryWait > 0) then
			{			
				//hintSilent format["Bleedout in %1 seconds\n\nRespawn button (ESC) in %2 seconds", round (_bleedOut - time),round (FAR_SuicideOption - time)];
				cutText [format["Bleedout in %1 seconds\n\nRespawn button (ESC) in %2 seconds", round (_bleedOut - time),round (FAR_SuicideOption - time)], "PLAIN", 0.1, true];				
			}
			else
			{
				//hintSilent format["Bleedout in %1 second", round (_bleedOut - time)];
				cutText [format["Bleedout in %1 second", round (_bleedOut - time)], "PLAIN", 0.1, true];
			};
			
			sleep 0.5;
		};
		
		if (_unit getVariable "FAR_isStabilized" == 1) then {
			//Unit has been stabilized. Disregard bleedout timer and umute player			
			
			while { !isNull _unit && alive _unit && _unit getVariable "FAR_isUnconscious" == 1 } do
			{
				if (round (FAR_SuicideOption - time) > 0 && FAR_MandatoryWait > 0) then
				{			
					//hintSilent format["You have been stabilized\n\nRespawn button (ESC) in %1 seconds", round (FAR_SuicideOption - time)];
					cutText [format["You have been stabilized\n\nRespawn button (ESC) in %1 seconds", round (FAR_SuicideOption - time)], "PLAIN", 0.1, true];
				}
				else
				{
					//hintSilent format["You have been stabilized"];
					cutText [format["You have been stabilized"], "PLAIN", 0.1, true];
				};				
				
				sleep 0.5;
			};
		};
		
		// Player bled out
		if (FAR_BleedOut > 0 && {time > _bleedOut} && {_unit getVariable ["FAR_isStabilized",0] == 0}) then
		{
			_unit setDamage 1;
		}
		else
		{
			// Player got revived
			_unit setVariable ["FAR_isStabilized", 0, true];			
			
			cutText ["", "PLAIN", 0.5, false];	
		
			//_unit enableSimulation true;
			_unit allowDamage true;
			_unit setDamage 0.5;
			_unit setCaptive false;			
			
			_unit playMove "amovppnemstpsraswrfldnon";
			_unit playMove "";
		};
	}
	else
	{
		// [Debugging] Bleedout for AI
		_bleedOut = time + FAR_BleedOut;
		
		while { !isNull _unit && alive _unit && _unit getVariable "FAR_isUnconscious" == 1 && _unit getVariable "FAR_isStabilized" == 0 && (FAR_BleedOut <= 0 || time < _bleedOut) } do
		{
			sleep 0.5;
		};
		
		if (_unit getVariable "FAR_isStabilized" == 1) then {			
			while { !isNull _unit && alive _unit && _unit getVariable "FAR_isUnconscious" == 1 } do
			{
				sleep 0.5;
			};
		};
		
		// AI bled out
		if (FAR_BleedOut > 0 && {time > _bleedOut} && {_unit getVariable ["FAR_isStabilized",0] == 0}) then
		{
			_unit setDamage 1;
			_unit setVariable ["FAR_isUnconscious", 0, true];
			_unit setVariable ["FAR_isDragged", 0, true];
		}
	};
};

INS_REV_FNCT_act_cancel_revive = {
	INS_REV_GVAR_cancel_revive = true;
	(_this select 0) removeAction (_this select 2);
};

FAR_HandleRevive = {
	private ["_target", "_player", "_reviveTime"];

	_target = _this select 0;
	_player = player;
	
	INS_REV_GVAR_cancel_revive = false;
	
	_isMedic = getNumber (configfile >> "CfgVehicles" >> typeOf player >> "attendant");
	
	//if the player is a medic set the reviveTime shorter than regular player.
	if (_isMedic == 0) then	
	{
		_reviveTime = time + FAR_reviveDuration + random (5);
	}
	else
	{
		_reviveTime = time + (FAR_reviveDuration * FAR_medicAdvantage) + random (5);
	};	
	
	if (alive _target) then
	{
		// Protect player
		[_player, false] call INS_REV_FNCT_allowDamage;
	
		// Attach to injured
		_player attachTo [_target, [-0.888, 0.222, 0]];
		_player setDir 90;
		_player playMoveNow "AinvPknlMstpSnonWrflDnon_medic";
		
		// Set injured move
		[_target, "AinjPpneMstpSnonWrflDnon_rolltoback"] call INS_REV_FNCT_playMoveNow;
		
		//Detach player
		if ([player] call INS_REV_FNCT_is_underwater) then 
		{
			waitUntil {animationState _player == "AinvPknlMstpSnonWrflDnon_medic" || _reviveTime < time};
		} 
		else 
		{
			sleep 0.5;
		};
		
		detach _player;
		
		// Add cancel revive action
		_cancel_revive_action = player addAction [
							"<t color=""#C90000"">" + "Cancel Revive" + "</t>",	/* Title */
							"call INS_REV_FNCT_act_cancel_revive",		/* Filename */
							[],											/* Arguments */
							10,												/* Priority */
							false,											/* ShowWindow */
							true,											/* HideOnUse */
							"",												/* Shortcut */
							""												/* Condition */
						];

		[_player, true] call INS_REV_FNCT_allowDamage; 	// Unprotect player			
						
		// Wait _reviveTakeTime until player is alive and injured is not disconnected
		while {!isNull _player && alive player && player getVariable "FAR_isUnconscious" == 0 && !isNull _target && alive _target && _reviveTime > time && !INS_REV_GVAR_cancel_revive} do 
		{
			hintSilent format["Finishing in %1 seconds", round (_reviveTime - time)];
		
			_playerMove = format ["AinvPknlMstpSnonWrflDnon_medic0", floor random 6];
			_player playMove _playerMove;
			
			hintSilent format["Finishing in %1 seconds", round (_reviveTime - time)];
			
			waitUntil {animationState _player == _playerMove || INS_REV_GVAR_cancel_revive || _reviveTime < time};
			
			hintSilent format["Finishing in %1 seconds", round (_reviveTime - time)];
			
			waitUntil {animationState _player != _playerMove || INS_REV_GVAR_cancel_revive || _reviveTime < time};
			_player playMoveNow "AinvPknlMstpSnonWrflDnon_medic";
			
			hintSilent format["Finishing in %1 seconds", round (_reviveTime - time)];
		};		
		
		//Clear Hint
		hintSilent "";
		
		if !(isNull _target) then // If injured is not disconnected
		{
			// If player and injured is alive
			if (!isNull _player && alive _player && _player getVariable "FAR_isUnconscious" == 0 && alive _target && !INS_REV_GVAR_cancel_revive) then 
			{		
				_target setVariable ["FAR_isUnconscious", 0, true];
				_target setVariable ["FAR_isDragged", 0, true];
				
				[_target, "AmovPpneMstpSrasWrflDnon"] call INS_REV_FNCT_playMoveNow;				
			};
		};
		
		// Finish player revive action
		if !(isNull _player) then 
		{
			if (alive _player && !INS_REV_GVAR_cancel_revive) then 
			{
				_player playMoveNow "AinvPknlMstpSnonWrflDnon_medicEnd";
				sleep 1;
			}
			else 
			{
				_player playMoveNow "amovpknlmstpsraswrfldnon";
			};
			_player removeAction _cancel_revive_action;
			
			if (_isMedic == 0) then {_player removeItem "FirstAidKit";};
		};

		// [Debugging] Code below is only relevant if revive script is enabled for AI
		if (!isPlayer _target && !INS_REV_GVAR_cancel_revive) then
		{
			_target enableSimulation true;
			_target allowDamage true;
			_target setDamage 0;
			_target setCaptive false;			
			
			[_target, "AmovPpneMstpSrasWrflDnon"] call INS_REV_FNCT_playMoveNow;
		};		
		
		INS_REV_GVAR_cancel_revive = nil;// Clear variable
	};
};

FAR_HandleStabilize = {
	private ["_target"];

	_target = _this select 0;

	if (alive _target) then
	{		
		[player, false] call INS_REV_FNCT_allowDamage;
		player playMove "AinvPknlMstpSlayWrflDnon_medic";
		
		sleep 6;
		[player, true] call INS_REV_FNCT_allowDamage;
		
		if (!("Medikit" in (items player)) ) then {
			player removeItem "FirstAidKit";
		};

		_target setVariable ["FAR_isStabilized", 1, true];	
	};
};

FAR_Drag_prone = {
	private ["_target", "_id"];
	_wrong_moves = ["helper_switchtocarryrfl","acinpknlmstpsraswrfldnon_amovppnemstpsraswrfldnon","acinpknlmstpsraswrfldnon_acinpercmrunsraswrfldnon","acinpercmrunsraswrfldnon","acinpercmrunsraswrfldf"];
	_prone_moves = ["amovppnemstpsraswrfldnon","amovppnemrunslowwrfldf","amovppnemsprslowwrfldfl","amovppnemsprslowwrfldfr","amovppnemrunslowwrfldb","amovppnemsprslowwrfldbl","amovppnemsprslowwrfldr","amovppnemstpsraswrfldnon_turnl","amovppnemstpsraswrfldnon_turnr","amovppnemrunslowwrfldl","amovppnemrunslowwrfldr","amovppnemsprslowwrfldb","amovppnemrunslowwrfldbl","amovppnemsprslowwrfldl","amovppnemsprslowwrfldbr"];
		
	_target = _this select 0;
	
	FAR_isDragging = true;
	INS_REV_GVAR_injured = _target;
	
	// Attach player to injured
	_target attachTo [player, [0, 1.5, 0.092]];	
	[_target, 180] call INS_REV_FNCT_setDir;	
	_target setVariable ["FAR_isDragged", 1, true];	
	
	[_target, "AinjPpneMstpSnonWrflDnon"] call INS_REV_FNCT_playMoveNow;
	
	// Rotation fix
	FAR_isDragging_EH = _target;
	publicVariable "FAR_isDragging_EH";
	
	INS_REV_FNCT_drag_prone_keydown = {
	if ((_this select 1) in (actionKeys "moveForward" + actionKeys "moveFastForward")) exitWith {true};
		false
	};

	// Add KeyDown event handler
	INS_REV_GVAR_keydown_event = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call INS_REV_FNCT_drag_prone_keydown"];
	
	// Add release action and save its id so it can be removed
	_id = player addAction ["<t color=""#0000FF"">" + "Release" + "</t>", "call FAR_handleAction", ["action_release"], 10, true, true, "", "true"];
	
	//Add Load option
	if (isNil "FNC_check_load_vehicle") then {
		FNC_check_load_vehicle = {
			private ["_objs","_vcl","_result"];
			_result = false;
			_objs = nearestObjects [player, ["Car","Tank","Helicopter","Plane","Boat"], 5];
			INS_REV_GVAR_load_vehicle = nil;
			if (count _objs > 0) then {
				INS_REV_GVAR_load_vehicle = _objs select 0;
				if (alive INS_REV_GVAR_load_vehicle) then {
					_result = true;
				};
			};
			_result
		};
	};
	
	STR_INS_REV_action_load_body		= "Load <t color='#bb3322'>%1</t> to <t color='#22bb22'>%2</t>";
	
	_trigger = createTrigger["EmptyDetector" ,getPos player];
	_trigger setTriggerArea [0, 0, 0, true];
	_trigger setTriggerActivation ["NONE", "PRESENT", true];
	_trigger setTriggerStatements[
		"call FNC_check_load_vehicle",
		"INS_REV_GVAR_loadActionID = player addAction [format[STR_INS_REV_action_load_body,name INS_REV_GVAR_injured,getText(configFile >> 'CfgVehicles' >> typeOf INS_REV_GVAR_load_vehicle >> 'displayname')], 'call INS_REV_FNCT_act_load_body',[INS_REV_GVAR_injured,INS_REV_GVAR_load_vehicle],10,false];",
		"player removeAction INS_REV_GVAR_loadActionID; INS_REV_GVAR_loadActionID = nil;"
	];	
	
	// Wait until release action is used or dragger goes unconscious or draggee wakes up or dragger stands up or crouches up.
	waitUntil 
	{ 
		!alive player 									|| 
		player getVariable "FAR_isUnconscious" == 1 	|| 
		!alive _target 									|| 
		_target getVariable "FAR_isUnconscious" == 0 	|| 
		!FAR_isDragging 									|| 
		_target getVariable "FAR_isDragged" == 0 		||
		!(animationState player in _prone_moves)		
	};

	// Handle release action
	FAR_isDragging = false;
	
	if (!isNull _target && alive _target) then
	{
		_target switchMove "AinjPpneMstpSnonWrflDnon";
		_target setVariable ["FAR_isDragged", 0, true];
		detach _target;
	};
	
	player removeAction _id;
	
	// Finish dragging
	if !(isNull player) then 
	{		
		if (alive player && player getVariable "FAR_isUnconscious" == 0) then 
		{
			// If player stand up, terminate move
			if ((animationState player) in _wrong_moves) then 
			{
				while {(animationState player) in _wrong_moves} do 
				{
					[player, "amovppnemstpsraswrfldnon"] call INS_REV_FNCT_switchMove;
					sleep 0.5;
				};
			};			
		};
	};
	
	//Remove loading stuff.
	if (!isNil "INS_REV_GVAR_loadActionID") then {
		player removeAction INS_REV_GVAR_loadActionID;
		INS_REV_GVAR_loadActionID = nil;
	};
	
	// Remove trigger
	if (!isNil "_trigger" && {!isNull _trigger}) then {
		deleteVehicle _trigger;
		_trigger = nil;
	};	
	
	//Remove the key event handler
	if (!isNil {INS_REV_GVAR_keydown_event}) then 
	{
		(findDisplay 46) displayRemoveEventHandler ["KeyDown", INS_REV_GVAR_keydown_event];
	};
	
	INS_REV_GVAR_injured = nil;
	INS_REV_GVAR_keydown_event = nil;
};

INS_Carry = {
	private ["_injured", "_player", "_release_body_action","_playerMove","_wrong_moves","_dir","_trigger"];
	
	// Remove Carry action
	(_this select 0) removeAction (_this select 2);
	
	_injured = (_this select 3) select 0;
	_release_body_action = (_this select 3) select 1;
	_trigger = (_this select 3) select 2;
	_player = player;
	_wrong_moves = ["helper_switchtocarryrfl","acinpknlmstpsraswrfldnon_amovppnemstpsraswrfldnon","acinpknlmstpsraswrfldnon_acinpercmrunsraswrfldnon","acinpercmrunsraswrfldnon","acinpercmrunsraswrfldf"];
	
	FAR_isDragging = true;
	INS_REV_GVAR_is_carring = true;
	INS_REV_GVAR_injured = _injured;

	[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_REV_FNCT_switchMove;
	waitUntil {animationState _injured == "AinjPpneMstpSnonWrflDnon"};
	_injured switchMove "AinjPfalMstpSnonWnonDnon_carried_Up";
	_injured attachto [player,[0.05, 1.1, 0]];
	detach _injured;
	_injured setPos [getPos _injured select 0,getPos _injured select 1,0.01];
	[_injured, (getDir _player + 180)] call INS_REV_FNCT_setDir;
	
	hintSilent "Hold Still until the injured is on your back";
	
	[_player, "AcinPknlMstpSrasWrflDnon_AcinPercMrunSrasWrflDnon"] call INS_REV_FNCT_playMoveNow;
	
	hintSilent "Ok. You can move now. Get him out of here.";
	
	while {animationState _injured == "ainjpfalmstpsnonwnondnon_carried_up" && alive _player && FAR_isDragging && vehicle _player == _player} do {sleep 0.01};
	_player playMove "manPosCarrying";
	sleep 0.1;

	// Create dir funciton
	if (isNil "FNC_dir_func") then {
		FNC_dir_func = {
			private ["_veh","_unit","_v","_p","_c","_dir"];
			_veh = _this select 0;
			_unit = _this select 1;

			_v = getDir _veh;
			_p = getDir _unit;
			_c = 360;

			_dir = _c-((_c-_p)-(_c-_v));

			_dir
		};
	};

	// Attach injured to player
	[_injured, "AinjPfalMstpSnonWnonDnon_carried_still"] call INS_REV_FNCT_switchMove;
	sleep 0.1;
	_injured attachto [_player,[0.1, 0.1, 0]];
	_dir = [_player, _injured] call FNC_dir_func;
	[_injured, _dir + 180] call INS_REV_FNCT_setDir;
	
	
	if (isNil "FNC_is_finished_carring") then //define the function to check if carrying is done
	{
		FNC_is_finished_carring = 
		{
			private ["_result","_player","_injured"];
			
			_player = _this select 0;
			_injured = _this select 1;
			_carring_moves = ["acinpercmstpsraswrfldnon","acinpercmrunsraswrfldf","acinpercmrunsraswrfldfr","acinpercmrunsraswrfldfl","acinpercmrunsraswrfldl","acinpercmrunsraswrfldr","acinpercmrunsraswrfldb","acinpercmrunsraswrfldbr","acinpercmrunsraswrfldbl"];
			_result = true;
			
			if (FAR_isDragging) then 
			{
				if (!isNull _player && alive _player && !isNull _injured && alive _injured && isPlayer _injured && vehicle _player == _player && _injured getVariable "FAR_isUnconscious" == 1) then 
				{
					if (animationState _player in _carring_moves) then 
					{
						_result = false;
					};
				};
			};			
			_result
		};
	};
	
	waitUntil {animationState _player == "acinpercmstpsraswrfldnon" || !alive _player || player getVariable "FAR_isUnconscious" == 1 || !FAR_isDragging || vehicle _player != _player};
	
	// Wait until dragging is finished
	while {!([_player, _injured] call FNC_is_finished_carring)} do 
	{
		sleep 0.5;
	};
	
	// If injured is not disconnected
	if (!isNull _injured) then 
	{
		// Detach injured
		detach _injured;
		
		[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_REV_FNCT_switchMove;		
		
		_injured setVariable ["FAR_isDragged", 0, true];
	};
	
	// Finish carring
	if !(isNull _player) then 
	{
		[_player, "AmovPknlMstpSrasWrflDnon"] call INS_REV_FNCT_switchMove;
	};
	
	_player removeAction _release_body_action;
	
	//Remove loading stuff.
	if (!isNil "INS_REV_GVAR_loadActionID") then {
		_player removeAction INS_REV_GVAR_loadActionID;
		INS_REV_GVAR_loadActionID = nil;
	};
	
	// Remove trigger
	if (!isNil "_trigger" && {!isNull _trigger}) then {
		deleteVehicle _trigger;
		_trigger = nil;
	};
	
	INS_REV_GVAR_is_carring = false;
	FAR_isDragging = false;
	INS_REV_GVAR_injured = nil;
};

FAR_Drag = {
	private ["_target", "_id"];	
	
	INS_REV_GVAR_is_carring = false;
	
	
	_target = _this select 0;
	INS_REV_GVAR_injured = _target;
	
	
	_prone_moves = ["amovppnemstpsraswrfldnon","amovppnemrunslowwrfldf","amovppnemsprslowwrfldfl","amovppnemsprslowwrfldfr","amovppnemrunslowwrfldb","amovppnemsprslowwrfldbl","amovppnemsprslowwrfldr","amovppnemstpsraswrfldnon_turnl","amovppnemstpsraswrfldnon_turnr","amovppnemrunslowwrfldl","amovppnemrunslowwrfldr","amovppnemsprslowwrfldb","amovppnemrunslowwrfldbl","amovppnemsprslowwrfldl","amovppnemsprslowwrfldbr"];
	_wrong_moves = ["helper_switchtocarryrfl","acinpknlmstpsraswrfldnon_amovppnemstpsraswrfldnon","acinpknlmstpsraswrfldnon_acinpercmrunsraswrfldnon","acinpercmrunsraswrfldnon","acinpercmrunsraswrfldf"];
	// If while prone call something else and exit
	if (animationState player in _prone_moves) exitWith 
	{
		_this spawn FAR_Drag_prone;
	};
	
	FAR_isDragging = true;
	
	_target attachTo [player, [0, 1.1, 0.092]];
	_target setDir 180;
	_target setVariable ["FAR_isDragged", 1, true];
	
	player playMoveNow "AcinPknlMstpSrasWrflDnon";
	
	// Rotation fix
	FAR_isDragging_EH = _target;
	publicVariable "FAR_isDragging_EH";
	
	// Add release action and save its id so it can be removed
	_id = player addAction ["<t color=""#0000FF"">" + "Release" + "</t>", "call FAR_handleAction", ["action_release"], 10, true, true, "", "true"];
	
	hint "Press 'C' if you can't move.";	
	
	//Add Load option
	if (isNil "FNC_check_load_vehicle") then {
		FNC_check_load_vehicle = {
			private ["_objs","_vcl","_result"];
			_result = false;
			_objs = nearestObjects [player, ["Car","Tank","Helicopter","Plane","Boat"], 5];
			INS_REV_GVAR_load_vehicle = nil;
			if (count _objs > 0) then {
				INS_REV_GVAR_load_vehicle = _objs select 0;
				if (alive INS_REV_GVAR_load_vehicle) then {
					_result = true;
				};
			};
			_result
		};
	};	
	
	STR_INS_REV_action_load_body		= "Load <t color='#bb3322'>%1</t> to <t color='#22bb22'>%2</t>";
	
	_trigger = createTrigger["EmptyDetector" ,getPos player];
	_trigger setTriggerArea [0, 0, 0, true];
	_trigger setTriggerActivation ["NONE", "PRESENT", true];
	_trigger setTriggerStatements[
		"call FNC_check_load_vehicle",
		"INS_REV_GVAR_loadActionID = player addAction [format[STR_INS_REV_action_load_body,name INS_REV_GVAR_injured,getText(configFile >> 'CfgVehicles' >> typeOf INS_REV_GVAR_load_vehicle >> 'displayname')], 'call INS_REV_FNCT_act_load_body',[INS_REV_GVAR_injured,INS_REV_GVAR_load_vehicle],10,false];",
		"player removeAction INS_REV_GVAR_loadActionID; INS_REV_GVAR_loadActionID = nil;"
	];
	
	_carry_body_action = player addAction ["<t color=""#0000FF"">" + "Carry" + "</t>", "call INS_Carry", [_target, _id, _trigger], 10, false, true, "", ""];
	
	// Wait until release action or carry action is used
	waitUntil 
	{ 
		!alive player || player getVariable "FAR_isUnconscious" == 1 || !alive _target || _target getVariable "FAR_isUnconscious" == 0 || !FAR_isDragging || _target getVariable "FAR_isDragged" == 0 || INS_REV_GVAR_is_carring
	};	
	
	//If the body is being carried get out of the function
	if (!isNil "INS_REV_GVAR_is_carring" && {INS_REV_GVAR_is_carring}) exitWith {};
	
	// Handle release action
	FAR_isDragging = false;
	
	if (!isNull _target && alive _target) then
	{
		_target switchMove "AinjPpneMstpSnonWrflDnon";
		_target setVariable ["FAR_isDragged", 0, true];
		detach _target;
	};
	
	player removeAction _id;
	player removeAction _carry_body_action;
	
	// Finish dragging
	if !(isNull player) then {
		// If player is dead, terminate move
		if (!alive player || player getVariable "FAR_isUnconscious" == 0) then 
		{
			[player, "AmovPknlMstpSrasWrflDnon"] call INS_REV_FNCT_switchMove;
		} 
		else 
		{
			// If player stand up, terminate move
			if ((animationState player) in _wrong_moves) then 
			{
				while {(animationState player) in _wrong_moves} do 
				{
					[player, "AmovPknlMstpSrasWrflDnon"] call INS_REV_FNCT_switchMove;
					sleep 0.5;
				};
			} 
			else 
			{
				player playMoveNow "AmovPknlMstpSrasWrflDnon";
			};
		};
	};	
	
	//Remove loading stuff.
	if (!isNil "INS_REV_GVAR_loadActionID") then {
		player removeAction INS_REV_GVAR_loadActionID;
		INS_REV_GVAR_loadActionID = nil;
	};
	
	// Remove trigger
	if (!isNil "_trigger" && {!isNull _trigger}) then {
		deleteVehicle _trigger;
		_trigger = nil;
	};
	
	INS_REV_GVAR_injured = nil;	
};

FAR_Release = {
	FAR_isDragging = false;
};

FAR_public_EH = {
	if(count _this < 2) exitWith {};
	
	_EH  = _this select 0;
	_target = _this select 1;

	// FAR_isDragging
	if (_EH == "FAR_isDragging_EH") then
	{
		_target setDir 180;
	};
	
	// FAR_deathMessage
	if (_EH == "FAR_deathMessage") then
	{
		_killed = _target select 0;
		_killer = _target select 1;

		if (isPlayer _killed && isPlayer _killer) then
		{
			systemChat format["%1 was injured by %2", name _killed, name _killer];
		}
		else
		{
			systemChat format["%1 is down.", name _killed];
		};
	};
};

FAR_Check_Revive = {
	private ["_target", "_isTargetUnconscious", "_isDragged"];

	_return = false;
	
	// Unit that will excute the action
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";
	_isMedic = getNumber (configfile >> "CfgVehicles" >> typeOf player >> "attendant");
	_target = cursorTarget;

	// Make sure player is alive and target is an injured unit
	if( !alive player || _isPlayerUnconscious == 1 || FAR_isDragging || isNil "_target" || !alive _target || (!isPlayer _target && !FAR_Debugging) || (_target distance player) > 2 ) exitWith
	{
		_return
	};

	_isTargetUnconscious = _target getVariable "FAR_isUnconscious";
	_isDragged = _target getVariable "FAR_isDragged"; 
	
	// Make sure target is unconscious and player is a medic 
	if (_isTargetUnconscious == 1 && _isDragged == 0 && (_isMedic == 1 || FAR_ReviveMode > 0) ) then
	{
		_return = true;

		// [ReviveMode] Check if player has a Medikit
		if ( FAR_ReviveMode == 1 && _isMedic == 0 && !("FirstAidKit" in (items player)) ) then
		{
			_return = false;
		}
		else
		{
			if ( FAR_ReviveMode == 2 && !("Medikit" in (items player)) ) then
			{
				_return = false;
			};
		};
	}
	else 
	{
		//if only medics can revive, check if there is one of the medical trucks nearby and the player is not a medic and player has a FAK.
		if (_isTargetUnconscious == 1 && _isDragged == 0 && _isMedic == 0 && FAR_ReviveMode == 0) then
		{
			_hemtt = [];
			_hemtt = (position player) nearEntities [FAR_medical_trucks, 7];
			
			if ((count _hemtt) > 0 && ("FirstAidKit" in (items player))) then 
			{
				_return = true;
			} 
			else 
			{
				_return = false;
			};
		};
	};
	
	_return
};

FAR_Check_Stabilize = {
	private ["_target", "_isTargetUnconscious", "_isDragged"];

	_return = false;
	
	// Unit that will excute the action
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";
	_target = cursorTarget;
	

	// Make sure player is alive and target is an injured unit
	if( !alive player || _isPlayerUnconscious == 1 || FAR_isDragging || isNil "_target" || !alive _target || (!isPlayer _target && !FAR_Debugging) || (_target distance player) > 2 ) exitWith
	{
		_return
	};

	_isTargetUnconscious = _target getVariable "FAR_isUnconscious";
	_isTargetStabilized = _target getVariable "FAR_isStabilized";
	_isDragged = _target getVariable "FAR_isDragged"; 
	
	// Make sure target is unconscious and hasn't been stabilized yet, and player has a FAK/Medikit 
	if (_isTargetUnconscious == 1 && _isTargetStabilized == 0 && _isDragged == 0 && ( ("FirstAidKit" in (items player)) || ("Medikit" in (items player)) ) ) then
	{
		_return = true;
	};
	
	_return
};

FAR_Check_Suicide = {
	_return = false;
	_isPlayerUnconscious = player getVariable ["FAR_isUnconscious",0];
	
	if (alive player && _isPlayerUnconscious == 1 && time > FAR_SuicideOption && FAR_MandatoryWait > 0) then
	{
		_return = true;
	};
	
	_return
};

FAR_Check_Dragging = {
	private ["_target", "_isPlayerUnconscious", "_isDragged"];
	
	_return = false;
	_target = cursorTarget;
	_isPlayerUnconscious = player getVariable "FAR_isUnconscious";

	if( !alive player || _isPlayerUnconscious == 1 || FAR_isDragging || isNil "_target" || !alive _target || (!isPlayer _target && !FAR_Debugging) || (_target distance player) > 2 ) exitWith
	{
		_return;
	};
	
	// Target of the action
	_isTargetUnconscious = _target getVariable "FAR_isUnconscious";
	_isDragged = _target getVariable "FAR_isDragged"; 
	
	if(_isTargetUnconscious == 1 && _isDragged == 0) then
	{
		_return = true;
	};
		
	_return
};

FAR_Player_Init = {
	// Cache player's side
	FAR_PlayerSide = side player;

	// Clear event handler before adding it
	player removeAllEventHandlers "HandleDamage";
	//player removeAllEventHandlers "Fired";

	player addEventHandler ["HandleDamage", FAR_HandleDamage_EH];
	player addEventHandler 
	[
		"Killed",
		{
			// Remove dead body of player (for missions with respawn enabled)
			_body = _this select 0;
			
			[player, [missionnamespace, "VirtualInventory"]] call BIS_fnc_saveInventory;
			
			[_body] spawn 
			{			
				waitUntil { alive player };
				_body = _this select 0;
				deleteVehicle _body;
			}
		}
	];

	[player, [missionnamespace, "VirtualInventory"]] call BIS_fnc_loadInventory;
	
	player setVariable ["FAR_isUnconscious", 0, true];
	player setVariable ["FAR_isStabilized", 0, true];
	player setVariable ["FAR_isDragged", 0, true];
	player setCaptive false;
	
	FAR_SuicideOption = time;
	FAR_isDragging = false;	
	
	INS_REV_thread_dead_camera = [] spawn {};		// On killed dead camera thread
	
	[] spawn FAR_Player_Actions;
};

////////////////////////////////////////////////
// Main function which controls the whole thing.
////////////////////////////////////////////////
[] spawn {
    waitUntil { !isNull player };

	// Public event handlers
	"FAR_isDragging_EH" addPublicVariableEventHandler FAR_public_EH;
	"FAR_deathMessage" addPublicVariableEventHandler FAR_public_EH;
	
	"INS_REV_GVAR_add_unload" addPublicVariableEventHandler INS_REV_FNCT_add_unload_action;
	"INS_REV_GVAR_del_unload" addPublicVariableEventHandler INS_REV_FNCT_remove_unload_action;	
	
	[] spawn FAR_Player_Init;

	// Event Handlers
	player addEventHandler 
	[
		"Respawn", 
		{			
			[] spawn FAR_Player_Init;
		}
	];
};

////////////////////////////////////////////////
// [Debugging] Add revive to playable AI units
////////////////////////////////////////////////
if (!FAR_Debugging || isMultiplayer) exitWith {};

{
	if (!isPlayer _x) then 
	{
		_x addEventHandler ["HandleDamage", FAR_HandleDamage_EH];
		_x setVariable ["FAR_isUnconscious", 0, true];
		_x setVariable ["FAR_isStabilized", 0, true];
		_x setVariable ["FAR_isDragged", 0, true];
	};
} forEach playableUnits;