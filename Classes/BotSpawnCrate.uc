//=============================================================================
// CrateUnbreakableLarge.
//=============================================================================
class BotSpawnCrate extends Containers;

var() class<ScriptedPawn> SpawnBotClass;

function Destroyed(){
    local ScriptedPawn MyBot;
    local Vector Loc;
    local int i;

    loc = Location;
    loc.Z += SpawnBotClass.Default.CollisionHeight;

    MyBot = Spawn(SpawnBotClass,,, loc);
    if (MyBot != None)    {
            for (i=0; i<8; i++){
                if (MyBot.InitialAlliances[i].AllianceName == 'player'||MyBot.InitialAlliances[i].AllianceName == 'Player'){
                    MyBot.InitialAlliances[i].AllianceLevel = 1;
            }
        }
    }

	Super.Destroyed();
}

defaultproperties
{
     bInvincible=False
     HitPoints=5
     bFlammable=False
     ItemName="Metal Crate"
     bBlockSight=True
     Mesh=LodMesh'DeusExDeco.CrateUnbreakableLarge'
     CollisionRadius=56.500000
     CollisionHeight=56.000000
     Mass=150.000000
     Buoyancy=160.000000
}
