class Marker extends Actor;
var() class<DeusExProjectile> StrikeProjectileClass;
var() int MyAmmo, MaxAmmo;

defaultproperties
{
    MyAmmo=10
    MaxAmmo=10
    StrikeProjectileClass=class'RocketDrone'
    bHidden=False
}