class TMTWinAbilitySelect expands MenuUIScreenWindow;

 
var MenuUIActionButtonWindow 	btnSelect1, btnSelect2;
var MenuUILabelWindow			rangeDisplay;
var TMTPlayer tPlayer;

event InitWindow(){
	local window w;

	Super.InitWindow();
	SetSize(400, 250);
	SetTitle("Ability Select");

	tPlayer = TMTPlayer(GetRootWindow().parentPawn);
	StyleChanged();
		
	winClient.SetBackground(Texture'DeusExUI.MaskTexture');
	winClient.SetBackgroundStyle(DSTY_Modulated);

	W = winClient.NewChild(Class'Window');
	W.SetSize(ClientWidth, ClientHeight);
	W.SetBackground(Texture'DeusExUI.MaskTexture');
	W.SetBackgroundStyle(DSTY_Modulated);
	W.Lower();
	
	CreateAbilityButtons();
	//Show();
}

event DestroyWindow(){
	super.DestroyWindow();
	//Log("Hijack dist "$inputDistLimit.GetText());
}

function CreateAbilityButtons(){
    //btnBack  = CreateToolButton(20, 65, "Open");
	btnUpgradeRange = MenuUIActionButtonWindow(winClient.NewChild(Class'MenuUIActionButtonWindow'));
	btnUpgradeRange.SetButtonText("+ Range");
	btnUpgradeRange.SetPos(130, 40);
	btnUpgradeRange.SetWidth(100);

	btnDowngradeRange = MenuUIActionButtonWindow(winClient.NewChild(Class'MenuUIActionButtonWindow'));
	btnDowngradeRange.SetButtonText("- Range");
	btnDowngradeRange.SetPos(20, 40);
	btnDowngradeRange.SetWidth(100);

	rangeDisplay = CreateMenuLabel(240, 40, "R "$TMTPlayer(player).hijackDistLimit, winClient);
	Show();	
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;

	bHandled = True;

	switch( buttonPressed )
	{
		case btnUpgradeRange:
			break;
			
		default:
			bHandled = False;
			break;
	}

	if ( !bHandled ) 
		bHandled = Super.ButtonActivated( buttonPressed );

	return bHandled;
}


function EnableButtons()
{
}

defaultproperties
{
     ClientWidth=400
     ClientHeight=250
     textureRows=3
     textureCols=2
}
