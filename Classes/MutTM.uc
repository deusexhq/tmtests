class MutTM extends Mutator;

function bool isHostile(ScriptedPawn sp){
     local int i;

     for (i=0; i<8; i++){
          if (sp.InitialAlliances[i].AllianceName == 'player' 
          || sp.InitialAlliances[i].AllianceName == 'Player'){
               if(sp.InitialAlliances[i].AllianceLevel == 1)
                    return false;
               else
                    return true;
          }
     }
}

// switchGlobalAlliances
// Switch alliance for player for all NPC's
function switchGlobalAlliances(){
     local ScriptedPawn sp;
     local int i;

     foreach AllActors(class'ScriptedPawn', sp){
	     for (i=0; i<8; i++){
		     if (sp.InitialAlliances[i].AllianceName == 'player' 
               || sp.InitialAlliances[i].AllianceName == 'Player'){
			     if(sp.InitialAlliances[i].AllianceLevel == 1)
                         sp.InitialAlliances[i].AllianceLevel = -1;
                    else
                         sp.InitialAlliances[i].AllianceLevel = 1;
               }
          }
          sp.InitializeAlliances();

     }
}

// grabSkin
// takes the skin from Source and applies it to Target
function grabSkin(pawn Source, pawn Target){
     //local vector l;
     //l = Target.Location;
     //l.z += int(Self.Default.CollisionHeight);
     //Target.SetLocation(l);
     Target.Mesh = Source.Mesh;
     Target.Drawscale = Source.Drawscale;
     Target.Fatness = Source.Fatness;
     //Target.SetCollisionSize(Source.CollisionRadius, Source.CollisionHeight);

     //Target.BaseEyeHeight = Source.BaseEyeHeight;
     Target.Skin = Source.Skin;
     Target.Texture = Source.Texture;
     Target.bMeshEnviroMap = Source.bMeshEnviroMap;
     Target.Multiskins[0] = Source.MultiSkins[0];
     Target.Multiskins[1] = Source.MultiSkins[1];
     Target.Multiskins[2] = Source.MultiSkins[2];
     Target.Multiskins[3] = Source.MultiSkins[3];
     Target.Multiskins[4] = Source.MultiSkins[4];
     Target.Multiskins[5] = Source.MultiSkins[5];
     Target.Multiskins[6] = Source.MultiSkins[6];
     Target.Multiskins[7] = Source.MultiSkins[7];
}

function grabInventory(pawn Source, pawn Target){
     local inventory item;

     for (item=Source.Inventory; item!=None; item=Source.Inventory){
          //log(item);
          //if(item.isA('Hijack')) t = Hijack(item);
          Source.DeleteInventory(item);
          Target.AddInventory(item);
     }
}


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
