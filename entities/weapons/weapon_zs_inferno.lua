AddCSLuaFile()

SWEP.PrintName = "'Inferno' AUG"
SWEP.Description = "A very accurate assault rifle with great damage output and a high clip size."

SWEP.Slot = 2
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	SWEP.HUD3DBone = "v_weapon.aug_Parent"
	SWEP.HUD3DPos = Vector(-1, -2.5, -3)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_aug.mdl"
SWEP.WorldModel = "models/weapons/w_rif_aug.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_AUG.Single")
SWEP.Primary.Damage = 23
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.095

SWEP.Primary.ClipSize = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 4
SWEP.ConeMin = 1

SWEP.WalkSpeed = SPEED_SLOW

SWEP.Tier = 4
SWEP.MaxStock = 3

SWEP.IronSightsAng = Vector(-1, -1, 0)
SWEP.IronSightsPos = Vector(-3, 4, 3)

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, "'Firestorm' Incendiary Rifle", "Fires incendiary assault rifle rounds, but reduced damage", function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.85

	function wept.BulletCallback(attacker, tr)
		local hitent = tr.Entity
		if hitent:IsValidLivingZombie() and math.random(6) == 1 then
			local burnstatus = hitent:GiveStatus("burn", 10)
			if burnstatus and burnstatus:IsValid() then
				burnstatus.Applier = attacker
				burnstatus.Damage = 200
			end
		end
	end
end)

function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

function SWEP:OnZombieKilled(zombie)
	local killer = self:GetOwner()

	if killer:IsValid() and zombie:WasHitInHead() then
		killer.RenegadeHeadshots = (killer.RenegadeHeadshots or 0) + 1

		if killer.RenegadeHeadshots >= 3 then
			killer:GiveStatus("renegade", 6)
			killer.RenegadeHeadshots = 0
		end
	end
end

if CLIENT then
	SWEP.IronsightsMultiplier = 0.25

	function SWEP:GetViewModelPosition(pos, ang)
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			return pos + ang:Up() * 256, ang
		end

		return --BaseClass.GetViewModelPosition(self, pos, ang) -- No idea what that did to fix it, but hey it works now
	end

	function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			self:DrawRegularScope()
		end
	end
end
