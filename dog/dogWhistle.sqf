if ( isDog == 'false' ) then {
	hint "Jessie, here girl!";

	"Alsatian_Sandblack_F" createUnit [[(getpos sharpePlayer) select 0,((getpos sharpePlayer) select 1) - 1, 0], sharpePlayer];

	dog1 = nearestobject [getpos sharpePlayer,"animal"];

	publicvariable "dog1";

	// dog1 allowDamage false;

	_mygroup = createGroup west;

	[dog1] join _mygroup;
	
	dog1 addEventHandler ["Killed", {_this execVM "dogRevive.sqf"}];
	
	isDog = 'true';
};