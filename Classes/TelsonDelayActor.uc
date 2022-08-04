class TelsonDelayActor extends Actor;

var() int hitDamage;
var() Pawn TargetPawn;
var() DeusExPlayer myOwner;

function Timer(){
    if(TargetPawn == None || TargetPawn.health <= 0){
        Destroy();
        return;
    }

    TargetPawn.TakeDamage(hitDamage,myOwner,vect(0,0,0),vect(0,0,1),'Special');	
    Destroy();
}

defaultproperties
{
    bHidden=True
}