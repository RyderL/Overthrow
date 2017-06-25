params ["_jobid","_jobparams"];
_jobparams params ["_faction"];

private _description = "";
private _destination = [];
private _title = "";

private _reppos = server getVariable [format["factionrep%1",_faction],getpos player];
private _roads = _reppos nearRoads 75;
if(count _roads > 0) then {
    _destination = getpos(_roads select 0);
}else{
    _destination = _reppos;
};

private _items = [];

private _itemcls = selectRandom OT_allCheapRifles;
private _itemName = _itemcls call OT_fnc_weaponGetName;
private _cost = (cost getVariable [_itemcls,[1]]) select 0;
private _numitems = floor(5 + random 5);

private _params = [_destination,_faction,_itemcls,_numitems];
private _markerPos = _destination;
private _factionName = server getvariable format["factionname%1",_faction];

//Build a mission description and title
_description = format["%1 requests %2 x %3. Deliver them to the marked location using any vehicle, just pull up with the weapons in the inventory and you will be paid for them, including any extras of the same type. </t><br/><t size='0.9'>Reward: +1 (%1), export value of weapons",_factionName,_numitems,_itemName];
_title = format["%1 requests %2 x %3",_factionName,_numitems,_itemName];

//The data below is what is returned to the gun dealer/faction rep, _markerPos is where to put the mission marker, the code in {} brackets is the actual mission code, only run if the player accepts
[[_title,_description],_markerPos,{
    //No setup required for this mission
},{
    //Fail check...
    false
},{
    //Success Check
    params ["_destination","_faction","_itemcls","_numitems"];
    _numavailable = 0;

    _driver = objNull;
    {
		_c = _x;
        if((_x call OT_fnc_hasOwner) and (speed _x) < 0.1) exitWith {
		     {
    			_x params ["_cls","_amt"];
                _cls = _cls call BIS_fnc_baseWeapon;
    			if(_cls == _itemcls) then {
    				_numavailable = _numavailable + _amt;
                    _driver = driver _c;
    			};
    		}foreach(_c call OT_fnc_unitStock);
        };
	}foreach(_destination nearObjects ["AllVehicles", 30]);

    _numavailable >= _numitems
},{
    params ["_destination","_faction","_itemcls","_numitems","_wassuccess"];

    //If mission was a success
    if(_wassuccess) then {
        //Take the weapons and count them
        _numavailable = 0;
        _driver = objNull;
        {
    		_c = _x;
            if((_x call OT_fnc_hasOwner) and (speed _x) < 0.1) then {
    		     {
        			_x params ["_cls","_amt"];
                    _basecls = _cls call BIS_fnc_baseWeapon;
        			if(_basecls == _itemcls) then {
                        _driver = driver _c;
                        [_c, _cls, _amt] call CBA_fnc_removeWeaponCargo;
                        _numavailable = _numavailable + _amt;
        			};
        		}foreach(_c call OT_fnc_unitStock);
            };
    	}foreach(_destination nearObjects ["AllVehicles", 30]);

        //apply standing and pay money
        _topay = ([OT_nation,_itemcls,0] call OT_fnc_getSellPrice) * _numavailable;
        [_topay,format["Delivered %1 x %2 (+1 %3)",_numitems,_itemcls call OT_fnc_weaponGetName,server getvariable format["factionname%1",_faction]]] remoteExec ["OT_fnc_money",_driver,false];
        server setVariable [format["standing%1",_faction],(server getVariable [format["standing%1",_faction],0]) + 1,true];
    };
},_params];
