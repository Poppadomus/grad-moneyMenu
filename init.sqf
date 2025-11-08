//Rewards the player with $100 per kill has a fancy cascading kill feed

fnc_floatingKillText = {       
    params ["_text", "_startX", "_startY", "_moveX", "_moveY", "_duration"];       
    private _display = findDisplay 46;       
    private _ctrl = _display ctrlCreate ["RscStructuredText", -1];       
           
    _ctrl ctrlSetPosition [_startX, _startY, 0.4, 0.1];       
    _ctrl ctrlSetStructuredText parseText _text;       
    _ctrl ctrlSetFade 0;       
    _ctrl ctrlCommit 0;       
           
    private _startTime = diag_tickTime;       
    private _pos = ctrlPosition _ctrl;       
           
    while {diag_tickTime - _startTime < _duration} do {       
        _pos set [0, (_pos select 0) + (_moveX * (diag_tickTime - _startTime) / _duration)];       
        _pos set [1, (_pos select 1) + (_moveY * (diag_tickTime - _startTime) / _duration)];       
        _ctrl ctrlSetPosition _pos;       
        _ctrl ctrlCommit 0;       
        sleep 0.01;       
    };       
           
    _ctrl ctrlSetFade 1;       
    _ctrl ctrlCommit 1;       
           
    sleep 1;       
    ctrlDelete _ctrl;       
};

if (hasInterface) then {     
    addMissionEventHandler ["EntityKilled", {     
        params ["_killed", "_killer", "_instigator"];     
        if (isNull _instigator) then {     
            _instigator = _killer;     
        };     
     
        if (isPlayer _killer && {_killed isKindOf "CAManBase"}) then {     
            private _distance = _killer distance2D _killed;     
            private _killed_Name = "";     
                   
            if (!(isPlayer _killed)) then {     
                _killed_Name = getText (configFile >> "CfgVehicles" >> format ["%1", typeOf _killed] >> "displayName");     
            } else {     
                _killed_Name = name _killed;     
            };     
     
            [_killer, 100] remoteExec ["grad_money_fnc_give", 2];
            
            [_killer, 100] call grad_moneymenu_fnc_addFunds;
     
            private _sideColor = switch (true) do {     
                case (side group _killed == west): { "#0000FF" };     
                case (side group _killed == east): { "#FF0000" };     
                case (side group _killed == independent): { "#00FF00" };     
                default { "#FF00FF" };     
            };     
     
            private _kill_HUD = format ["<t size='0.8' color='#FFFFFF' align='right'><t color='%1'>%2</t> Eliminated (<t color='#00FFFF'>%3m</t>) | <t color='#00FF00'>$%4</t></t>", _sideColor, _killed_Name, floor _distance, 100];     
                   
            [_kill_HUD, safezoneX + (safezoneW / 2) - 0.05, safezoneY + (safezoneH / 2) - 0.05, 0, 0.005, 5] remoteExec ["fnc_floatingKillText", owner _killer];
        };     
    }];     
};
