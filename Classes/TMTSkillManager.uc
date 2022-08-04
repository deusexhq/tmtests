//=============================================================================
// SkillManager
//=============================================================================
class TMTSkillManager extends SkillManager;

function AddSkillClass(Class aNewSkill)
{
    local skill toAdd;
    toAdd = GetSkillFromClass(aNewSkill);
	if (toAdd.IncLevel())
		Player.ClientMessage(Sprintf(YourSkillLevelAt, toAdd.SkillName, toAdd.CurrentLevel));
}

function AddSkillSilent(Skill aNewSkill)
{
	aNewSkill.IncLevel();
}

function ResetSingle(Class mySkill)
{
	local Skill aSkill;

	aSkill = FirstSkill;
	while(aSkill != None)
	{
		if(aSkill.class == mySkill) aSkill.CurrentLevel = aSkill.Default.CurrentLevel;
		aSkill = aSkill.next;
	}
}

defaultproperties
{
     skillClasses(0)=Class'DeusEx.SkillWeaponHeavy'
     skillClasses(1)=Class'DeusEx.SkillWeaponPistol'
     skillClasses(2)=Class'DeusEx.SkillWeaponRifle'
     skillClasses(3)=Class'DeusEx.SkillWeaponLowTech'
     skillClasses(4)=Class'DeusEx.SkillDemolition'
     skillClasses(5)=Class'DeusEx.SkillEnviro'
     skillClasses(6)=Class'DeusEx.SkillLockpicking'
     skillClasses(7)=Class'DeusEx.SkillTech'
     skillClasses(8)=Class'DeusEx.SkillMedicine'
     skillClasses(9)=Class'DeusEx.SkillComputer'
     skillClasses(10)=Class'DeusEx.SkillSwimming'
     NoToolMessage="You need the %s"
     NoSkillMessage="%s skill level insufficient to use the %s"
     SuccessMessage="Success!"
     YourSkillLevelAt="Your skill level at %s is now %d"
     bHidden=True
     bTravel=True
}
