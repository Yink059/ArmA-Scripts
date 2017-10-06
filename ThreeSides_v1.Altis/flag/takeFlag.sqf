flagCarrier = _this select 1;
publicVariable "flagCarrier";
_sideFlagCarrier = "";

if (side flagCarrier == west) then
{
	flagOwnedBySide = "west";
	publicVariable "flagOwnedBySide";
};
if (side flagCarrier == east) then
{
	flagOwnedBySide = "east";
	publicVariable "flagOwnedBySide";
};

flagTarget attachTo [player, [0, 0.15, -0.8], "Pelvis"]; 
if (side flagCarrier == west) then 
{
	_sideFlagCarrier = "Blufor";
} else {
	_sideFlagCarrier = "Opfor";
};
_pickupMssg = format ["%1 has picked up the flag!", _sideFlagCarrier];
[_pickupMssg,"hint",true,false] call BIS_fnc_MP;

_run = true;
while {_run} do
{
	if(flagCarrier getVariable "FAR_isUnconscious" == 1) then
	{
		nul = []execVM "flag\dropFlag.sqf";
	};
	if !(flagCarrier == player) then
	{
		_run = false;
	};
	sleep .4;
};
