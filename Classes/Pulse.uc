class Pulse extends DeusExPickup;

var() int maxRange;
var() float cooldown, cooldowntime;

function Tick(float deltatime){
    super.Tick(deltatime);
    if(cooldown > 0.0) {
        cooldown -= deltatime;
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

     if(cooldown > 0.0)
          Canvas.DrawText("        > "$cooldown$"_");
     else
          Canvas.DrawText("        > READY_");
}

simulated function PreBeginPlay(){
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_StandAlone )
		MaxCopies = 1;
}

function Pulsar(){
     local Keypad hd; 
     local Lamp l; 
     local SecurityCamera sc;
     local Autoturret at; 
     local Robot bot; 
     local DeusExMover mv, m;
     local DeusExPlayer player;

     player = DeusExPlayer(owner);

     ExploFX();
     
     foreach player.RadiusActors(class'Keypad', hd, maxRange){
          hd.ToggleLocks(Player);
          hd.RunEvents(Player,True);
          hd.RunUntriggers(Player);
     }

     foreach player.RadiusActors(class'Lamp', l, maxRange){
          if (l.bOn) {
               l.bOn = False;
               l.LightType = LT_None;
               l.bUnlit = False;
               l.ResetScaleGlow();
          }
     }

     foreach player.RadiusActors(class'SecurityCamera', sc, maxRange){
          sc.UnTrigger(Player, Player);
     }

     foreach player.RadiusActors(class'Autoturret', at, maxRange){
          sc.UnTrigger(Player, Player);
     }

     foreach player.RadiusActors(class'Robot', bot, maxRange){
          bot.TakeDamageBase(1000, Player, bot.location, player.location, 'EMP', true);
     }

     foreach player.RadiusActors(class'DeusExMover', mv, maxRange){
          if(mv.KeyIDNeeded != ''){
               mv.bLocked = False;
               mv.TimeSinceReset = 0;
               mv.doOpen();
               if ((mv.Tag != '') && (mv.Tag != 'DeusExMover')){
                    foreach AllActors(class'DeusExMover', M, mv.Tag){
                         if (M != Self) {
                              M.bLocked = False;
                              M.TimeSinceReset = 0;
                              M.doOpen();
                         }
                    }
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
    sphere.size = maxRange;

}


state Activated
{
	function Activate()	{}
	function BeginState() {
		local DeusExPlayer  player;

		Super.BeginState();
          player = DeusExPlayer(Owner);

          if(cooldown <= 0.0){
               Pulsar();
               cooldown = cooldowntime;
          }
          
          // De-activate self so we can be re-used infinitely
		GotoState('DeActivated');
	}
Begin:
}


defaultproperties
{
     maxRange=2048
     cooldowntime=15.0
     bBreakable=False
     maxCopies=1
     bActivatable=True
     ItemName="EMP Pulse"
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
     beltDescription="EMP"
     Mesh=LodMesh'DeusExItems.Multitool'
     SoundVolume=64
     CollisionRadius=4.800000
     CollisionHeight=0.860000
     Mass=10.000000
     Buoyancy=8.000000
}
