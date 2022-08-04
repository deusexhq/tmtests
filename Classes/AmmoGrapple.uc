class AmmoGrapple extends DeusExAmmo;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
      AmmoAmount = 1;
}

defaultproperties
{
     bShowInfo=False
     AmmoAmount=11
     MaxAmmo=1
     ItemName="Rope Dart"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.AmmoDart'
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoDartsNormal'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoDartsNormal'
     largeIconWidth=20
     largeIconHeight=47
     Description="The mini-crossbow dart is a favored weapon for many 'wet' operations; however, silent kills require a high degree of skill."
     beltDescription="ROPE"
     Mesh=LodMesh'DeusExItems.AmmoDart'
     CollisionRadius=8.500000
     CollisionHeight=2.000000
     bCollideActors=True
}
