_playerKilled = _this select 0;

if (_playerKilled == flagCarrier) then
{
	_killedMssg = format ["%1 has dropped the flag!", name _playerKilled];
	[_killedMssg,"hint",true,false] call BIS_fnc_MP;

	//_playerKilled allowDamage false;	
	detach flagTarget;
	flagTarget setPos [(getPos flagTarget select 0), (getPos flagTarget select 1), 0];
	flagCarrier = noOne;
	publicVariable "flagCarrier";
	sleep .5;
	//player allowDamage true;
};