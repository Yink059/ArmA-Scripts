_unassigned = grpNull;
_side = side player;
sleep 1;


fnc_yink_refresh =
{
	if (dialog) then
	{
		//executing unit: [_unit]
		// refresh1 = [_unit] spawn fnc_yinkrefresh1;
		_unit = player;
		_side = side _unit;
		_group2 = group _unit;
		lbSetCurSel [1501,0];
		_index1 = _unit getVariable "memberIndex";
		_value1 = lbText [1501,_index1];
		_memberTarget = lbData [1501,_index1];
		_target = (missionNameSpace getVariable _memberTarget) select 0;
		_admin = serverCommandAvailable "#kick";
			
		lbClear 1500;
		lbClear 1501;
		{
			if ((side (leader _x))==_side) then
			{//Refresh lb_left
				_index1 = lbAdd [1500,str _x];
				lbSetData [1500,_index1, str (leader _x)];
				missionNameSpace setVariable [(str _x), _x];
				lbSetCurSel [1500, _index1];
			};
		} forEach allGroups;
	};
};

fnc_yink_groupInfo =
{
	_player = _this select 0;
	_index1 = lbCurSel 1500;
	_leader = player;
	_value1 = lbText [1500,_index1];
	_leader1 = lbData [1500,_index1];
	ctrlSetText [1003, _value1];
	ctrlSetText [1005,name (leader (missionNameSpace getVariable (_value1)))];
	lbClear 1501;
	_admin = serverCommandAvailable "#kick";
	{
		_index2 = lbAdd [1501,name _x];
		lbSetData [1501,_index2,str _x];
		missionNameSpace setVariable [(str _x),[_x]];
	} foreach units (group (leader (missionNameSpace getVariable (_value1))));


	if (((_player==(leader _player))||(_admin))&&((_value1)==(str (group _player)))) then
	{
		ctrlSetText [1603,"Promote"];
	};
	if (((_player==(leader _player))||(_admin))&&((_value1)!=(str (group _player)))) then
	{
		ctrlSetText [1603,"Invite"];
	};

};

fnc_yink_groupJoin =
{
	_unit = _this select 0;
	_side = side _unit;
	_group2 = group _unit;
	_index1 = lbCurSel 1500;
	_value1 = lbText [1500,_index1];
	_leader1 = lbData [1500,_index1];
	_group1 = units (missionNameSpace getVariable (_value1));
	_leader = leader (_group1 select 0);
	if ((str _group2)!=(_value1)) then
	{
		hint format["You joined '%1'",_group1 select 0];
		[_unit] joinSilent _leader;
	} else {
	hint "Cant join the same group!";
	};
	if ((count (units _group2))==0) then
	{
		deleteGroup _group2;
	};
	action1 = [_unit] spawn fnc_yink_groupInfo;
	//hint format["You joined '%1'",_group1 select 0];
	[{ refresh1 = [player] spawn fnc_yink_refresh},"BIS_fnc_spawn",side player,true] call BIS_fnc_MP;
};

fnc_yink_groupNew =
{
	_player = _this select 0;
	_side = side _player;
	_group = createGroup _side;
	if (missionType=="pvp")then
	{
		switch (_side) do
		{
			case west:
			{
				_unassigned = unassignedWest;
			};
			case east:
			{
				_unassigned = unassignedEast;
			};
			case resistance:
			{
				_unassigned = unassignedInd;
			};
			case civilian:
			{
				_unassigned = unassignedCiv;
			};
		};
	};
	hint "created group!";
	_player = _this select 0;
	[_player] joinSilent _group;
	[{ refresh1 = [player] spawn fnc_yink_refresh},"BIS_fnc_spawn",side player,true] call BIS_fnc_MP;

};

fnc_yink_kick =
{	
	_unit = _this select 0;
	_target = objNull;
	_side = side _unit;
	_group2 = group _unit;
	_index1 = _unit getVariable "memberIndex";
	_value1 = lbText [1501,_index1];
	_memberTarget = lbData [1501,_index1];
	_admin = serverCommandAvailable "#kick";
	_unassigned = grpNull;
	_names = ["<Void West>",("<Void East>"),("<Void Ind>"),("<Void Civ>")];

	if ((_unit==(leader ((missionNameSpace getVariable _memberTarget) select 0)))||(_admin)) exitWith
	{
		if ((name ((missionNameSpace getVariable _memberTarget) select 0)) in _names) exitWith
		{
			hint "cant kick that AI!";
		};
		
		switch (_side) do
		{
			case west:
			{
				_unassigned = unassignedWest;
			};
			case east:
			{
				_unassigned = unassignedEast;
			};
			case resistance:
			{
				_unassigned = unassignedInd;
			};	
			case civilian:
			{
				_unassigned = unassignedCiv;
			};
		};
		[((missionNameSpace getVariable _memberTarget) select 0)] joinSilent _unassigned;	 
		hint ((name ((missionNameSpace getVariable _memberTarget) select 0)) + " kicked!");
		_action1 = [_unit] spawn fnc_yink_groupInfo;
		lbClear 1500;
		lbClear 1501;
		[{ refresh1 = [player] spawn fnc_yink_refresh},"BIS_fnc_spawn",side player,true] call BIS_fnc_MP;
	};
	
	hint "You're not Squad Leader!";
};

fnc_yink_directJoin =
{

	_unit	= (_this select 3) select 0;
	_group	= (_this select 3) select 1;
	_unit1	= (_this select 3) select 2;
	_unit setVariable ["invited",false];
	hint format ["Joined: '%1'",_group];
	[{ refresh1 = [player] spawn fnc_yink_refresh},"BIS_fnc_spawn",side player,true] call BIS_fnc_MP;
	{
		_unit removeAction _x;
	} forEach (_unit getVariable "actions");
	_unit setVariable ["actions", [ ]];
	[_unit] joinSilent _group;
	[format["%1 Joined your group",_unit], "hint", _unit1, false, true] call BIS_fnc_MP;
};

fnc_yink_inviteInvite =
{
	
	_target = _this select 0;
	_group	= _this select 1;
	_admin 	= _this select 2;
	_unit 	= _this select 3;
	_id		= 10000;
	_names = ["<Void West>",("<Void East>"),("<Void Ind>"),("<Void Civ>")];
	
	if ((name _target) in _names) exitWith
	{
		hint "cant invite that AI!";
	};
	if (!(_admin)) then
	{
		_id = _target addaction
		[
			format["Join %1",_group],
			fnc_yink_directJoin,
			[_target,_group,_unit],
			1.5,
			true,
			true,
			"",
			"_target == _this"
		];
	};

	if (_admin) then
	{
		_join = [objNull,objNull,objNull,[_target,_group,_unit]] call fnc_yink_directJoin;
	};
	
	_curSel = lbCurSel 1500;
	[{refresh1 = [player] spawn fnc_yink_refresh},"BIS_fnc_spawn",side player,true] call BIS_fnc_MP;
	lbSetCurSel [1500,_curSel];
	if (_id==10000) then
	{	
		_target setVariable ["actions",(_target getVariable "actions") + [_id]];
		sleep 15;
		_target removeAction _id;
	};
};

fnc_yink_invitePromote =
{
	target = _this select 0;
	publicVariable "target";
	group1	= _this select 1;
	publicVariable "group1";
	_side = side target;
	switch (_side) do
	{
		case west:
		{
			_unassigned = unassignedWest;
		};
		case east:
		{
			_unassigned = unassignedEast;
		};
		case resistance:
		{
			_unassigned = unassignedInd;
		};
			case civilian:
		{
			_unassigned = unassignedCiv;
		};
	};

	if (group1==_unassigned) exitWith
	{
		hint "cant promote in this group!";
	};
	_admin	= _this select 2;
	[{group1 selectLeader target},"BIS_fnc_spawn",side player,true] call BIS_fnc_MP;
	[{ refresh1 = [player] spawn fnc_yink_refresh},"BIS_fnc_spawn",side player,true] call BIS_fnc_MP;
};	


fnc_yink_invite =
{
	
	_unit = _this select 0;
	_side = side _unit;
	_group = group _unit;
	_index1 = _unit getVariable "memberIndex";
	_value1 = lbText [1501,_index1];
	_memberTarget = lbData [1501,_index1];
	_target = (missionNameSpace getVariable _memberTarget) select 0;
	_leader = leader _target;
	_target setVariable ["invited",true];
	_admin = serverCommandAvailable "#kick";
	[{ refresh1 = [player] spawn fnc_yink_refresh},"BIS_fnc_spawn",side player,true] call BIS_fnc_MP;
	
	if (((_unit==(leader _unit))||(_admin))&&((ctrlText 1603)=="Invite")) then
	{
		hint format["You invited:\n%1\n-to-\n%2",_target,_group];
		[[_target,_group,_admin,_unit], "fnc_yink_inviteInvite", _target, true] call BIS_fnc_MP;
		[format["you were invited to %1\nBy: %2",_group,name _unit], "hint", _target, true] call BIS_fnc_MP;
	};
	if (((_unit==(leader _unit))||(_admin))&&((ctrlText 1603)=="Promote")) then
	{
		hint format["You Promoted:\n%1\n-in-\n%2",_target,_group];
		[[_target,_group,_admin], "fnc_yink_invitePromote", _target, true] call BIS_fnc_MP;
		[format["you were Promoted to SL\nBy: %2",_group,name _unit], "hint", _target, true] call BIS_fnc_MP;
	};
};

fnc_yink_changeName =
{
	_unit = _this select 0;
	_admin = serverCommandAvailable "#kick";
	if ((dialog)&&((_unit==(leader _unit))||(_admin))) then
	{	
		
		temp_name1	= ctrlText 2501;
		temp_group1	= group _unit;
		publicvariable "temp_name1";
		publicvariable "temp_group1";
		
		if ((str (temp_group1))=="B Unassigned") exitWith
		{
			hint "Can't edit Waiting Group!";
		};
		
		[{ temp_group1 setGroupId [temp_name1];},"BIS_fnc_spawn",side player,true] call BIS_fnc_MP;
		sleep 0.2;
		hint format["New squad name:\n%1", temp_group1];
		temp_name1 	= objNull;
		temp_group1	= objNull;
		[{ refresh1 = [player] spawn fnc_yink_refresh},"BIS_fnc_spawn",side player,true] call BIS_fnc_MP;
	
		temp_name1 	= objNull;
		temp_group1	= objNull;
	};
};



fnc_yink_activate =
{
	_key = _this select 1;
	if ((!dialog)&&((inputaction "teamswitch")>0)) then
	{
		[objNull,player] execVM "YGM\Functions\execYGM.sqf";
		(findDisplay 46) displayRemoveAllEventHandlers "keyDown";
		waituntil{!dialog};
		(findDisplay 46) displayAddEventHandler ["keyDown", fnc_yink_activate];
	};
	
	if ((dialog)&&((inputaction "teamswitch")>0)) then
	{
		closedialog 2201;
	};	
};
	

fnc_yink_deactivate =
{
};/*

};		
	
	
	
	





*/



