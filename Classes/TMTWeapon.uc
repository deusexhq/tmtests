class TMTWeapon extends DeusExWeapon;

#exec TEXTURE IMPORT NAME="isightglock" FILE="Textures\pistol_sight.bmp" GROUP="Skins" FLAGS=2
#exec TEXTURE IMPORT NAME="isightglock2" FILE="Textures\pistol_sight2.pcx" GROUP="Skins" FLAGS=2

var() float shoutRadius, tauntTimeout;
var ScriptedPawn Taunts[16];
var float TauntTimeouts[16];
var string TauntInfo[16];
var ScriptedPawn lastLookedAt;
var() float Cooldown, CooldownTime;
var bool bIronSightsOn;

function IronSightsOn(){
    PlayerViewOffset.X=500.000000;
    PlayerViewOffset.Y=300.000000;
    PlayerViewOffset.Z=-700.000000;
	if(TMTPlayer(Owner) != None){
        TMTPlayer(Owner).bCrosshairVisible = False;

        DeusExRootWindow(TMTPlayer(Owner).rootWindow).UpdateHud();
        TMTPlayer(Owner).GroundSpeed /= 2;
	}
    Level.Game.SetGameSpeed(0.2);
	Level.Game.SaveConfig(); 

    BaseAccuracy = 0.0;
    bIronSightsOn = True;

}

function IronSightsOff(){
    TMTPlayer(Owner).bCrosshairVisible = True;

    DeusExRootWindow(TMTPlayer(Owner).rootWindow).UpdateHud();
    PlayerViewOffset = Default.PlayerViewOffset * 100;
    TMTPlayer(Owner).ChangeSetHand("right");
    //TMTPlayer(Owner).extHUD.ironSight.DeactivateView();
    TMTPlayer(Owner).GroundSpeed = TMTPlayer(Owner).default.GroundSpeed;
    BaseAccuracy = Default.BaseAccuracy;
    Level.Game.SetGameSpeed(1);
	Level.Game.SaveConfig(); 
    bIronSightsOn = False;
}

function ToggleIronSights(){
    if(bIronSightsOn) IronSightsOff();
    else IronSightsOn();
}

function ScopeOn()
{
	
    super.ScopeOn();
    bZoomed = False;
}

function ScopeOff()
{
	super.ScopeOff();
    bZoomed = False;
}

simulated function ScopeToggle()
{
	super.ScopeToggle();
}

function MutTM WorldMutator(){
    local MutTM M;
    foreach AllActors(class'MutTM', M) return M;
    return Spawn(class'MutTM');
}

simulated function RenderOverlays(canvas Canvas){
    local DeusExPlayer P;
    local float Scale;
    local int y, i;
	local float			fromX, toX;
	local float			fromY, toY;
	local float			scopeWidth, scopeHeight;
    local string str;
	local float mod;

    scopeWidth  = 256;
	scopeHeight = 256;

	fromX = (512-scopeWidth)/2;
	fromY = (512-scopeHeight)/2;
	toX   = fromX + scopeWidth;
	toY   = fromY + scopeHeight;

    Super.RenderOverlays(Canvas);
    P = DeusExPlayer(Owner);
    y = 0.5 * Canvas.ClipY - 16 * Scale;
    //bOwnsCrossHair = True; 
    Scale = Canvas.ClipX/640;
    
    Canvas.DrawColor.R = 200;
    Canvas.DrawColor.G = 200;
    Canvas.DrawColor.B = 200;
    Canvas.Font = Canvas.SmallFont;

    
    for (i=0; i<16; i++){ 
        if(Taunts[i] != None) {
            Canvas.SetPos(0.5 * Canvas.ClipX - 16 * Scale, y);
            if(TauntInfo[i] == "CLEAR")
                Canvas.DrawText("        > "$Taunts[i].FamiliarName$" ("$TauntInfo[i]$")_");
            else
                Canvas.DrawText("        > "$Taunts[i].FamiliarName$" ("$TauntInfo[i]$"): "$TauntTimeouts[i]$"_");
            y += 20;
        }
    }
    Canvas.SetPos(0.5 * Canvas.ClipX - 16 * Scale, y);
    //if(bIronSightsOn){
		str = "ACCURACY "$Int((2.0 - Default.BaseAccuracy)*50.0) $ "%";
		mod = (Default.BaseAccuracy - (BaseAccuracy + GetWeaponSkill())) * 0.5;
		if (mod != 0.0)	{
			str = str @ BuildPercentString(mod);
			str = str @ "=" @ Min(100, Int(100.0*mod+(2.0 - Default.BaseAccuracy)*50.0)) $ "%";
		}
        str = str$"_";
        Canvas.DrawText("        > "$str);
    //}
}

function bool isHostile(ScriptedPawn sp){
     local int i;

     for (i=0; i<8; i++){
          if (sp.InitialAlliances[i].AllianceName == 'player' 
          || sp.InitialAlliances[i].AllianceName == 'Player'){
               if(sp.InitialAlliances[i].AllianceLevel == -1)
                    return true;
               else
                    return false;
          }
     }
}

function setAlliance(ScriptedPawn sp, int ni){
    local int i;

    for (i=0; i<8; i++){
        if (sp.InitialAlliances[i].AllianceName == 'player' 
        || sp.InitialAlliances[i].AllianceName == 'Player'){
            sp.InitialAlliances[i].AllianceLevel = ni;
        }
    }
    sp.InitializeAlliances();

}

function AppendTaunt(ScriptedPawn t){
    local int i;

    for (i=0; i<16; i++){
        if(Taunts[i] == None) { Taunts[i] = t; TauntTimeouts[i] = tauntTimeout; return; }
    }
}

function RemoveTaunt(ScriptedPawn t){
    local int i;

    for (i=0; i<16; i++){
        if(Taunts[i] == t) { Taunts[i] = None; TauntTimeouts[i] = 0.0; return; }
    }
}

function bool isTaunt(ScriptedPawn t){
    local int i;

    for (i=0; i<16; i++){ if(Taunts[i] == t) return true; }

    return false;
}

function float getTimeout(ScriptedPawn t){
    local int i;

    for (i=0; i<16; i++){ if(Taunts[i] == t) return TauntTimeouts[i]; }

    return 0.0;
}

function setTimeout(ScriptedPawn t, float n){
    local int i;

    for (i=0; i<16; i++){ if(Taunts[i] == t) TauntTimeouts[i] = n; }
}

function OrderTarget(){
    local DeusExPlayer  player;
    local scriptedpawn  hitpawn;
    local Actor         hitActor;
    local Vector        hitLocation, hitNormal, position, line;
    local float         dist;

    player = DeusExPlayer(Owner);
    // Tracing and finding target
    position       = player.Location;
    position.Z     += player.BaseEyeHeight;
    line           = Vector(player.ViewRotation) * 4000;
    hitActor       = Trace(hitLocation, hitNormal, position+line, position, true);
    hitpawn        = ScriptedPawn(hitactor);

    if(hitpawn != None && isTaunt(hitpawn)){
        dist = Abs(VSize(HitLocation - player.Location));
        if(dist < 100){
            if(hitpawn.IsInState('following')){
                hitpawn.GotoState('standing');
                WorldMutator().createBark(player, player, "Wait here.", 2.0);
                WorldMutator().createBark(player, hitpawn, "Fine.", 2.0);
            } else {
                hitpawn.GotoState('following');
                WorldMutator().createBark(player, player, "Follow me.", 2.0);
                WorldMutator().createBark(player, hitpawn, "Fine.", 2.0);
            }
        }
    }
}

function Takedown(){
    local DeusExPlayer  player;
    local scriptedpawn  hitpawn;
    local Actor         hitActor;
    local Vector        hitLocation, hitNormal, position, line;
    local float         dist;

    player = DeusExPlayer(Owner);
    // Tracing and finding target
    position       = player.Location;
    position.Z     += player.BaseEyeHeight;
    line           = Vector(player.ViewRotation) * 4000;
    hitActor       = Trace(hitLocation, hitNormal, position+line, position, true);
    hitpawn        = ScriptedPawn(hitactor);

    if(hitpawn != None && isTaunt(hitpawn)){
        dist = Abs(VSize(HitLocation - player.Location));
        if(dist < 100)
            hitpawn.TakeDamage(HitDamage*10, Player, hitLocation, position, 'knockedout');
    }
}

function Tick(float dt){
    local DeusExPlayer  player;
    local scriptedpawn  hitpawn;
    local Actor         hitActor;
    local Vector        hitLocation, hitNormal, position, line;
    local float         dist;
    local int i;

    if(cooldown > 0.0) cooldown -= dt;

    player         = DeusExPlayer(Owner);
    // Tracing and finding target
    position       = player.Location;
    position.Z     += player.BaseEyeHeight;
    line           = Vector(player.ViewRotation) * 4000;
    hitActor       = Trace(hitLocation, hitNormal, position+line, position, true);
    hitpawn        = ScriptedPawn(hitactor);

    if(hitpawn != None){
        lastLookedAt = hitpawn;
        dist = Abs(VSize(HitLocation - owner.Location));
        if(dist <= shoutRadius){
            setTimeout(hitpawn, tauntTimeout);
        }
    }

    for (i=0; i<16; i++){ 
       if(Taunts[i] != None && TauntTimeouts[i] > 0.0) {
            if(Taunts[i] == hitpawn) TauntInfo[i] = "CLEAR";
            else TauntInfo[i] = "RECOVERING";
            Taunts[i].LookAtActor(Owner, true, true, true);
            TauntTimeouts[i] -= dt;
            //DeusExPlayer(Owner).ClientMessage( i@Taunts[i]@TauntTimeouts[i] );
            if(TauntTimeouts[i] <= 0.0){
                setAlliance(Taunts[i], -1);
                RemoveTaunt(Taunts[i]);
                Taunts[i].SetEnemy(DeusExPlayer(Owner));
                Taunts[i].HandleEnemy();
                Taunts[i].setupWeapon(true);
            } 
       } 
    } 
}

function ExploFX(){
    local ShockRing s1, s2, s3;
    local TMTSphere sphere;

    s1 = spawn(class'ShockRing',,,owner.location,rot(16384,0,0));
	//s1.Lifespan = 2.5;
    s2 = spawn(class'ShockRing',,,owner.location,rot(0,16384,0));
	//s2.Lifespan = 2.5;
    s3 = spawn(class'ShockRing',,,owner.location,rot(0,0,16384));
	//S3.Lifespan = 2.5;

    sphere = Spawn(class'TMTSphere',,, owner.location);
    sphere.size = shoutRadius;

}

function DoShoutThing(ScriptedPawn Target){
    Target.DropWeapon();
    setAlliance(Target, 1);
    if(!isTaunt(Target)) AppendTaunt(Target);
    target.GotoState('Standing');
    WorldMutator().createBark(DeusExPlayer(Owner), target, "Don't shoot!", 2.0);
}

function Shout(ScriptedPawn Target){
    if(target.bIsHuman && isHostile(Target)){
        DoShoutThing(Target);
    }
    target.LookAtActor(Owner, true, true, true);
}

function ExecShout(){
    local ScriptedPawn ps;

    local DeusExPlayer  player;
    local scriptedpawn  hitpawn;
    local Actor         hitActor;
    local Vector        hitLocation, hitNormal, position, line;
    local float         dist;
    local int i;

    player         = DeusExPlayer(Owner);
    // Tracing and finding target
    position       = player.Location;
    position.Z     += player.BaseEyeHeight;
    line           = Vector(player.ViewRotation) * 4000;
    hitActor       = Trace(hitLocation, hitNormal, position+line, position, true);
    hitpawn        = ScriptedPawn(hitactor);

    player.ClientMessage("Checking target.");
    if(hitpawn != None && isTaunt(hitpawn)){
        player.ClientMessage("Starting conversation....");
        player.flagBase.setBool('target_shouted', True, True);
        //player.StartConversationByName(Name(hitpawn.BindName$"gunpoint"), hitpawn);
        hitpawn.Frob(Player, Player.InHand);
        player.StartConversation(hitpawn, IM_Frob);
        return;
    }
    player.ClientMessage("Target passed, moving to standard shout.");
    if(cooldown > 0.0) return;
    cooldown = cooldowntime;
    ExploFX();
    WorldMutator().createBark(DeusExPlayer(Owner), owner, "Hands up!", 2.0);
    foreach RadiusActors(class'ScriptedPawn', ps, shoutRadius){
        Shout(ps);
    }
}

function Altfire(float v){
    ExecShout();
}

defaultproperties
{
    shoutRadius=512
    tauntTimeout=2.0
    cooldownTime=10
}