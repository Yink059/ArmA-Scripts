//resetFlag.sqf
_runBefore = _this select 0;
//player sideChat "resetFlag.sqf";
flagOwnedBySide = "none";
publicVariable "flagOwnedBySide";

if (flagNumberOfStartingPositions == 1) then
{
	if (_runBefore == 0) then
	{
		_possibleFlagLocations = ["mrk_Start1","mrk_Start2","mrk_Start3"];
		_flagIndex = floor random (count _possibleFlagLocations);
		flagLocation = _possibleFlagLocations select _flagIndex;
		publicVariable "flagLocation";
	};
};
if (flagNumberOfStartingPositions == 2) then
{
	_possibleFlagLocations = ["mrk_Start1","mrk_Start2"];
	_flagIndex = floor random (count _possibleFlagLocations);
	flagLocation = _possibleFlagLocations select _flagIndex;
	publicVariable "flagLocation";
};
if (flagNumberOfStartingPositions == 3) then
{
	_possibleFlagLocations = ["mrk_Start1","mrk_Start2","mrk_Start3"];
	_flagIndex = floor random (count _possibleFlagLocations);
	flagLocation = _possibleFlagLocations select _flagIndex;
	publicVariable "flagLocation";
};

flagTarget = "Flag_FD_Green_F" createVehicle (getMarkerPos flagLocation);
publicVariable "flagTarget";
["The flag has been placed at a new location.","hint",true,false] call BIS_fnc_MP;

//if (_runBefore < 1) then
//{
	//create AI guard
	aafGroup move [((getPos flagTarget select 0) + ((floor random 40) - 20)),((getPos flagTarget select 1) + ((floor random 40) - 20)), 0];
//};