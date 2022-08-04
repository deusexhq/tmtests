class GyroDrone extends DroneExt;
var() int ActiveFunction, Darts, Rockets;
var Vector TargetLocation;

function FireProjectile(class<DeusExProjectile> Proj){
    local Rotator testRot;

    testRot = rotator(TargetLocation - Location);
    Spawn(Proj,Pawn(Owner),,Location + (CollisionRadius+Default.CollisionRadius+5) * Vector(Rotation) + vect(0,0,1) * 2,testRot);
}

function DoFunction(){
	local Vector        hitLocation, hitNormal, position, line;

    line           = Vector(Rotation) * 4000;
    Trace(hitLocation, hitNormal, Location+line, Location, true);
    TargetLocation = HitLocation;
	switch (ActiveFunction)
	{
		case 0:	
            FireProjectile(class'Dart');
            break;

		case 1:	
            FireProjectile(class'Rocket');
            break;

		case 2:	
            DeusExPlayer(Owner).ClientMessage("Turret unavailable.");
            break;

        case 3:
            DeactivateAug();
            break;

        case 4:
            DeusExPlayer(Owner).DroneExplode();
            break;
	}
}

function CycleFunction(){
    ActiveFunction++;
    if(ActiveFunction >= 5) ActiveFunction = 0;

	switch (ActiveFunction)
	{
		case 0:	
            DeusExPlayer(Owner).ClientMessage("Darts ready.");
            break;

		case 1:	
            DeusExPlayer(Owner).ClientMessage("Rockets ready.");
            break;

		case 2:	
            DeusExPlayer(Owner).ClientMessage("Turret function ready.");
            break;

        case 3:
            DeusExPlayer(Owner).ClientMessage("Deactivation function ready.");
            break;

        case 4:
            DeusExPlayer(Owner).ClientMessage("Self-destruct function ready.");
            break;
	}
}

function OnRightClick(){
    CycleFunction();
}

function OnClick(){
    DoFunction();
}

defaultproperties
{
    ActiveFunction=3
    Darts=30
    Rockets=5
    blastRadius=128.000000
    DamageType=Exploded
    Damage=100
}
