/*
dog functions

pass in the calling unit

made by: 
Yink, Sharpe
*/
hint "hi";
_unit = _this select 0;
_side = side _unit;
_dog = _unit getvariable "dog";

_dogRevive = 
	{
	_unit = _this select 0;
	_side = side _unit;
	_dog = _unit getvariable "dog";
		sleep 5;
		
		_side = side _unit;
		
		_tempPos = getpos _dog;

		deleteVehicle _dog;
	
		_group1 = createGroup _side;
	
		"Alsatian_Sandblack_F" createUnit [_tempPos,_group1,"_unit setvariable ['dog',format['%1',this]]", 1.0, private];
	
		sleep 0.5
	
		_dog = _unit getvariable "dog";
	
		_dog addEventHandler ["Killed", ""];
		_unit setvariable ["step","go"];
	
	};
	
_dogWhistle =
	{
		hint "Jessie, here girl!";
		
		_tempPos = [(getpos _unit) select 0,((getpos _unit) select 1) + 1,0];
		
		_group1 = createGroup west;
		
		"Alsatian_Sandblack_F" createUnit [_tempPos,_group1,"_unit setvariable ['dog',format['%1',this]]", 1.0, private];

		_dog = nearestobject [getpos _unit,"animal"];

		// _dog allowDamage false;

		_dog addEventHandler ["Killed", {_this execVM "dogRevive.sqf"}];
	
		_unit setvariable ["order","idle"];
		_unit setvariable ["step","go"];
	};

_dogFollow =
	{
		hint "Jessie, follow!";

		_unit setvariable ["follow",'true'];

		while {(_unit getvariable "follow" == 'true'} do 
		{
			sleep 0.5;
			if ((_dog distance _unit) < 4) then 
				{
				_dog domove getpos _dog;
				} 
				else 
					{
					_dog domove getpos _unit;	
					};
			sleep 1;
		_unit setvariable ["order","active"];
		_unit setvariable ["step","go"];
		};

	};

_dogSeek = 
	{
		hint "Jessie, seek!";

		_dog = _unit getvariable "dog";
		_side = side _unit;
			
		_radius = 1000;
	
		_nearestunits = nearestObjects [_dog,["Man"],_radius];
	
		_nearestunitofside = [];

		if(_side countSide _nearestunits > 0) then
		{
			{
				_unit = _x;
				if (side _unit == _side) then 
					{
						_nearestunitofside = _nearestunitofside + [_unit]
					};
			} foreach _nearestunits;
		};

		_dog domove getpos (_nearestunitofside select 0);
		_unit setvariable ["order","active"];
		_unit setvariable ["step","go"];
	};
	
_dogHeel =
	{
		hint "Jessie, Heal!";

		_dog = _unit getvariable "dog";

		_dog domove [(getpos _unit) select 0,((getpos _unit) select 1) - 1, 0];
		_unit setvariable ["order","active"];
		_unit setvariable ["step","go"];
	};

_dogHide =
	{
	
		_dog = _unit getvariable "dog";
		
		hint "Jessie, sleep!";

		deleteVehicle _dog;
		_unit setvariable ["order","nil"];
		_unit setvariable ["step","go"];
	};

_dogStop =
	{
		_dog = _unit getVariable "dog";
		hint "Jessie, wait!";

		_dog domove getpos _dog;
		_unit setvariable ["order","idle"];
		_unit setvariable ["step","go"];
	};
	
_actions = 
	{

	_dog = _unit getvariable "dog":
	
	while {(_unit getvariable "action")=='true'} do
		{
			_actions = _unit getvariable "actions";
			{
			_unit removeaction _x
			} foreach _actions;
		
		_actions = [ ];
	
		if ((_unit getvariable "order") == "nil") then
			{
				_whistle = _unit addAction ["Whistle", _dogWhistle];
				_unit setvariable ["order","whistle"];
				_unit setvariable ["step","wait"];
				
				_unit setvariable ["actions",[_whistle]];
			};
		
		if ((_unit getvariable "order") == "idle") then
			{
				_follow = _unit addAction ["Follow", _dogFollow];
				_find = _unit addAction ["Find", _dogSeek];
				_rest = _unit addAction ["Rest", _dogHide];
				_heel = _unit addAction ["Heel", _dogHeel];
				_unit setvariable ["step","wait"];
				
				_unit setvariable ["actions",[_follow,_find,_rest,_heel]];
				
			};
	
		if ((_unit getvariable "order") == "active") then
			{
				_stop = _unit addAction ["Stop", _dogStop];
				_unit setvariable ["step","wait"];
				_unit setvariable ["actions",[_stop]];
			};
		
		waituntil {((_unit getvariable "step") == "go")};
	
		};
	
	};




	
	
	
	