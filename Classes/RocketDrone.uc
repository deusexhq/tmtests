class RocketDrone extends DeusExProjectile;

var float time;
var float dist;
var Rotator dir;
var vector TargetLocation;
var rotator TargetDir;
var rotator RandomAdd;
var rotator HeightAdjAdd;
var rotator Rand;
var() float proxRadius; 
var() bool bfalloff; 
var() float certainity;
var float certainity2;
var() float drunkness; 
var() float sharpness; 
var() float heightAdj; 
var() float tickTime; 
var() float minMass; 
var rotator RotationOld;
var Pawn P;
var Pawn Itarget; 
var pawn Ignorer;

function PostBeginPlay(){
	TargetLocation = Location; 
	bRotateToDesired = True;
	DesiredRotation = Rotation;
}

simulated function Tick(float deltaTime){
	if (time >= tickTime){
		time = 0;
		DoGuidance();
	}
	else
		time += deltaTime;
}

function DoGuidance(){
	if (Itarget != None){
		TargetLocation = Itarget.Location;
		dist = Vsize(TargetLocation - Location);
		if ((bfalloff) && (proxRadius != 0))
			certainity2 = ((proxRadius-dist) * certainity ) / proxRadius;
		else
			certainity2 = certainity;
	}
	else
		certainity2 = 0;
	Rand = Rotator(Vrand());
	TargetDir = Rotator(TargetLocation - Location);
	RandomAdd = (TargetDir-Rotation)*certainity2+Rand*(1-certainity2)*drunkness;
	HeightAdjAdd = Rotation*heightAdj + RandomAdd * sharpness * (1-heightAdj);
	RotationOld = Rotation; 
	DesiredRotation = RotationOld + RandomAdd*sharpness;

	velocity = Vector(Rotation) * Speed;
}

defaultproperties
{
     proxRadius=800.000000
     certainity=1.000000
     drunkness=0.100000
     sharpness=1.000000
     tickTime=0.100000
     minMass=40.000000
     bExplodes=True
     bBlood=True
     bDebris=True
     blastRadius=128.000000
     DamageType=exploded
     AccurateRange=14400
     maxRange=24000
     ItemName="Drone Rocket"
     ItemArticle="a"
     speed=400.000000
     MaxSpeed=1500.000000
     Damage=500.000000
     MomentumTransfer=10000
     SpawnSound=Sound'DeusExSounds.Weapons.GEPGunFire'
     ImpactSound=Sound'DeusExSounds.Generic.SmallExplosion1'
     Mesh=LodMesh'DeusExItems.Rocket'
     DrawScale=1.00000
     SoundRadius=16
     SoundVolume=196
     AmbientSound=Sound'DeusExSounds.Special.RocketLoop'
     RotationRate=(Pitch=99999)
}
