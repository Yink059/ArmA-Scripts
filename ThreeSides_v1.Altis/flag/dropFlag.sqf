_oldCarrier = flagCarrier;
player allowDamage false;
detach flagTarget;
flagTarget setPos [(getPos flagTarget select 0), (getPos flagTarget select 1), 0];
flagCarrier = noOne;
publicVariable "flagCarrier";
if (side _oldCarrier == west) then 
{
	_oldCarrier = "Blufor";
} else {
	_oldCarrier = "Opfor";
};
_dropMssg = format ["%1 has dropped the flag!", _oldCarrier];
[_dropMssg,"hint",true,false] call BIS_fnc_MP;
sleep .5;
player allowDamage true;