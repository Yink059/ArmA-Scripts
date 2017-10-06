continue = false;
onPreloadFinished { continue = true};



if (isServer) then {
	execVM "Yink\init_server.sqf";
	execVM "Yink\init_players.sqf";
};

player action ["lightOn",  truck];
waitUntil{!(isNull player)};
if (!isServer) then {
	execVM "Yink\init_players.sqf";
};



player action ["lightOn",  truck];

