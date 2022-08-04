//=============================================================================
// WeaponStealthPistol.
//=============================================================================
class Telson extends DeusExWeapon;

var() int TimeToKill;

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z){

	local ScriptedPawn Target;
        local TelsonDelayActor tda;

	if(Other.isa('ScriptedPawn')){
                Target = ScriptedPawn(Other);
		tda = Spawn(class'TelsonDelayActor');
                tda.hitDamage = HitDamage;
                tda.TargetPawn = Target;
                tda.SetTimer(TimeToKill, False);
                DeusExPlayer(Owner).ClientMessage("Target "$Target.FamiliarName$" tagged...");
	}

        return;
}

simulated function float CalculateAccuracy()
{
	return 0.000000; //Dirty hack to always return dead on accuracy.
}

function ScopeToggle()
{
}

function LaserToggle()
{
}

defaultproperties
{
     TimeToKill=5
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     AmmoName=Class'AmmoSting'
     AmmoNames(0)=Class'AmmoSting'
     NoiseLevel=0.010000
     ShotTime=0.150000
     reloadTime=1.500000
     HitDamage=400
     maxRange=4800
     AccurateRange=2400
     BaseAccuracy=0.800000
     bCanHaveScope=True
     ScopeFOV=25
     bCanHaveLaser=True
     recoilStrength=0.100000
     mpBaseAccuracy=0.200000
     mpAccurateRange=1200
     mpMaxRange=1200
     bHasSilencer=True
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     bInstantHit=True
     ReloadCount=10
     PickupAmmoCount=10
     FireOffset=(X=-24.000000,Y=10.000000,Z=14.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.StealthPistolFire'
     AltFireSound=Sound'DeusExSounds.Weapons.StealthPistolReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.StealthPistolReload'
     SelectSound=Sound'DeusExSounds.Weapons.StealthPistolSelect'
     InventoryGroup=6899
     ItemName="Scorpion Stinger (Telson)"
     PlayerViewOffset=(X=24.000000,Y=-10.000000,Z=-14.000000)
     PlayerViewMesh=LodMesh'DeusExItems.StealthPistol'
     PickupViewMesh=LodMesh'DeusExItems.StealthPistolPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.StealthPistol3rd'
     Icon=Texture'DeusExUI.Icons.BeltIconStealthPistol'
     largeIcon=Texture'DeusExUI.Icons.LargeIconStealthPistol'
     largeIconWidth=47
     largeIconHeight=37
     Description="The stealth pistol is a variant of the standard 10mm pistol with a larger clip and integrated silencer designed for wet work at very close ranges."
     beltDescription="TELSON"
     Mesh=LodMesh'DeusExItems.StealthPistolPickup'
     CollisionRadius=8.000000
     CollisionHeight=0.800000
}
