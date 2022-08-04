class DroneExt extends SpyDrone;
// Base for custom drone classes.
var bool bSpawnObjectOnDestroy;
var class<Actor> DeathSpawnClass;

function DeactivateAug(){
    local AugDrone anAug;

    anAug = AugDrone(DeusExPlayer(Owner).AugmentationSystem.FindAugmentation(class'AugDrone'));	
    if (anAug != None) anAug.Deactivate();

}

function OnRightClick(){}

function OnClick(){
    DeusExPlayer(Owner).ClientMessage("Using base DroneExt click.");
    DeactivateAug();
    Destroy();
}

function Destroyed(){
    local Actor a;

	if ( TMTPlayer(Owner) != None )
		TMTPlayer(Owner).bCustomDroneActive = False;

	Super.Destroyed();

    if(TMTPlayer(Owner) != None && bSpawnObjectOnDestroy){
        a = Spawn(DeathSpawnClass,,,Location);
    }
}

function Tick(float deltaTime){
	DeusExPlayer(Owner).Energy = DeusExPlayer(Owner).EnergyMax;
}

function BeginPlay(){
	//bSpawnObjectOnDestroy = True;
    //DeathSpawnClass = class'Rocket';
}

defaultproperties
{
}
