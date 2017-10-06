sleep 5;

_tempPos = getpos dog1;

deleteVehicle dog1;

"Alsatian_Sandblack_F" createUnit [_tempPos, sharpePlayer];

dog1 = nearestobject [_tempPos,"animal"];

publicvariable "dog1";
	
_mygroup = createGroup west;

[dog1] join _mygroup;

dog1 addEventHandler ["Killed", {_this execVM "dogRevive.sqf"}];