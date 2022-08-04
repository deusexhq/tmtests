//=============================================================================
// WeaponMiniCrossbow.
//=============================================================================
class TMTWeaponGrapple extends TMTWeapon;

var int GrappleVelocity;

function GiveTo( pawn Other ){
    super.Giveto(Other);
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		HitDamage = mpHitDamage;
		BaseAccuracy = mpBaseAccuracy;
		ReloadTime = mpReloadTime;
		AccurateRange = mpAccurateRange;
		MaxRange = mpMaxRange;
		ReloadCount = mpReloadCount;
      PickupAmmoCount = mpReloadCount;
	}
}


function LaserToggle(){
	GrappleVelocity += 500;
	OwnerMsg("Set: "@GrappleVelocity);

}

function ScopeToggle(){
	GrappleVelocity -= 500;
	OwnerMsg("Set: "@GrappleVelocity);
}

function OwnerMsg(string str){
	DeusExPlayer(Owner).ClientMessage(str,'TeamSay');
}

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return ( (BeltSpot >= 1) && (BeltSpot <=9) );
}

defaultproperties
{
     GrappleVelocity=1500
     LowAmmoWaterMark=4
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     NoiseLevel=0.050000
     EnemyEffective=ENMEFF_Organic
     Concealability=CONC_All
     ShotTime=0.800000
     reloadTime=2.000000
     HitDamage=25
     maxRange=1600
     AccurateRange=800
     BaseAccuracy=0.800000
     bCanHaveScope=True
     ScopeFOV=15
     bCanHaveLaser=True
     bHasSilencer=True
     StunDuration=10.000000
     bHasMuzzleFlash=False
     mpReloadTime=0.500000
     mpHitDamage=30
     mpBaseAccuracy=0.100000
     mpAccurateRange=2000
     mpMaxRange=2000
	 PickupAmmoCount=1
	 ReloadCount=1
     bCanHaveModBaseAccuracy=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     FireOffset=(X=-25.000000,Y=8.000000,Z=14.000000)
     ProjectileClass=Class'GrappleDart'
     shakemag=30.000000
     FireSound=Sound'DeusExSounds.Weapons.MiniCrossbowFire'
     AltFireSound=Sound'DeusExSounds.Weapons.MiniCrossbowReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.MiniCrossbowReload'
     SelectSound=Sound'DeusExSounds.Weapons.MiniCrossbowSelect'
     InventoryGroup=25390
     ItemName="Grapple Crossbow"
	 AmmoName=Class'AmmoGrapple'
     PlayerViewOffset=(X=25.000000,Y=-8.000000,Z=-14.000000)
     PlayerViewMesh=LodMesh'DeusExItems.MiniCrossbow'
     PickupViewMesh=LodMesh'DeusExItems.MiniCrossbowPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.MiniCrossbow3rd'
     Icon=Texture'DeusExUI.Icons.BeltIconCrossbow'
     largeIcon=Texture'DeusExUI.Icons.LargeIconCrossbow'
     largeIconWidth=47
     largeIconHeight=46
     Description="The mini-crossbow was specifically developed for espionage work, and accepts a range of dart types (normal, tranquilizer, or flare) that can be changed depending upon the mission requirements."
     beltDescription="GRAP"
     Mesh=LodMesh'DeusExItems.MiniCrossbowPickup'
     CollisionRadius=8.000000
     CollisionHeight=1.000000
     Mass=15.000000
}
