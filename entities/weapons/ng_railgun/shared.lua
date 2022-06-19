if(SERVER) then
	AddCSLuaFile("shared.lua")
 
	SWEP.Weight = 5

	Pews = 0
	
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
elseif(CLIENT) then
	SWEP.PrintName = "f(r)agger"

	SWEP.Slot = 1
	SWEP.SlotPos = 1
	
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Purpose = "Obliterates faggots."
SWEP.Instructions = "pow pow"

SWEP.Category = "narugibs"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/c_superphyscannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"
SWEP.HoldType = "physgun"

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.UseHands = true

local powSound = Sound("weapons/ar2/npc_ar2_altfire.wav") 
local denySound = Sound("friends/message.wav")

function SWEP:Initialize()
	self.cantDash = 0
	self:SetHoldType("physgun")
end

function SWEP:Reload()
end

function SWEP:Think()
	if(self.Owner:OnGround()) then
		self.Owner.floorDashed = false
	end
end

function SWEP:PrimaryAttack()
	if(!self.Owner.lastShoot) then self.Owner.lastShoot = 0 end

	if(CurTime() - self.Owner.lastShoot >= 0.25) then
		local bullet = {}
		bullet.Src 	= self.Owner:GetShootPos()
		bullet.Dir 	= self.Owner:GetAimVector()
		bullet.Tracer	= 1
		bullet.TracerName = "ToolTracer"
		bullet.Spread 	= Vector(0, 0, 0)
		bullet.Num 	= 1
		bullet.Force	= 9999
		bullet.Damage	= 10000
		
		self.Owner.lastShoot = CurTime()
		self:EmitSound(powSound)
		self.Owner:FireBullets( bullet )
		self:ShootEffects()

		if(SERVER) then
			Pews = Pews + 1
		end
	end
end
 
function SWEP:SecondaryAttack()
	if(self.Owner:OnGround()) then
		self.Owner.floorDashed = false
	end

	if(!self.Owner:OnGround() && !self.Owner.floorDashed) then
		self.Owner:SetVelocity(self.Owner:EyeAngles():Forward() * 700)
		self.Owner:EmitSound("/vehicles/airboat/pontoon_impact_hard" .. math.random(1, 2) .. ".wav")
		self.Owner.floorDashed = true
	else
		if(CLIENT) then
			self.cantDash = self.cantDash + 1
			if(self.cantDash == 10) then
				self.Owner:EmitSound(denySound)
				notification.AddLegacy("To dash, you need to be mid air || not already be dashing.", NOTIFY_HINT, 5)
				self.cantDash = 0
			end
		end
	end
end

function SWEP:DrawHUD()
	if(!self.Owner.gameOver) then
		if(self.Owner.lastShoot) then
			local lastShootBar = math.Clamp(CurTime() - self.Owner.lastShoot, 0, 0.25) * 4
			local colourFade = lastShootBar * 100
	
			draw.RoundedBox(999, 16, ScrH() - 22, lastShootBar * ScrW() - 32, 16, Color(255, 0, 0, colourFade))
		end
	
		draw.RoundedBox(5, ScrW() * 0.0175, ScrH() * 0.9, ScrW() * 0.12, ScrH() * 0.075, Color(0, 0, 0, 150))
		draw.DrawText("FRAGS", "HUDFont", ScrW() * 0.0285, ScrH() * 0.94, Color(255, 220, 0, 255), TEXT_ALIGN_LEFT)
		draw.DrawText(LocalPlayer():Frags(), "numbersFont", ScrW() * 0.07635, ScrH() * 0.905, Color(255, 220, 0, 255), TEXT_ALIGN_LEFT)
	
		draw.RoundedBox(5, ScrW() * 0.15, ScrH() * 0.9, ScrW() * 0.12, ScrH() * 0.075, Color(0, 0, 0, 150))
		draw.DrawText("SPEED", "HUDFont", ScrW() * 0.1595, ScrH() * 0.94, Color(255, 220, 0, 255), TEXT_ALIGN_LEFT)
		draw.DrawText(math.Round(self.Owner:GetVelocity():Length()), "numbersFont", ScrW() * 0.225, ScrH() * 0.905, Color(255, 220, 0, 255), TEXT_ALIGN_CENTER)
	end
end