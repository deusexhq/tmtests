class Strike extends DeusExPickup;

/*
Var for wether to use homing drone
Var for wether to allow targetting NPC's
Allow for targetting terrain
Add ground shake for player when rocket hits if within a var range
Sound effects for when drone fires

 */

var() int strikeDistLimit, Ammo, maxAmmo;
var() Marker strikeMarker; 
var() float CountdownToFireStrike, StrikeFiresIn;
var() bool bStrikeCanTargetTerrain, bStrikeCanTargetNPC;
var bool bWaitingToFireStrike;
var Pawn StrikeTarget;
var Vector StrikeTargetLocation;

function Tick(float deltatime){
    super.Tick(deltatime);
    if(DeusExPlayer(Owner) != None && bWaitingToFireStrike) {
        CountdownToFireStrike -= deltatime;
        if (CountdownToFireStrike < 0.0){
            bWaitingToFireStrike = False;

            if(StrikeTarget != None) FireOnTarget();
            else FireOnLoc();
        }
    }
}

simulated function RenderOverlays(canvas Canvas){
	local DeusExPlayer  P;
    local float         Scale;

	Super.RenderOverlays(Canvas);
	P = DeusExPlayer(Owner);

    Scale = Canvas.ClipX/640;
    Canvas.SetPos(0.5 * Canvas.ClipX - 16 * Scale, 0.5 * Canvas.ClipY - 16 * Scale );
    Canvas.DrawColor.R = 200;
    Canvas.DrawColor.G = 200;
    Canvas.DrawColor.B = 200;
    Canvas.Font = Canvas.SmallFont;

    Canvas.DrawText("        > AMMO "$Ammo$"_");

    Canvas.SetPos(0.5 * Canvas.ClipX - 16 * Scale, 0.5 * Canvas.ClipY - 16 * Scale + 20 );
    if(strikeMarker != None) {
        if(bWaitingToFireStrike) Canvas.DrawText("        > LAUNCHING IN "$CountdownToFireStrike$"_");
        else Canvas.DrawText("        > CONNECTED // READY_");
    } else Canvas.DrawText("        > NO CONNECTION, TRY AGAIN_");
}

simulated function PreBeginPlay(){
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_StandAlone )
		MaxCopies = 1;
}


state Activated
{
	function Activate()	{}
	function BeginState() {
		local DeusExPlayer  player;
		local scriptedpawn  hitpawn;
		local Actor         hitActor;
		local Vector        hitLocation, hitNormal, position, line;
		local float         dist;
        local marker        mc;

		Super.BeginState();
        player = DeusExPlayer(Owner);

        position       = player.Location;
        position.Z     += player.BaseEyeHeight;
        line           = Vector(player.ViewRotation) * 4000;
        hitActor       = Trace(hitLocation, hitNormal, position+line, position, true);
        dist           = Abs(VSize(HitLocation - player.Location));
        hitpawn        = ScriptedPawn(hitactor);

        if(bWaitingToFireStrike){
            player.ClientMessage("|P2System busy.");
            GotoState('DeActivated');
            return;   
        }

        if(strikeMarker == None){
            player.ClientMessage("Scanning for available strike markers...");
            foreach AllActors(class'Marker', mc){
                player.ClientMessage("Connection established.");
                strikeMarker = mc;
            }
        }

        if(strikeMarker == None){
            player.ClientMessage("|P2No marker in range. Strike unavailable.");
            GotoState('DeActivated');
            return;
        }

        if(strikeMarker.Ammo == 0) {
            player.ClientMessage("|P2Strike bay is out of missiles.");
            GotoState('DeActivated');
            return;
        }

        if(hitpawn == None && dist < strikeDistLimit && bStrikeCanTargetTerrain){
            striketargetLocation = hitLocation;
            CountdownToFireStrike = StrikeFiresIn;
            bWaitingToFireStrike = True;
        }
        if(hitpawn != None && dist < strikeDistLimit && bStrikeCanTargetNPC){
            StrikeTarget = hitpawn;
            player.ClientMessage("Target found. Preparing.");
            CountdownToFireStrike = StrikeFiresIn;
            bWaitingToFireStrike = True;
		}
          
        // De-activate self so we can be re-used infinitely
		GotoState('DeActivated');
	}
Begin:
}

function FireOnLoc(){
    local rotator            launchRot;
    local DeusExProjectile   rd;

    DeusExPlayer(Owner).ClientMessage("Launched missile.");

    launchRot = Rotator(StrikeTargetLocation - strikeMarker.Location);  
    rd = Spawn(strikeMarker.StrikeProjectileClass, DeusExPlayer(Owner),,strikeMarker.Location,launchRot);
    
    strikeMarker.Ammo -= 1;
}

function FireOnTarget(){
    local rotator            launchRot;
    local DeusExProjectile   rd;

    DeusExPlayer(Owner).ClientMessage("Launched missile.");

    launchRot = Rotator(StrikeTarget.Location - strikeMarker.Location);  
    rd = Spawn(strikeMarker.StrikeProjectileClass, DeusExPlayer(Owner),,strikeMarker.Location,launchRot);

    if(rd.isA('RocketDrone')) RocketDrone(rd).Itarget = StrikeTarget;
    
    strikeMarker.Ammo -= 1;
}

defaultproperties
{
     strikeDistLimit=1024
     StrikeFiresIn=15.0
     bStrikeCanTargetNPC=True
     bStrikeCanTargetTerrain=True
     maxAmmo=1000
     Ammo=1000
     bBreakable=False
     maxCopies=1
     bActivatable=True
     ItemName="Airstrike"
     PlayerViewOffset=(X=20.000000,Y=10.000000,Z=-16.000000)
     PlayerViewMesh=LodMesh'DeusExItems.MultitoolPOV'
     PickupViewMesh=LodMesh'DeusExItems.Multitool'
     ThirdPersonMesh=LodMesh'DeusExItems.Multitool3rd'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconMultitool'
     largeIcon=Texture'DeusExUI.Icons.LargeIconMultitool'
     largeIconWidth=28
     largeIconHeight=46
     M_Activated=""
     Description=" "
     beltDescription="STRIKE"
     Mesh=LodMesh'DeusExItems.Multitool'
     SoundVolume=64
     CollisionRadius=4.800000
     CollisionHeight=0.860000
     Mass=10.000000
     Buoyancy=8.000000
}
