//=============================================================================
// AmmoCrate
//=============================================================================
class TMT extends Containers;

/*function Restock(DeusExPlayer Player){
   if (Player != None){
      CurInventory = Player.Inventory;
      while (CurInventory != None){
         //if (CurInventory.IsA('Hijack'))
            //Hijack(CurInventory).Upgrade();
         CurInventory = CurInventory.Inventory;
      }
   }
}
*/

function Frob(Actor Frobber, Inventory frobWith){
	local DeusExPlayer Player;

   local DeusExRootWindow root;
   local TMTWinHijack mWin;

	Player = DeusExPlayer(Frobber);
   Player.InitRootWindow();
   root = DeusExRootWindow(Player.rootWindow);
   if (root != None) {
      //mWin = TMTWin(root.InvokeUIScreen(Class'TMTWin', True));
      if(Player.InHand.isA('Hijack')){
         mWin = TMTWinHijack(root.InvokeUIScreen(Class'TMTWinHijack', True));
         //mWin.current = Hijack(Player.InHand);
         mWin.createControls();
      }

   }


}

defaultproperties
{
     HitPoints=4000
     bFlammable=False
     ItemName="TMT Station"
     bPushable=False
     bBlockSight=True
     Mesh=LodMesh'DeusExItems.DXMPAmmobox'
     bAlwaysRelevant=True
     CollisionRadius=22.500000
     CollisionHeight=16.000000
     Mass=3000.000000
     Buoyancy=40.000000
}
