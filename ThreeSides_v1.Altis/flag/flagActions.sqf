_run = true;
sleep 2;
_takeActionAddedPlayer = false;
_dropActionAddedCarrier = false;
_tfID = 100;
_dfID = 99;

while {_run} do
{
	if (flagCarrier == player) then
	{
		if !(_dropActionAddedCarrier) then
		{
			//add actions to flag carrier
			_dfID = player addAction ["<t color='#FF3333'>DROP FLAG</t>", "flag\dropFlag.sqf"];
			_dropActionAddedCarrier = true;
//			"mrk_bomb" setMarkerPos [0,0,0];
		};
	};
	
	//player sideChat format ["%1 from flag.", player distance flagTarget];
	if (flagCarrier == noOne) then
	{
		if (flagOwnedBySide == "west" && side player == west) then
		{		
			if (player distance flagTarget < 5.5) then
			{
				if !(_takeActionAddedPlayer) then
				{
					//add actions to flag to pick it up
					_tfID = player addAction ["<t color='#FF3333'>TAKE FLAG</t>", "flag\takeFlag.sqf"];
					_takeActionAddedPlayer = true;
				};
			};
		};
		if (flagOwnedBySide == "east" && side player == east) then
		{		
			if (player distance flagTarget < 5.5) then
			{
				if !(_takeActionAddedPlayer) then
				{
					//add actions to flag to pick it up
					_tfID = player addAction ["<t color='#FF3333'>TAKE FLAG</t>", "flag\takeFlag.sqf"];
					_takeActionAddedPlayer = true;
				};
			};
		};
		if (flagOwnedBySide == "none") then
		{		
			if (player distance flagTarget < 5.5) then
			{
				if !(_takeActionAddedPlayer) then
				{
					//add actions to flag to pick it up
					_tfID = player addAction ["<t color='#FF3333'>TAKE FLAG</t>", "flag\takeFlag.sqf"];
					_takeActionAddedPlayer = true;
				};
			};
		};		
	};
	
	//clean up actions
	if (_takeActionAddedPlayer) then
	{
		sleep 3;
		player removeAction _tfID;
		_takeActionAddedPlayer = false;
	};
	
	if (_dropActionAddedCarrier) then
	{
		sleep 3;
		player removeAction _dfID;
		_dropActionAddedCarrier = false;
	};
	sleep .2;

};
