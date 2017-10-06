execVM "YGM\functionsGM.sqf";

_unit = _this select 1;
_side = side _unit;
_groupManager = createDialog "groupManager";

lbClear 1500;
{

	_bool1 = false;
	{
		if ((isplayer _x)||((name _x)=="<Admin>")) then
		{
			_bool1 = true;
		};
	} foreach units _x;
	
	if (((side (leader _x))==_side)&&(_bool1)) then
	{
		_index1 = lbAdd [1500,str _x];
		lbSetData [1500,_index1, str (leader _x)];
		missionNameSpace setVariable [(str _x), _x];
	};

} forEach allGroups;

lbSetCurSel [1500,0];










//invite/promote below


	
	



	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	




/* #Baxefa
$[
	1.063,
	["GM",[[0,0,1,1],0.025,0.04,"GUI_GRID"],0,0,0],
	[1800,"frame_left",[2,"",["2.07 * GUI_GRID_W + GUI_GRID_X","1.01 * GUI_GRID_H + GUI_GRID_Y","8 * GUI_GRID_W","22 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1801,"frame_right",[2,"",["30 * GUI_GRID_W + GUI_GRID_X","1 * GUI_GRID_H + GUI_GRID_Y","8 * GUI_GRID_W","22 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1802,"frame_top",[2,"",["10 * GUI_GRID_W + GUI_GRID_X","2 * GUI_GRID_H + GUI_GRID_Y","20 * GUI_GRID_W","5 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1500,"lb_left",[2,"",["3 * GUI_GRID_W + GUI_GRID_X","3 * GUI_GRID_H + GUI_GRID_Y","6 * GUI_GRID_W","16 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1000,"text_title",[2,"Group Manager",["15 * GUI_GRID_W + GUI_GRID_X","0.5 * GUI_GRID_H + GUI_GRID_Y","10 * GUI_GRID_W","1.5 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","1.45"],[]],
	[1001,"text_title_left_lb",[2,"Groups:",["3 * GUI_GRID_W + GUI_GRID_X","1.5 * GUI_GRID_H + GUI_GRID_Y","3.5 * GUI_GRID_W","1.5 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Names of active groups","-1"],[]],
	[1002,"text_title_current",[2,"Current Group:",["10.5 * GUI_GRID_W + GUI_GRID_X","2.5 * GUI_GRID_H + GUI_GRID_Y","6.5 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Name of your active group","-1"],[]],
	[1003,"text_current",[2,"<nil>",["10.5 * GUI_GRID_W + GUI_GRID_X","3.5 * GUI_GRID_H + GUI_GRID_Y","8.5 * GUI_GRID_W","1.5 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"name of your current group","-1"],[]],
	[1004,"text_title_current_leader",[2,"Group Leader:",["20 * GUI_GRID_W + GUI_GRID_X","2.5 * GUI_GRID_H + GUI_GRID_Y","6.5 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"leader of active group, why are you hovering over this?","-1"],[]],
	[1005,"text_current_leader",[2,"<nil>",["20 * GUI_GRID_W + GUI_GRID_X","3.5 * GUI_GRID_H + GUI_GRID_Y","8.5 * GUI_GRID_W","1.5 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"name of your current group","-1"],[]],
	[1600,"button_join",[2,"Join Group",["11 * GUI_GRID_W + GUI_GRID_X","5.5 * GUI_GRID_H + GUI_GRID_Y","5 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"join the selected group","-1"],[]],
	[1501,"lb_right",[2,"",["31 * GUI_GRID_W + GUI_GRID_X","3 * GUI_GRID_H + GUI_GRID_Y","6 * GUI_GRID_W","16 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1006,"text_title_right_lb",[2,"Members:",["31 * GUI_GRID_W + GUI_GRID_X","1.5 * GUI_GRID_H + GUI_GRID_Y","4 * GUI_GRID_W","1.5 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"title for players","-1"],[]],
	[1601,"button_new_group",[2,"New Group",["20.5 * GUI_GRID_W + GUI_GRID_X","5.5 * GUI_GRID_H + GUI_GRID_Y","5 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"join the selected group","-1"],[]],
	[1602,"button_kick_right_lb",[2,"Kick",["31 * GUI_GRID_W + GUI_GRID_X","20 * GUI_GRID_H + GUI_GRID_Y","6 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"join the selected group","-1"],[]],
	[1603,"button_right_invite_lb",[2,"Invite",["31 * GUI_GRID_W + GUI_GRID_X","21.5 * GUI_GRID_H + GUI_GRID_Y","6 * GUI_GRID_W","1 * GUI_GRID_H"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"join the selected group","-1"],[]]
]
*/
