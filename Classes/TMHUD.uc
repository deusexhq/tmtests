class TMHUD expands DeusExHUD;

var TextWindow wintm;
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

	wintm = TextWindow(NewChild(Class'TextWindow'));
	wintm.SetWindowAlignments(HALIGN_Right,VALIGN_Center,,128);
	wintm.SetFont(Font'TechMedium');
	wintm.Show(True);

	bTickEnabled = True;
}

event DescendantRemoved(Window descendant)
{
	if (descendant == wintm)
		wintm = None;
	else
		Super.DescendantRemoved(descendant);
}

function tick(float deltaTime)
{
	local DeusExRootWindow root;
	local string str;
	
	root = DeusExRootWindow(GetRootWindow());
	str = "";
	if(wintm != None && tmtp != None){
		if(tmtp.hijackcooldowntime > 0)
			str = str@"HJCK="$tmtp.hijackcooldowntime;
		if(tmtp.CountdownToFireStrike > 0)
			str = str@"STRK="$tmtp.CountdownToFireStrike;
		if(tmtp.bHeartScanning)
			str = str@"SCAN="$tmtp.CurrentHeartscanTime;
		if(tmtp.bJacked){
			str = str@"CONTROL="$tmtp.jackedPawn.FamiliarName;
			str = str@"DIST="$tmtp.curDist$"/"$tmtp.hijackDistLimit;
			str = str@"TIME="$tmtp.hijackTimeLimit-tmtp.jackTime;
		}

		wintm.SetText(str);
	}
}

defaultproperties
{

}
