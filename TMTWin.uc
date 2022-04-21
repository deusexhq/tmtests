class TMTWin expands ToolWindow;

var ToolListWindow		lstOpts;
var ToolButtonWindow	btnTest, btnOpen;    
var string selected;

event InitWindow()
{
	Super.InitWindow();
	SetSize(370, 430);
	SetTitle("Ability Selection");

	CreateControls();
	PopulateList();

}

// ----------------------------------------------------------------------
// DestroyWindow()
// ----------------------------------------------------------------------

event DestroyWindow(){}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls(){
	CreateOptsList();
    btnOpen  = CreateToolButton(280, 65, "Open");
	btnTest  = CreateToolButton(280, 362, "Close");
}

function CreateOptsList()
{
	lstOpts = CreateToolList(15, 38, 255, 372);
	lstOpts.EnableMultiSelect(False);
	lstOpts.EnableAutoExpandColumns(True);
	lstOpts.SetColumns(2);
	lstOpts.HideColumn(1);
}

function PopulateList()
{
	lstOpts.DeleteAllRows();

	lstOpts.AddRow("Hijack");
    lstOpts.AddRow("Strike");
	lstOpts.Sort();

	EnableButtons();
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;

	bHandled = True;

	switch( buttonPressed )
	{
        case btnOpen:
            log(selected);
            break;

		case btnTest:
			Log("Tested!");
            root.PopWindow();
			break;

		default:
			bHandled = False;
			break;
	}

	if ( !bHandled ) 
		bHandled = Super.ButtonActivated( buttonPressed );

	return bHandled;
}

event bool ListSelectionChanged(window list, int numSelections, int focusRowId)
{
	Log(focusRowId, 'TMT');
    Log(lstOpts.GetField(focusRowId, 0), 'TMT');
    selected = lstOpts.GetField(focusRowId, 0);
	return true;
}

event bool ListRowActivated(window list, int rowId)
{
	Log(rowID, 'TMT2');
    Log(lstOpts.GetField(rowID, 0), 'TMT2');
    selected = lstOpts.GetField(rowID, 0);
	return true;
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local bool retval;

	retval = Super.VirtualKeyPressed(key, bRepeat);

	switch (key)
	{
		case IK_Enter:
            ButtonActivated(btnOpen);
			retval = true;
			break;


	}

	return (retval);

}

function EnableButtons()
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
