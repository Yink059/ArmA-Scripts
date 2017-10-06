if ((isServer)||(isDedicated)) then
{
	missionType = "pvp";
	publicVariable "missionType";
	unassignedWest = creategroup west;
	"B_officer_F" createunit [[0,0,0],unassignedWest,"voidB = this;", 1.0, "colonel"];
	voidB allowdamage false;
	voidB setname "<Void West>";
	unassignedWest setGroupId ["UnassignedWest"];
	publicvariable "unassignedWest";
	{
		if ((side _x)==west) then
		{
			[_x] joinSilent unassignedWest;
		};
	} foreach playableUnits;
	
	unassignedEast = creategroup east;
	"O_officer_F" createunit [[0,0,0],unassignedEast,"voidE = this;", 1.0, "colonel"];
	voidE allowdamage false;
	voidE setname "<Void East>";
	unassignedEast setGroupId ["UnassignedEast"];
	publicvariable "unassignedEast";
	{	
		if ((side _x)==east)  then
		{
			[_x] joinSilent unassignedEast;
		};
	} foreach playableUnits;
	
	unassignedInd = creategroup resistance;
	"I_officer_F" createunit [[0,0,0],unassignedInd,"voidI = this;", 1.0, "colonel"];
	voidI allowdamage false;
	voidI setname "<Void Inde>";
	unassignedInd setGroupId ["UnassignedInd"];
	publicvariable "unassignedInd";
	{
		if ((side _x)==resistance) then
		{
			[_x] joinSilent unassignedInd;
		};
	} foreach playableUnits;
	
	unassignedCiv = creategroup civilian;
	"C_man_shorts_4_F_afro" createunit [[0,0,0],unassignedCiv,"voidC = this;", 1.0, "colonel"];
		voidC allowdamage false;
		voidC setname "<Void Civ>";
	unassignedCiv setGroupId ["UnassignedCiv"];
		publicvariable "unassignedCiv";
		{
			if ((side _x)==civilian)  then
		{
			[_x] joinSilent unassignedCiv;
		};
	} foreach playableUnits;
	
	publicVariable "unassignedWest";
	publicVariable "unassignedEast";
	publicVariable "unassignedInd";
	publicVariable "unassignedCiv";
	execVM "YGM\Functions\functionsGM.sqf";
};
waituntil {!isNull player};
missionType = "pvp";
publicVariable "missionType";
_current_sls = grpNull;
_group = objNull;
sleep 1;

_groups = [unassignedWest, unassignedEast, unassignedInd, unassignedCiv];
_sls	= [voidB, voidE, voidI,  voidC];
_side	= side player;

_current_sls = grpNull;
_group = objNull;

switch (_side) do
{
	case west:
	{
		_group = _groups select 0;
		_current_sls = _sls select 0;		
		_current_sls setname "<Void West>";
		_group setGroupId ["UnassignedWest"];
	};
	case east:
	{
		_group = _groups select 1;
		_current_sls = _sls select 1;
		_current_sls setname "<Void East>";
		_group setGroupId ["UnassignedEast"];
	};
	case resistance:
	{
		_group = _groups select 2;
		_current_sls = _sls select 2;
		_current_sls setname "<Void Inde>";
		_group setGroupId ["UnassignedInd"];
	};
	case civilian:
	{
		_group = _groups select 3;
		_current_sls = _sls select 3;
		_current_sls setname "<Void Civ>";
		_group setGroupId ["UnassignedCiv"];
	};
};
	[player] joinSilent _group;
	
player setVariable ["counter",0];
script_handler = [] execVM "YGM\Functions\functionsGM.sqf";
waitUntil { scriptDone script_handler };
(findDisplay 46) displayAddEventHandler ["keyDown", fnc_yink_activate];
player setVariable ["actions", [ ]];
player setVariable ["actions", [ ]];

execVM "YGM\Functions\functionsGM.sqf";
//hint "YinkGM Functions loaded";



