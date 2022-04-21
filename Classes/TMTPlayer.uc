class TMTPlayer extends JCDentonMale;

var bool bAlreadyJumped, IsMantling, bDisableFallDamage;
var int MantleVelocity, WallJumpCheck, FallDamageReduction;
var float WallJumpVelocity, DoubleJumpMultiplier, WallJumpZVelocity;
var TMHUD extHUD;
var name Ability1Name, Ability2Name;

var() bool bCanUseHijack, bCanUseStrike, bCanUseBullettime, bCanUseHeartscan;

// Hijack
var bool bJacked, bSwitchedAlliance;
var JCDouble hijackHost;
var ScriptedPawn jackedPawn;
var() int hijackDistLimit;
var() float hijackTimeLimit, hijackCooldown;
var float jackTime;
var int curDist;
var float hijackcooldowntime;

// Strike
var() int strikeDistLimit;
var() Marker strikeMarker; 
var() float CountdownToFireStrike, StrikeFiresIn;
var() bool bStrikeCanTargetTerrain, bStrikeCanTargetNPC;
var bool bWaitingToFireStrike;
var ScriptedPawn StrikeTarget;
var Vector StrikeTargetLocation;

// Bullettime
var bool bBulletTimeOn;
var() float BulletTimeSpeed;

// Heartscan
var() int heartscanMaxDist;
var float HeartscanDelay, CurrentHeartscanTime;
var bool bHeartScanning;
var ScriptedPawn HeartscanTarget;

// Summon Bot
var Marker2 botSpawnMarker;

function MultiplayerTick(float deltatime){
	local scriptedpawn  hitpawn;
	local Actor         hitActor;
	local Vector        hitLocation, hitNormal, position, line;
	local float         dist;
	local rotator       playerRot;

	if(bHeartScanning){
		position       = Location;
		position.Z     += BaseEyeHeight;
		line           = Vector(ViewRotation) * 4000;
		hitActor       = Trace(hitLocation, hitNormal, position+line, position, true);
		dist           = Abs(VSize(HitLocation - Location));
		hitPawn 	   = ScriptedPawn(HitActor);
		if(hitPawn == None || hitPawn != HeartscanTarget || dist > heartscanMaxDist) {
			ClientMessage("Target lost.");
			bHeartScanning = False;
		} else {
			CurrentHeartscanTime -= deltatime;
			if(CurrentHeartscanTime < 0.0){
				ClientMessage("Scan complete.");
				AddNote("=== SCAN RESULT (Heartscan V1) ===|nName: "$HeartscanTarget.FamiliarName);
				bHeartScanning = False;
				HeartscanTarget = None;
			}
		}
	}

	if(hijackcooldowntime > 0.0) hijackcooldowntime -= deltatime;

	if(bJacked) {
		jackTime += deltatime;
		if (jackTime >= hijackTimeLimit) Hijack();

		curDist = Abs(VSize(jackedPawn.Location - Location));
		if(curDist > hijackDistLimit) Hijack();
	}
	
	if(bWaitingToFireStrike) {
		CountdownToFireStrike -= deltatime;
		if (CountdownToFireStrike < 0.0){
			bWaitingToFireStrike = False;

			if(StrikeTarget != None) StrikeFireOnTarget();
			else StrikeFireOnLoc();
		}
		
	}
	super.Tick(deltatime);
	super.MultiplayerTick(deltatime);
}

event Possess(){
    local DeusExRootWindow w;

    Super.Possess();

    w = DeusExRootWindow(RootWindow);
   	if (w != None)
	{
	    if (w.hud != None){
			w.hud.Destroy();
		}
		w.hud = TMHUD(w.NewChild(Class'TMHUD'));
		//extHUD = w.hud;
		w.hud.UpdateSettings(self);
		w.hud.SetWindowAlignments(HALIGN_Full,VALIGN_Full,0.00,0.00);
		
	}

}

function ExecAbility(name AbilityName){
	ClientMessage("Executing"@abilityName);
	if(AbilityName == 'hijack'){
		Hijack();
	}
	if(AbilityName == 'strike'){
		Strike();
	}
	if(AbilityName == 'bullettime'){
		Bullettime();
	}
	if(AbilityName == 'pulse'){
		//Call Pulse
	}
	if(AbilityName == 'bot'){
		SummonBot();
	}
	if(AbilityName == 'heartscan'){
		Heartscan();
	}
}

function SetAbilityName(int slot, name newAbilityName){
	if(slot == 1) Ability1Name = newAbilityName;
	if(slot == 2) Ability2Name = newAbilityName;
}
//
// Commands
//

exec function SummonBot(){
	local Marker2 mc;

	if(botSpawnMarker == None){
		ClientMessage("Scanning for available markers...");
		foreach AllActors(class'Marker2', mc){
			ClientMessage("Connection established.");
			botSpawnMarker = mc;
		}
	}

	if(botSpawnMarker == None){
		ClientMessage("|P2No marker in range. Summon unavailable.");
		return;
	}

	botSpawnMarker.DoSpawn();
}

exec function Heartscan(){
	local Actor         hitActor;
	local Vector        hitLocation, hitNormal, position, line;
	local float         dist;

	position       = Location;
	position.Z     += BaseEyeHeight;
	line           = Vector(ViewRotation) * 4000;
	hitActor       = Trace(hitLocation, hitNormal, position+line, position, true);
	dist           = Abs(VSize(HitLocation - Location));
	

	if(!bHeartScanning && dist < heartscanMaxDist){
		HeartscanTarget= ScriptedPawn(hitactor);
		CurrentHeartscanTime = HeartscanDelay;
		bHeartScanning = True;
		ClientMessage("Scanning target....");
	} else ClientMessage("No target found.");

}

exec function Bullettime(){
	if(bBulletTimeOn){
		Level.Game.SetGameSpeed(1);
		Level.Game.SaveConfig(); 
		bBulletTimeOn = False;
	} else {
		Level.Game.SetGameSpeed(BulletTimeSpeed);
		Level.Game.SaveConfig(); 
		bBulletTimeOn = True;
	}
}

exec function Hijack(){
	local MutTM tm;
	local scriptedpawn  hitpawn;
	local Actor         hitActor;
	local Vector        hitLocation, hitNormal, position, line;
	local float         dist;
	local rotator       playerRot;

	if(hijackcooldowntime > 0.0) {
		ClientMessage("|P2System on cooldown.");
		return;
	}

	tm = WorldMutator();

	if(bJacked){
		// Effects
		SetInHand(None);
		ClientFlash(2, vect(0,255,0));
		//player.Sprite = None;
		//player.ConsoleCommand("RMODE 5");
		jackedPawn.bHidden = False;

		// Copy player's skin back to the jacked pawn
		tm.grabSkin(self, jackedPawn);
		// Copy host skin back to the player
		tm.grabSkin(hijackHost, self);

		// Move the players inventory back to the jacked pawn
		tm.grabInventory(self, jackedPawn);

		// Move the hosts inventory back to the player
		tm.grabInventory(hijackHost, self);
		
		jackedPawn.SetLocation(Location);
		SetLocation(hijackHost.location);
		
		// Cleanup
		bJacked = False;
		jackedPawn.SetPhysics(PHYS_Falling);
		jackedPawn.SetCollision(True, True, True);
		jackedPawn = None;
		hijackHost.destroy();

		hijackcooldowntime = hijackCooldown;
		if(bSwitchedAlliance) {
			bSwitchedAlliance = False;
			tm.switchGlobalAlliances();
		}
	} else {
		// Tracing and finding target
		position       = Location;
		position.Z     += BaseEyeHeight;
		line           = Vector(ViewRotation) * 4000;
		hitActor       = Trace(hitLocation, hitNormal, position+line, position, true);
		dist           = Abs(VSize(HitLocation - Location));
		hitpawn        = ScriptedPawn(hitactor);

		// Pawn found and within range
		if(hitpawn != None && dist < hijackDistLimit && !hitpawn.isA('Animal') && !hitpawn.isA('Robot')) {
				// Effects and generic setup
				ClientFlash(2, vect(0,255,0));
				SetInHand(None);
				//player.Sprite=Texture(DynamicLoadObject("Extras.Matrix_A00",class'Texture'));
				//player.ConsoleCommand("RMODE 6");
				jackedPawn = hitpawn;
				bJacked = True;
				jackTime = 0.0;

				

				// Spawning a host to store player data
				// Turning off player collision here so an NPC can spawn on them
				SetCollision(False, False, False);
				playerRot = ViewRotation;
				playerRot.pitch = 0;
				hijackHost = Spawn(class'JCDouble', self, 'Jacker', Location, playerRot);
				hijackHost.orders = 'standing';
				SetLocation(hitpawn.location);
				SetRotation(hitpawn.ViewRotation);
				SetCollision(True, True, True);
				

				// Storing player skin on the host
				tm.grabSkin(self, hijackHost);
				// Copying target skin to the player
				tm.grabSkin(hitpawn, self);

				// Moving players inventory to the host for storage
				tm.grabInventory(self, hijackHost);
				// Moving targets inventory to player for usage
				tm.grabInventory(hitpawn, self);

				// Hiding the real target from the world
				hitpawn.SetPhysics(PHYS_None);
				hitPawn.SetCollision(False, False, False);
				hitpawn.bHidden = True;

				// If enemy is a hostile, switch everyones alliances
				if(tm.isHostile(hitpawn)){
					tm.switchGlobalAlliances();
					bSwitchedAlliance = True; 
				}
			}
		}
}

exec function Strike(){
	local scriptedpawn  hitpawn;
	local Actor         hitActor;
	local Vector        hitLocation, hitNormal, position, line;
	local float         dist;
	local marker        mc;

	position       = Location;
	position.Z     += BaseEyeHeight;
	line           = Vector(ViewRotation) * 4000;
	hitActor       = Trace(hitLocation, hitNormal, position+line, position, true);
	dist           = Abs(VSize(HitLocation - Location));
	hitpawn        = ScriptedPawn(hitactor);

	if(bWaitingToFireStrike){
		ClientMessage("|P2System busy.");
		return;   
	}

	if(strikeMarker == None){
		ClientMessage("Scanning for available strike markers...");
		foreach AllActors(class'Marker', mc){
			ClientMessage("Connection established.");
			strikeMarker = mc;
		}
	}

	if(strikeMarker == None){
		ClientMessage("|P2No marker in range. Strike unavailable.");
		return;
	}

	if(strikeMarker.MyAmmo == 0) {
		ClientMessage("|P2Strike bay is out of missiles.");
		return;
	}

	if(hitpawn == None && dist < strikeDistLimit && bStrikeCanTargetTerrain){
		striketargetLocation = hitLocation;
		CountdownToFireStrike = StrikeFiresIn;
		bWaitingToFireStrike = True;
	}
	
	if(hitpawn != None && dist < strikeDistLimit && bStrikeCanTargetNPC){
		StrikeTarget = hitpawn;
		ClientMessage("Target found. Preparing.");
		CountdownToFireStrike = StrikeFiresIn;
		bWaitingToFireStrike = True;
	}
}

exec function AbilityName1(name abilityName){ Ability1Name = abilityName; }
exec function AbilityName2(name abilityName){ Ability2Name = abilityName; }
exec function Ability1(){ ExecAbility(Ability1Name); }
exec function Ability2(){ ExecAbility(Ability2Name); }

exec function pp(){	ClientMessage(DeusExWeapon(inHand).PlayerViewOffset); }
exec function px(float x){DeusExWeapon(inHand).PlayerViewOffset.X=x; }
exec function py(float y){ DeusExWeapon(inHand).PlayerViewOffset.Y=y; }
exec function pz(float z){ DeusExWeapon(inHand).PlayerViewOffset.Z=z; }

exec function tmt(){ ClientMessage("Test!");}
exec function msgr(string text){ ShowMessage(text); }
exec function bark(string text){ CreateBark(self, text, 5.0); }

exec function toggleironsights(){
	local TMTWeapon T;
	if(InHand.IsA('TMTWeapon')){
		T = TMTWeapon(InHand);
		T.ToggleIronSights();
	}
}
exec function ironsightsoff(){
	local TMTWeapon T;
	if(InHand.IsA('TMTWeapon')){
		T = TMTWeapon(InHand);
		T.IronSightsOff();
	}
}

exec function ironsightson(){
	local TMTWeapon T;
	if(InHand.IsA('TMTWeapon')){
		T = TMTWeapon(InHand);
		T.IronSightsOn();
	}
}

exec function shout(){
	local TMTWeapon T;
	if(InHand.IsA('TMTWeapon')){
		T = TMTWeapon(InHand);
		T.ExecShout();
	}
}

exec function takedown(){
	local TMTWeapon T;
	if(InHand.IsA('TMTWeapon')){
		T = TMTWeapon(InHand);
		T.Takedown();
	}
}

exec function giveorder(){
	local TMTWeapon T;
	if(InHand.IsA('TMTWeapon')){
		T = TMTWeapon(InHand);
		T.OrderTarget();
	}
}

// 
// Custom
//

simulated function ShowMessage(string Message){
    local HUDMissionStartTextDisplay    HUD;

    if ((RootWindow != None) && (DeusExRootWindow(RootWindow).HUD != None)) {
        HUD = DeusExRootWindow(RootWindow).HUD.startDisplay;
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

simulated final function createBark(Actor BotSender, string msg, float Delay){
	local DeusExRootWindow _root;

	_root = DeusExRootWindow(rootWindow);
	if(_root != None){
		_root.hud.barkdisplay.addBark(msg, Delay, BotSender);
	}

}


//
// Overrides
//

function DoJump( optional float F ){
	local DeusExWeapon w;
	local float scaleFactor, augLevel;
	local vector loc, line, HitLocation, hitNormal;
	local Vector DVector;

	if ( (CarriedDecoration != None) && (CarriedDecoration.Mass > 20) )
		return;
	else if ( bForceDuck || IsLeaning() )
		return;

	if ( Physics == PHYS_Walking ){
		if ( Role == ROLE_Authority )
			PlaySound(JumpSound, SLOT_None, 1.5, true, 1200, 1.0 - 0.05*FRand() );
		if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
			MakeNoise(0.1 * Level.Game.Difficulty);
		PlayInAir();

		Velocity.Z = JumpZ;
					
		if ( Base != Level )
			Velocity.Z += Base.Velocity.Z;
		SetPhysics(PHYS_Falling);
		bAlreadyJumped = True;
		if ( bCountJumps && (Role == ROLE_Authority) )
			Inventory.OwnerJumped();
	}

	else if ( (Physics == PHYS_Falling) && (bAlreadyJumped))
	{
        loc = Location;
        loc.Z += BaseEyeHeight;
        line = Vector(ViewRotation) * 90000;

        Trace(hitLocation, hitNormal, loc+line, loc, true);
        if(Abs(VSize(HitLocation - Location)) < WallJumpCheck)
        {
            Velocity = (normal(Location - HitLocation) * WallJumpVelocity);
            Velocity.Z = WallJumpZVelocity;
            SetPhysics(Phys_Falling);
            //bAlreadyJumped = False;
            if ( bCountJumps && (Role == ROLE_Authority) )
                Inventory.OwnerJumped();
            if ( Role == ROLE_Authority )
                PlaySound(JumpSound, SLOT_None, 1.5, true, 1200, 1.0 - 0.05*FRand() );
            if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
                MakeNoise(0.1 * Level.Game.Difficulty);
            PlayInAir();

            return;
        }
	
		bAlreadyJumped = False;
		
		if ( Role == ROLE_Authority )
			PlaySound(JumpSound, SLOT_None, 1.5, true, 1200, 1.0 - 0.05*FRand() );
		if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
			MakeNoise(0.1 * Level.Game.Difficulty);
		PlayInAir();

		Velocity.Z = JumpZ * DoubleJumpMultiplier;	
		SetPhysics(PHYS_Falling);
		if ( bCountJumps && (Role == ROLE_Authority) )
			Inventory.OwnerJumped();
	}
}

function float GetCurrentGroundSpeed(){
	local float speed;

	speed = super.GetCurrentGroundSpeed();
	if(TMTWeapon(inHand) != None && TMTWeapon(inHand).bIronSightsOn){
		speed /= 5;
	}
	return speed;
}

state PlayerWalking
{
	function ProcessMove ( float DeltaTime, vector newAccel, eDodgeDir DodgeMove, rotator DeltaRot)	{
		local actor HitActor;
		local vector HitLocation, HitNormal, checkpoint, start, checkNorm, Extent;
		local Vector loc;
        local rotator vr;

		super.ProcessMove(DeltaTime, newAccel, DodgeMove, DeltaRot);
		
		//Kaiser: Mantling system.
		if (Physics == PHYS_Falling && velocity.Z != 0)	{
            if (CarriedDecoration == None){
				checkpoint = vector(Rotation);
				checkpoint.Z = 0.0;
				checkNorm = Normal(checkpoint);
				checkPoint = Location + CollisionRadius * checkNorm;
				Extent = CollisionRadius * vect(0.2,0.2,0);
				Extent.Z = CollisionHeight;
				HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, True, Extent);
				if ( (HitActor != None) && (Pawn(HitActor) == None) && (HitActor == Level || HitActor.bCollideActors) && !HitActor.IsA('DeusExCarcass')){
					WallNormal = -1 * HitNormal;
					start = Location;
					start.Z += 1.1 * MaxStepHeight + CollisionHeight;
					checkPoint = start + 2 * CollisionRadius * checkNorm;
					HitActor = Trace(HitLocation, HitNormal, checkpoint, start, true, Extent);
					if (HitActor == None){
						if(!isMantling)	{
							isMantling = True;
							setPhysics(PHYS_Falling);
							Velocity.Z = MantleVelocity;
							Acceleration = vect(0,0,0);
							PlaySound(sound'MaleLand', SLOT_None, 1.5, true, 1200, (1.0 + 0.2*FRand()) * 1.0 );
							Acceleration = wallNormal * AccelRate / 8;
						}
					}
				}
			}
		}
	}
}

function Landed(vector HitNormal){
    local vector legLocation;
	local int augLevel;
	local float augReduce, dmg;

	PlayLanded(Velocity.Z);
	isMantling=False;
	if (Velocity.Z < -1.4 * JumpZ)	{
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)) * runSilentValue);
		if ((Velocity.Z < -700) && (ReducedDamageType != 'All'))
			if ( Role == ROLE_Authority ) {
				augReduce = 0;
				if (AugmentationSystem != None)	{
					augLevel = AugmentationSystem.GetClassLevel(class'AugSpeed');
					if (augLevel >= 0)
						augReduce = 15 * (augLevel+1);
				}

				if(drugEffectTimer < 0) 
					augReduce += 10;

				dmg = Max((-0.16 * (Velocity.Z + 700)) - augReduce, 0);
				if(FallDamageReduction > 0)
					dmg = dmg / FallDamageReduction;
				legLocation = Location + vect(-1,0,-1);
				if(dmg > 0 && !bDisableFallDamage) //Kaiz0r - Adding code for disabling fall damage
					TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');

				legLocation = Location + vect(1,0,-1);			// damage right leg
				if(dmg > 0 && !bDisableFallDamage)
					TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');

				dmg = Max((-0.06 * (Velocity.Z + 700)) - augReduce, 0);
				legLocation = Location + vect(0,0,1);			// damage torso
				if(dmg > 0 && !bDisableFallDamage)
					TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');
            }
	}
	else if ( (Level.Game != None) && (Level.Game.Difficulty > 1) && (Velocity.Z > 0.5 * JumpZ) )
		MakeNoise(0.1 * Level.Game.Difficulty * runSilentValue);
	bJustLanded = true;
}

function MutTM WorldMutator(){
    local MutTM M;
    foreach AllActors(class'MutTM', M) return M;
    return Spawn(class'MutTM');
}

function StrikeFireOnLoc(){
    local rotator            launchRot;
    local DeusExProjectile   rd;

    ClientMessage("Launched missile.");

    launchRot = Rotator(StrikeTargetLocation - strikeMarker.Location);  
    rd = Spawn(strikeMarker.StrikeProjectileClass, self,,strikeMarker.Location,launchRot);
    
    strikeMarker.MyAmmo -= 1;
}

function StrikeFireOnTarget(){
    local rotator            launchRot;
    local DeusExProjectile   rd;

    ClientMessage("Launched missile.");

    launchRot = Rotator(StrikeTarget.Location - strikeMarker.Location);  
    rd = Spawn(strikeMarker.StrikeProjectileClass, self,,strikeMarker.Location,launchRot);

    if(rd.isA('RocketDrone')) RocketDrone(rd).Itarget = StrikeTarget;
    
    strikeMarker.MyAmmo -= 1;
}

defaultproperties
{
	heartscanMaxDist=1024
	HeartscanDelay=10.0
	bCanUseHijack=True
	bCanUseStrike=True
	bCanUseBullettime=True
	bCanUseHeartscan=True
	BulletTimeSpeed=0.2
	strikeDistLimit=1024
	StrikeFiresIn=15.0
	bStrikeCanTargetNPC=True
	bStrikeCanTargetTerrain=True
	hijackCooldown=15.0
    hijackDistLimit=1024
    hijackTimeLimit=60.0
    MantleVelocity=600
    WallJumpVelocity=512.000000
    DoubleJumpMultiplier=1.200000
    WallJumpZVelocity=712.000000
    WallJumpCheck=55
}