class MutTM extends Mutator;

function PostBeginPlay (){
    Level.Game.BaseMutator.AddMutator (Self);
    Level.Game.RegisterDamageMutator (Self);
}

simulated function ShowMessage(DeusExPlayer Player, string Message){
    local HUDMissionStartTextDisplay    HUD;

    if ((Player.RootWindow != None) && (DeusExRootWindow(Player.RootWindow).HUD != None)) {
        HUD = DeusExRootWindow(Player.RootWindow).HUD.startDisplay;
    }

    if(HUD != None) {
        HUD.shadowDist = 0;
        //HUD.setFont(Font'FontMenuTitle');
        HUD.fontText = Font'FontMenuExtraLarge';
        HUD.Message = "";
        HUD.charIndex = 0;
        HUD.winText.SetText("");
        HUD.winTextShadow.SetText("");
        HUD.displayTime = 5.50;
        HUD.perCharDelay = 0.01;
        HUD.AddMessage(Message);
        HUD.StartMessage();
    }
}

simulated final function createBark(DeusExPlayer _Player, Actor BotSender, string msg, float Delay){
	local DeusExRootWindow _root;

	if(_Player != None){
		_root = DeusExRootWindow(_Player.rootWindow);
		if(_root != None){
			_root.hud.barkdisplay.addBark(msg, Delay, BotSender);
		}
	}
}


function Mutate (String S, PlayerPawn PP){
    local DeusExPlayer player;
    local string msgs;
    local ScriptedPawn ps;
    local TMTWeapon T;
    Super.Mutate (S, PP);
    player = DeusExPlayer(pp);

    if(left(S,5) ~= "MSGR ") {
        msgs = Right(S, Len(S) - 5);
        ShowMessage(Player, msgs);
    }

    if(left(S,5) ~= "BARK ") {
        msgs = Right(S, Len(S) - 5);
        CreateBark(Player, Player, msgs, 3.0);
    }

    if(s ~= "SHOUT") {
        if(player.InHand.IsA('TMTWeapon')){
            T = TMTWeapon(player.InHand);
            T.ExecShout();
        }
    }

    if(s ~= "TAKEDOWN") {
        if(player.InHand.IsA('TMTWeapon')){
            T = TMTWeapon(player.InHand);
            T.Takedown();
        }
    }

    if(s ~= "ORDER") {
        if(player.InHand.IsA('TMTWeapon')){
            T = TMTWeapon(player.InHand);
            T.OrderTarget();
        }
    }
}

defaultproperties
{
}
