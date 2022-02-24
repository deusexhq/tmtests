class TMTPlayer extends JCDentonMale;

var bool bAlreadyJumped, IsMantling, bDisableFallDamage;
var int MantleVelocity, WallJumpCheck, FallDamageReduction;
var float WallJumpVelocity, DoubleJumpMultiplier, WallJumpZVelocity;

//
// Commands
//

exec function tmt(){
    ClientMessage("Test!");
}

exec function msgr(string text){
	ShowMessage(text);
}

exec function bark(string text){
	CreateBark(self, text, 5.0);
}

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

defaultproperties
{
    MantleVelocity=600
    WallJumpVelocity=512.000000
    DoubleJumpMultiplier=1.200000
    WallJumpZVelocity=712.000000
    WallJumpCheck=55
}