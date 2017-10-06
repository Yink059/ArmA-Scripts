_missionTimeLimit = _this select 0;

if (isServer) then
{
	_run = true;
	playerMessage = "none";
	while {_run} do
	{
		if (time >= _missionTimeLimit) then
		{
			if !(flagOwnedBySide == "eastWon" || flagOwnedBySide == "westWon") then
			{
				missionTimeout = "true";
				publicVariable "missionTimeout";
			};
			_run = false;
		};
		if ((time >= (_missionTimeLimit / 2)) && (time < ((_missionTimeLimit / 2) + 20)) && (playerMessage == "fulltime")) then
		{
			playerMessage = "halftime";
			//publicVariable "playerMessage";
			["Half the time is over. Move your objectives.","hint",true,false] call BIS_fnc_MP;
		};
		if ((time >= 10) && (time < 30) && (playerMessage == "none")) then
		{
			playerMessage = "fulltime";
			_timeMssg = format ["You have %1 minutes to complete your objectives.", (_missionTimeLimit / 60)];
			[_timeMssg,"hint",true,false] call BIS_fnc_MP;
		};
		sleep 2;
	};
};