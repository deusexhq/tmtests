class Strike extends DeusExPickup;

/*
Var for wether to use homing drone
Var for wether to allow targetting NPC's
Allow for targetting terrain
Add ground shake for player when rocket hits if within a var range
Sound effects for when drone fires

 */
var() int maxRange, Ammo, maxAmmo;
var() Marker MyMarker; 
var() float CountdownToFire, FiresIn;
var() bool bCanTargetTerrain, bCanTargetNPC;
var bool bWaitingToFire;
var Pawn Target;

function Tick(float deltatime){
    super.Tick(deltatime);
    if(DeusExPlayer(Owner) != None && bWaitingToFire) {
        CountdownToFire -= deltatime;
        if (CountdownToFire < 0.0){
            bWaitingToFire = False;
            FireOnTarget();
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
    if(MyMarker != None) {
        if(bWaitingToFire) Canvas.DrawText("        > LAUNCHING IN "$CountdownToFire$"_");
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

        if(bWaitingToFire){
            player.ClientMessage("|P2System busy.");
            GotoState('DeActivated');
            return;   
        }

        if(Ammo == 0) {
            player.ClientMessage("|P2Strike bay is out of missiles.");
            GotoState('DeActivated');
            return;
        }

        if(MyMarker == None){
            player.ClientMessage("Scanning for available strike markers...");
            foreach AllActors(class'Marker', mc){
                player.ClientMessage("Connection established.");
                MyMarker = mc;
            }
        }

        if(MyMarker == None){
            player.ClientMessage("|P2No marker in range. Strike unavailable.");
            GotoState('DeActivated');
            return;
        }

        if(hitpawn != None && dist < maxRange && bCanTargetNPC){
            Target = hitpawn;
            player.ClientMessage("Target found. Preparing.");
            CountdownToFire = FiresIn;
            bWaitingToFire = True;
		}
          
        // De-activate self so we can be re-used infinitely
		GotoState('DeActivated');
	}
Begin:
}

function FireOnTarget(){
    local rotator            launchRot;
    local DeusExProjectile   rd;

    DeusExPlayer(Owner).ClientMessage("Launched missile.");

    launchRot = Rotator(Target.Location - MyMarker.Location);  
    rd = Spawn(MyMarker.StrikeProjectileClass, DeusExPlayer(Owner),,MyMarker.Location,launchRot);

    if(rd.isA('RocketDrone')) RocketDrone(rd).Itarget = Target;
    
    Ammo -= 1;
}

defaultproperties
{
     bCanTargetNPC=True
     bCanTargetTerrain=True
     maxAmmo=1000
     Ammo=1000
     maxRange=1024
     FiresIn=15.0
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
