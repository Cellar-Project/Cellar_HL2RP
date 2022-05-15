SWEP.Base = "arccw_base"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "CELLAR [DEV]" 
SWEP.AdminOnly = false

SWEP.PrintName = "OSPR Mk. 3"

SWEP.Slot = 2

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/schwarzkruppzo/c_ospr.mdl"
SWEP.WorldModel = "models/weapons/schwarzkruppzo/w_ospr.mdl"
SWEP.ViewModelFOV = 65

SWEP.Damage = 75
SWEP.DamageMin = 40
SWEP.BloodDamage = 500
SWEP.ShockDamage = 3000
SWEP.BleedChance = 100
SWEP.AmmoItem = "bullets_ar2"
SWEP.ImpulseSkill = true

SWEP.DefaultBodygroups = "000000"

SWEP.Range = 2000 -- in METRES
SWEP.Penetration = 30
SWEP.DamageType = DMG_BULLET
SWEP.ShootEntity = nil -- entity to fire, if any
SWEP.MuzzleVelocity = 900 -- projectile or phys bullet muzzle velocity
-- IN M/S

SWEP.ImpactEffect = "AR2Impact"
SWEP.Tracer = "AR2Tracer"
SWEP.TracerNum = 1 -- tracer every X
SWEP.TracerCol = Color(21, 37, 64)
SWEP.TracerWidth = 10

SWEP.ChamberSize = 0 -- how many rounds can be chambered.
SWEP.Primary.ClipSize = 30 -- DefaultClip is automatically set.
SWEP.ExtendedClipSize = 60
SWEP.ReducedClipSize = 15

SWEP.Recoil = 0.1
SWEP.RecoilSide = 0
SWEP.RecoilRise = 0.75
SWEP.VisualRecoilMult = 1
SWEP.RecoilPunch = 2

SWEP.RecoilDirection = Angle(1, 0, 0)
SWEP.RecoilDirectionSide = Angle(0, 1, 0)

SWEP.Delay = 60 / 600 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
	{
		Mode = 1,
	},
}

SWEP.NPCWeaponType = {"weapon_ar2", "weapon_smg1"}
SWEP.NPCWeight = 150

SWEP.AccuracyMOA = 0 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 512 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 2048

SWEP.Primary.Ammo = "AR2" -- what ammo type the gun uses

SWEP.ShootVol = 155 -- volume of shoot sound
SWEP.ShootPitch = 120 -- pitch of shoot sound

sound.Add({
    name = "OSPR.Single",
    channel = CHAN_WEAPON,
    volume = 1,
    level = 155,
    pitch = {85, 130},
    sound = "weapons/ospr/fire1.ogg"
})

SWEP.FirstShootSound = Sound("OSPR.Single")
SWEP.ShootSound = Sound("OSPR.Single")
SWEP.DistantShootSound = Sound("OSPR.Single")

SWEP.MuzzleEffect = "muzzleflash_ar2"
SWEP.ShellModel = "models/weapons/shell.mdl"
SWEP.ShellPitch = 95
SWEP.ShellScale = 1

SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.CaseEffectAttachment = 0 -- which attachment to put the case effect on

SWEP.SpeedMult = 0.96
SWEP.SightedSpeedMult = 0.70
SWEP.SightTime = 1

SWEP.BulletBones = { -- the bone that represents bullets in gun/mag
	-- [0] = "bulletchamber",
	-- [1] = "bullet1"
}

SWEP.ProceduralRegularFire = false
SWEP.ProceduralIronFire = false

SWEP.CaseBones = {}

SWEP.IronSightStruct = {
	Pos = Vector(-6, -10, 0.5),
	Ang = Angle(0, 0, 0),
	Magnification = 2,
	ScopeMagnification = 0,
	ScopeMagnificationMin = 0,
	ScopeMagnificationMax = 20,
	BlackBox = false,
	ScopeTexture = nil,
	SwitchToSound = "", -- sound that plays when switching to this sight
	SwitchFromSound = "",
	ScrollFunc = ArcCW.SCROLL_ZOOM,
	FlatScope = true,
	MagnifiedOptic = true,
	CrosshairInSights = false
}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "passive"
SWEP.HoldtypeSights = "passive"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(0, 0, 0)

SWEP.BarrelOffsetSighted = Vector(0, 0, -1)
SWEP.BarrelOffsetHip = Vector(2, 0, -2)

SWEP.BarrelLength = 27

SWEP.ExtraSightDist = 5

SWEP.Attachments = {}
SWEP.Animations = {
	["idle"] = {
		Source = "idle",
		Time = 5
	},
	["reload"] = {
		Source = "fire",
		Time = 1,
	},
	["draw"] = {
		Source = "draw",
		Time = 1,
	},
	["fire"] = {
		Source = "fire",
		Time = 1,
	},
	["enter_sprint"] = {
		Source = "sprint_in",
		Time = 0.7
	},
	["exit_sprint"] = {
		Source = "sprint_out",
		Time = 0.7
	},
	["idle_sprint"] = {
		Source = "sprint",
		Time = 0.7
	},
	["bash"] = {
		Source = "melee",
		Time = 1
	},
	
}
SWEP.OSPR = true

if CLIENT then
	local rt_Store		= render.GetScreenEffectTexture(0)
	local rt_Blur		= render.GetScreenEffectTexture(1)
	local wireframe = Material("models/wireframe")
	local debugwhite = Material("models/debug/debugwhite")
	local thermalrt = CreateMaterial("visorThermalRT", "UnlitGeneric", {
		["$basetexture"] = "_rt_FullFrameFB",
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$ignorez"] = 0,
		["$additive"] = 0,
	})
	local copy = Material("pp/copy")

	local function ArcCW_TranslateBindToEffect(bind)
	    local alt = GetConVar("arccw_altbindsonly"):GetBool()

	    return alt and ArcCW.BindToEffect_Unique[bind] or ArcCW.BindToEffect[bind] or bind
	end

	local function OSPR_PlayerBindPress(ply, bind, pressed)
		if not (ply:IsValid()) then return end

		local wep = ply:GetActiveWeapon()

		if not wep.ArcCW then return end
		if not wep.OSPR then return end
		
		local block = false

		bind = ArcCW_TranslateBindToEffect(bind)

		if wep:GetState() == ArcCW.STATE_SIGHTS then
			if bind == "zoomin" then
				wep:Scroll(1)
				return true
			elseif bind == "zoomout" then
				wep:Scroll(-1)
				return true
			end
		end
	end

	hook.Add("PlayerBindPress", "OSPR_PlayerBindPress", OSPR_PlayerBindPress)

	function SWEP:PostDrawViewModel()
		render.SetBlend(1)

		if ArcCW.Overdraw then
			ArcCW.Overdraw = false
		else
			self:DoScope()
		end
	end

	local scope_bg = Material("ospr/scope_bg")
	local scope_bg_overlay = Material("ospr/scope_bg_overlay")

	if IsValid(visor_ui_model) then
		visor_ui_model:Remove()
		visor_ui_model = nil
	end

	visor_ui_model = ClientsideModel("models/sniper_ui.mdl", RENDERGROUP_OPAQUE)
	visor_ui_model:SetNoDraw(true)
	visor_ui_model:SetMaterial("debug/debugwhite")

	local pos, ang = Vector(0, 0, 0), Angle()
	local mdlang = Angle(ang)
	mdlang:RotateAroundAxis(ang:Right(), 0)
	mdlang:RotateAroundAxis(ang:Forward(), 0)
	mdlang:RotateAroundAxis(ang:Up(), 90)

	local drawThermal = false
	function OSPR_TestThermal()
		local rt_Scene = render.GetRenderTarget()
		render.CopyRenderTargetToTexture(rt_Store)

		render.OverrideAlphaWriteEnable(true, true)
		render.Clear(0, 0, 0, 0, false, true)

		cam.Start3D()
			render.SuppressEngineLighting(true)

			for _, ent in ipairs(ents.FindByClass("player")) do
				if !ent:IsPlayer() then 
					continue 
				end

				render.SetColorModulation(1, 0, 0.25)
				render.MaterialOverride(wireframe)

				ent:DrawModel()


		    end

		    render.SuppressEngineLighting(false)
		    render.SetColorModulation(1, 1, 1)
		    render.MaterialOverride(nil)
		cam.End3D()
			
		render.CopyRenderTargetToTexture(rt_Blur)
		render.BlurRenderTarget(rt_Blur, 0.025, 0.025, 1)

		thermalrt:SetTexture("$basetexture", rt_Blur)

		render.SetRenderTarget(rt_Scene)
		
		copy:SetTexture("$basetexture", rt_Store)
		render.SetMaterial(copy)
		render.DrawScreenQuad()
		
		render.SetMaterial(thermalrt)
		render.DrawScreenQuad()
	end

	function SWEP:DoScope()
		if self:GetState() != ArcCW.STATE_SIGHTS then
			if drawThermal then
				hook.Remove("PostDrawEffects", "VISOR.UI")
				drawThermal = false
			end

			return
		end
		
		if self:GetSightDelta() > 0.75 then
			if drawThermal then
				hook.Remove("PostDrawEffects", "VISOR.UI")
				drawThermal = false
			end
			
			return
		end

		if !drawThermal then
			hook.Add("PostDrawEffects", "VISOR.UI", OSPR_TestThermal)
			drawThermal = true
		end
		
		if !scope_bg:IsError() then
			render.SetMaterial(scope_bg)
	        render.DrawScreenQuad()

	        render.SetMaterial(scope_bg_overlay)
	        render.DrawScreenQuad()
	    end

	   
	end

	function SWEP:DrawHUD()
		if self:GetState() != ArcCW.STATE_SIGHTS then
			return
		end
		
		if self:GetSightDelta() > 0.75 then
			return
		end
		
		cam.Start3D(EyePos(), ang, 75, 0, 0, nil, nil, 0.1, 1280)
			cam.IgnoreZ(true)
				render.SuppressEngineLighting(true)
				render.SetColorModulation(0, 1, 0.95)
				render.MaterialOverride(debugwhite)
				visor_ui_model:SetPos(EyePos())
				visor_ui_model:SetAngles(mdlang)
				visor_ui_model:DrawModel()
				render.SuppressEngineLighting(false)
			cam.IgnoreZ(false)
		cam.End3D()
	end
end

function SWEP:StartCharge()
	self.LastChargeUpTime = CurTime()
end

function SWEP:StopCharge()
	self.LastChargeUpTime = nil
end

function SWEP:GetChargeDelta()
	if !self.LastChargeUpTime then
		return 0
	end
	
	local delta = math.Clamp((CurTime() - self.LastChargeUpTime) / 5, 0, 1)

	delta = math.abs(delta)

	return delta
end

function SWEP:Hook_Think()
	if SERVER then
		if self:GetState() == ArcCW.STATE_SIGHTS and !self.LastChargeUpTime then
			self:StartCharge()
			self:CallOnClient("StartCharge")
		elseif self:GetState() != ArcCW.STATE_SIGHTS and self.LastChargeUpTime then
			self:StopCharge()
			self:CallOnClient("StopCharge")
		end
	end
end

function SWEP:DoShellEject()

end

function SWEP:DoEffects()

end