if (!isServer) exitwith {};

_leaderpos = objNULL;

waitUntil{not isNil "AIT_economyInitDone"};

{
	_town = _x;
	_posTown = server getVariable _town;
	_mSize = 300;
	if(_town in AIT_capitals) then {
		_mSize = 800;
	};
	_garrison = 0;	
	_stability = server getVariable format ["stability%1",_town];
	server setVariable [format["crimnew%1",_town],false,true];
	server setVariable [format["crimadd%1",_town],0,true];
	if(_stability < 17) then {
		_garrison = 2+round((1-(_stability / 10)) * 6);				
		_building = [_posTown, AIT_crimHouses] call getRandomBuilding;
		if(isNil "_building") then {
			_leaderpos = [[[_posTown,_mSize]]] call BIS_fnc_randomPos;
		}else{
			_leaderpos = getpos _building;
		};
		
		server setVariable [format["crimleader%1",_town],_leaderpos,true];
	}else{
		server setVariable [format["crimleader%1",_town],false,true];
	};
	server setVariable [format ["numcrims%1",_x],_garrison,true];
	server setVariable [format ["timecrims%1",_x],0,true];
}foreach (AIT_allTowns);

AIT_CRIMInitDone = true;
publicVariable "AIT_CRIMInitDone";

_sleeptime = 0;

while {true} do {
	{			
		_town = _x;
		_posTown = server getVariable _town;
		_mSize = 300;
		if(_town in AIT_capitals) then {
			_mSize = 800;
		};
		_stability = server getVariable format ["stability%1",_town];
		if((_stability < 30) || (_town in (server getvariable "NATOabandoned"))) then {
			_time = server getVariable format ["timecrims%1",_town];
			_num = server getVariable format ["numcrims%1",_town];
			
			_leaderpos = server getVariable format["crimleader%1",_town];
			if ((typeName _leaderpos) == "ARRAY") then {
				server setVariable [format ["timecrims%1",_x],_time+_sleeptime,true];
				if(((random 100) > 80) and _num < 20) then {
					server setVariable [format ["numcrims%1",_x],_num + 1,true];
				};
			}else{
				if((random 100) > 90) then {
					//New leader spawn
					_building = [_posTown, AIT_crimHouses] call getRandomBuilding;
					if(isNil "_building") then {
						_leaderpos = [[[_posTown,50]]] call BIS_fnc_randomPos;
					}else{
						_leaderpos = getpos _building;
					};	
					server setVariable [format["crimnew%1",_town],_leaderpos,true];
					server setVariable [format ["crimadd%1",_x],4,true];
					server setVariable [format ["timecrims%1",_x],0,true];
				}
			};			
		};
		sleep 0.1;
	}foreach (AIT_allTowns);
	_sleeptime = AIT_CRIMwait + round(random AIT_CRIMwait);
	sleep _sleeptime;
};

