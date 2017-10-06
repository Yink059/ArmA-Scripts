hint "Jessie, follow!";

dogFollow = 'true';

while {dogFollow == 'true'} do {
    if ((dog1 distance sharpePlayer) < 4) then {
		dog1 domove getpos dog1;
	} else {
		dog1 domove getpos sharpePlayer;	
	};
   
    sleep 1;
};