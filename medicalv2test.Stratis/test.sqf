//test.sqf for medical v2


//(_this select 0) addEventHandler ["killed","hint 'hi';"];
//(_this select 0) addEventHandler ["respawn","hint 'ji';"];

private ["_path"];
_path = gettext (configfile >> "RscGUIEditor" >> "path");
[] spawn compile preprocessfilelinenumbers (_path + "GUI_init.sqf");