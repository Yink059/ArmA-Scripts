hint "Jessie, seek!";

dogFollow = 'false';

_bomber = dog1;
_radius = 1000;
_side   = east;


_nearestunits = nearestObjects [_bomber,["Man"],_radius];


_nearestunitofside = [];


if(_side countSide _nearestunits > 0) then{
   {
      _unit = _x;
      if(side _unit == _side) then{_nearestunitofside = _nearestunitofside + [_unit]};
   } foreach _nearestunits;
};


_bomber domove getpos (_nearestunitofside select 0);