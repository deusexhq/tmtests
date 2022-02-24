class Hijack extends DeusExPickup;
var bool bJacked, bSwitchedAlliance;
var JCDouble host;
var ScriptedPawn jackedPawn;
var() int distLimit;
var() float timeLimit, cooldown;
var float jackTime; //time that we've been jacked
var int curDist;
var float cooldowntime;

simulated function RenderOverlays(canvas Canvas){
	local DeusExPlayer P;
     local float Scale;

	Super.RenderOverlays(Canvas);
	P = DeusExPlayer(Owner);

     //bOwnsCrossHair = True; 
     Scale = Canvas.ClipX/640;
     Canvas.SetPos(0.5 * Canvas.ClipX - 16 * Scale, 0.5 * Canvas.ClipY - 16 * Scale );
     Canvas.DrawColor.R = 200;
     Canvas.DrawColor.G = 200;
     Canvas.DrawColor.B = 200;
     Canvas.Font = Canvas.SmallFont;

     if(bJacked) Canvas.DrawText("        > TIME REMAINING "$timeLimit-jackTime$"_");
     if(cooldowntime > 0.0) Canvas.DrawText("        > SYSTEM LOCKED FOR "$cooldowntime$"_");

     Canvas.SetPos(0.5 * Canvas.ClipX - 16 * Scale, 0.5 * Canvas.ClipY - 16 * Scale + 20 );
     if(bJacked) Canvas.DrawText("        > INFO "$jackedPawn.FamiliarName$" ("$curDist$")_");
}

function DropFrom(vector StartLocation){
	if(bJacked) { GotoState('Activated'); StartLocation = host.location; }
     super.DropFrom(StartLocation);
}

function BecomePickup(){
	super.BecomePickup();
}

function BecomeItem(){
	super.BecomeItem();
}

simulated function PreBeginPlay(){
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
		MaxCopies = 1;
}

function Tick(float deltatime){
     super.Tick(deltatime);
     if(cooldowntime > 0.0) cooldowntime -= deltatime;

     if(DeusExPlayer(Owner) != None && bJacked) {
          jackTime += deltatime;
          if (jackTime >= timeLimit) GotoState('Activated');

          curDist = Abs(VSize(jackedPawn.Location - Owner.Location));
          if(curDist > distLimit) GotoState('Activated');
     }
}

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
     local Hijack t;

     for (item=Source.Inventory; item!=None; item=Source.Inventory){
          log(item);
          if(item.isA('Hijack')) t = Hijack(item);
          Source.DeleteInventory(item);
          Target.AddInventory(item);
     }
     if(t != None) {
          Target.DeleteInventory(t);
          Source.AddInventory(t);
     }
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
          local rotator       playerRot;

		Super.BeginState();
		player = DeusExPlayer(Owner);

          if(cooldowntime > 0.0) {
               player.ClientMessage("|P2System on cooldown.");
               GotoState('DeActivated');
               return;
          }

		if (player != None) {
               if(bJacked){
                    // Effects
                    player.ClientFlash(2, vect(0,255,0));
                    //player.Sprite = None;
                    //player.ConsoleCommand("RMODE 5");
                    jackedPawn.bHidden = False;

                    // Copy player's skin back to the jacked pawn
                    grabSkin(player, jackedPawn);
                    // Copy host skin back to the player
                    grabSkin(host, player);

                    // Move the players inventory back to the jacked pawn
                    grabInventory(player, jackedPawn);

                    // Move the hosts inventory back to the player
                    grabInventory(host, player);
                    
                    jackedPawn.SetLocation(player.Location);
                    player.SetLocation(host.location);
                    
                    // Cleanup
                    bJacked = False;
                    jackedPawn.SetPhysics(PHYS_Falling);
                    jackedPawn.SetCollision(True, True, True);
                    jackedPawn = None;
                    host.destroy();

                    cooldowntime = cooldown;
                    if(bSwitchedAlliance) {
                         bSwitchedAlliance = False;
                         switchGlobalAlliances();
                    }
               } else {
                    // Tracing and finding target
                    position       = player.Location;
                    position.Z     += player.BaseEyeHeight;
                    line           = Vector(player.ViewRotation) * 4000;
                    hitActor       = Trace(hitLocation, hitNormal, position+line, position, true);
                    dist           = Abs(VSize(HitLocation - player.Location));
                    hitpawn        = ScriptedPawn(hitactor);

                    // Pawn found and within range
			     if(hitpawn != None && dist < distLimit && !hitpawn.isA('Animal') && !hitpawn.isA('Robot')) {
                         // Effects and generic setup
                         player.ClientFlash(2, vect(0,255,0));
                         //player.Sprite=Texture(DynamicLoadObject("Extras.Matrix_A00",class'Texture'));
                         //player.ConsoleCommand("RMODE 6");
                         jackedPawn = hitpawn;
                         bJacked = True;
                         jackTime = 0.0;

                         

                         // Spawning a host to store player data
                         // Turning off player collision here so an NPC can spawn on them
                         player.SetCollision(False, False, False);
                         playerRot = Player.ViewRotation;
                         playerRot.pitch = 0;
                         host = Spawn(class'JCDouble', player, 'Jacker', Player.Location, playerRot);
                         host.orders = 'standing';
                         player.SetLocation(hitpawn.location);
                         player.SetCollision(True, True, True);
                         

                         // Storing player skin on the host
                         grabSkin(player, host);
                         // Copying target skin to the player
                         grabSkin(hitpawn, player);

                         // Moving players inventory to the host for storage
                         grabInventory(player, host);
                         // Moving targets inventory to player for usage
                         grabInventory(hitpawn, player);

                         // Hiding the real target from the world
                         hitpawn.SetPhysics(PHYS_None);
                         hitPawn.SetCollision(False, False, False);
                         hitpawn.bHidden = True;

                         // Unequip the hijack tool for aesthetics
                         player.SetInHand(None);

                         // If enemy is a hostile, switch everyones alliances
                         if(isHostile(hitpawn)){
                              switchGlobalAlliances();
                              bSwitchedAlliance = True; 
                         }
                    }
               }

		}
          
          // De-activate self so we can be re-used infinitely
		GotoState('DeActivated');
	}
Begin:
}

defaultproperties
{
     cooldown=15.0
     distLimit=1024
     timeLimit=60.0
     bBreakable=False
     maxCopies=1
     bActivatable=True
     ItemName="Hijack"
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
     beltDescription="JACK"
     Mesh=LodMesh'DeusExItems.Multitool'
     SoundVolume=64
     CollisionRadius=4.800000
     CollisionHeight=0.860000
     Mass=10.000000
     Buoyancy=8.000000
}
