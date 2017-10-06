//player init

//nul = [] execVM "intro\intro.sqf";
player action ["lightOn",  truck];
missionNameSpace setVariable ["cars",[]];
gate allowdamage false;
player addEventHandler ["HandleRating",{0}];
player removePrimaryWeaponItem "acc_pointer_IR";
player addPrimaryWeaponItem "acc_flashlight";
player unassignItem "NVGoggles_tna_F";
player removeItem "NVGoggles_tna_F";
leader1 assignItem "Rangefinder";
leader1 addItem "Rangefinder";
call1 = {
	//<param> call1 {code};
	(_this select 0) call (_this select 1);
};
waitUntil {continue};
nul = [] execVM "intro\intro.sqf";