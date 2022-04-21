//=============================================================================
// DeusExScopeView.
//=============================================================================
class IronSightView expands Window;

#exec TEXTURE IMPORT NAME="isightglock" FILE="Textures\pistol_sight.bmp" GROUP="Skins" FLAGS=2
#exec TEXTURE IMPORT NAME="isightglock2" FILE="Textures\pistol_sight2.pcx" GROUP="Skins" FLAGS=2

var bool bActive;
var DeusExPlayer player;
var Color colLines;
var Bool  bViewVisible;
var int   desiredFOV;

event InitWindow(){
	Super.InitWindow();
	player = DeusExPlayer(GetRootWindow().parentPawn);
	bTickEnabled = true;
	StyleChanged();
}

event StyleChanged(){
	local ColorTheme theme;
	theme = player.ThemeManager.GetCurrentHUDColorTheme();
	colLines = theme.GetColorFromName('HUDColor_HeaderText');
}

event Tick(float deltaSeconds){
	local Crosshair        cross;
	local DeusExRootWindow dxRoot;

	dxRoot = DeusExRootWindow(GetRootWindow());
	if (dxRoot != None)	{
		cross = dxRoot.hud.cross;

		if (bActive)
			cross.SetCrosshair(false);
		else
			cross.SetCrosshair(player.bCrosshairVisible);
	}
}

function ActivateView(int newFOV, bool bNewBinocs, bool bInstant){
	desiredFOV = newFOV;

	if (player != None)
	{
		if (bInstant)
			player.SetFOVAngle(desiredFOV);
		else
			player.desiredFOV = desiredFOV;

		bViewVisible = True;
		Show();
	}
}

function DeactivateView(){
	if (player != None)	{
		Player.DesiredFOV = Player.Default.DefaultFOV;
		bViewVisible = False;
		Hide();
	}
}

function HideView(){
	if (bViewVisible)	{
		Hide();
		Player.SetFOVAngle(Player.Default.DefaultFOV);
	}
}

function ShowView(){
	if (bViewVisible)	{
		Player.SetFOVAngle(desiredFOV);
		Show();
	}
}


event DrawWindow(GC gc){
	local float			fromX, toX;
	local float			fromY, toY;
	local float			scopeWidth, scopeHeight;

	Super.DrawWindow(gc);

	if (GetRootWindow().parentPawn != None)	{
		if (player.IsInState('Dying'))
			return;
	}

	scopeWidth  = 256;
	scopeHeight = 256;

	fromX = (width-scopeWidth)/2;
	fromY = (height-scopeHeight)/2;
	toX   = fromX + scopeWidth;
	toY   = fromY + scopeHeight;

	//gc.SetTileColorRGB(0, 0, 0);
	//gc.SetStyle(DSTY_Normal);
	/*if ( Player.Level.NetMode == NM_Standalone ){
		gc.DrawPattern(0, 0, width, fromY, 0, 0, Texture'Solid');
		gc.DrawPattern(0, toY, width, fromY, 0, 0, Texture'Solid');
		gc.DrawPattern(0, fromY, fromX, scopeHeight, 0, 0, Texture'Solid');
		gc.Dra*wPattern(toX, fromY, fromX, scopeHeight, 0, 0, Texture'Solid');
	}*/

	gc.SetStyle(DSTY_Normal);
	gc.DrawTexture(fromX, fromY+200, scopeWidth, scopeHeight, 0.0, 0.0, Texture'isightglock2');
}

defaultproperties
{
}
