class TMHUD expands DeusExHUD;

var IronSightView ironSight;
var TMTPlayer tmtp;

event InitWindow()
{
	local DeusExRootWindow root;
	local DeusExPlayer player;

	Super.InitWindow();

	// Get a pointer to the root window
	root = DeusExRootWindow(GetRootWindow());

	// Get a pointer to the player
	player = DeusExPlayer(root.parentPawn);
	tmtp = TMTPlayer(player);
	
	SetFont(Font'TechMedium');
	SetSensitivity(false);

	ironSight = IronSightView(NewChild(Class'IronSightView', False));
    ironSight.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);
	bTickEnabled = True;
}

event DescendantRemoved(Window descendant)
{
	if (descendant == ironSight)
		ironSight = None;
	else
		Super.DescendantRemoved(descendant);
}

defaultproperties
{

}
