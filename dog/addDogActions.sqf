_Unit = _this select 0;

_PlayerProfile = getPlayerUID player;

_SharpeProfile = getPlayerUID sharpePlayer;

waitUntil {alive sharpePlayer};
if(_SharpeProfile == _PlayerProfile) then {
	sharpePlayer addAction ["Whistle", "dogWhistle.sqf"];
	sharpePlayer addAction ["Follow", "dogFollow.sqf"];
	sharpePlayer addAction ["Find", "dogSeek.sqf"];
	sharpePlayer addAction ["Heel", "dogHeel.sqf"];
	sharpePlayer addAction ["Rest", "dogHide.sqf"];
	sharpePlayer addAction ["Stop", "dogStop.sqf"];
	}