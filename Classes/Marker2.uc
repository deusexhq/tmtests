class Marker2 extends Actor;

var() class<ScriptedPawn> SpawnBotClass;

function DoSpawn(){
    local BotSpawnCrate bsc;
    local Vector Loc;

    loc = Location;
    loc.Z -= class'BotSpawnCrate'.Default.CollisionHeight;

    bsc = Spawn(class'BotSpawnCrate',,, loc);
    bsc.SpawnBotClass = SpawnBotClass;

}

defaultproperties
{
    SpawnBotClass=class'SecurityBot2'
}