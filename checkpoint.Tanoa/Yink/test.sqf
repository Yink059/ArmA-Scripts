//execVM "Yink\checkpoint_yink.sqf";
				_soundPath = [(str missionConfigFile), 0, -15] call BIS_fnc_trimString;
				_soundToPlay = _soundPath + "sound\move_along.ogg";
				player playAction "gestureGo";
				player say3D ["see_id", 25, 1];//[_soundToPlay, (player), false, getPos player, 50, 1, 25]