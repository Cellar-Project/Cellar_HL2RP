SWEP.Base = "arccw_base"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "CELLAR"
SWEP.AdminOnly = false

SWEP.PrintName = "Military Sniper"
SWEP.TrueName = "Military Sniper"
SWEP.Trivia_Class = "Sniper Rifle"
SWEP.Trivia_Desc = "The military sniper rifle is available to purchase in Factions. To unlock, the player needs to collect 6900 supplies, making it the most expensive purchasable weapon to acquire. It costs three loadout points to equip and requires 400 Parts to purchase, making it the most expensive purchaseables after the Shotgun. When purchased, the player is given four rounds; the price goes up by 80 parts for each purchase thereafter unless the player switches classes. Like other scoped weapons, if the player aims down the scope, the light reflecting off the scope lens can be seen. This can give away the player's position."
SWEP.Trivia_Manufacturer = "The Military"
SWEP.Trivia_Calibre = ".30-06 Springfield"
SWEP.Trivia_Mechanism = "Bolt-Action"
SWEP.Trivia_Country = "United States"
SWEP.Trivia_Year = 1988

SWEP.Slot = 2

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_militarysniper.mdl"
SWEP.WorldModel = "models/weapons/c_militarysniper.mdl"
SWEP.ViewModelFOV = 60

SWEP.DefaultBodygroups = "000000000000"

SWEP.ShotgunReload = false
SWEP.Damage = 150
SWEP.DamageMin = 100 -- damage done at maximum range
SWEP.RangeMin = 50
SWEP.BloodDamage = 666
SWEP.ShockDamage = 666
SWEP.BleedChance = 90
SWEP.Num = 1
SWEP.Range = 1097
SWEP.Penetration = 12
SWEP.DamageType = DMG_BULLET
SWEP.ShootEntity = nil -- entity to fire, if any
SWEP.ChamberSize = 0
SWEP.Primary.ClipSize = 4 -- DefaultClip is automatically set.
SWEP.AmmoItem = "bullets_springfield"

SWEP.PhysBulletMuzzleVelocity = 700

SWEP.Recoil = 1.7
SWEP.RecoilSide = 1.2
SWEP.RecoilRise = 1.6

SWEP.ManualAction = true
SWEP.Delay = 60 / 300 -- 60 / RPM.
SWEP.Firemodes = {
    {
        Mode = 1,
        PrintName = "BOLT"
    },
    {
        Mode = 0
    }
}

SWEP.NPCWeaponType = "weapon_crossbow"
SWEP.NPCWeight = 180

SWEP.AccuracyMOA = 0.2
SWEP.HipDispersion = 500 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 220

SWEP.Primary.Ammo = "ar2" -- what ammo type the gun uses

SWEP.ShootVol = 120 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound

SWEP.ShootSound = "weapons/militarysniper/fire.wav"
SWEP.ShootSoundSilenced = "weapons/mini14/fire_suppressed.wav"
SWEP.DistantShootSound = "weapons/hunting/dist1.wav"

SWEP.MeleeSwingSound = "arccw_go/m249/m249_draw.wav"
SWEP.MeleeMissSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.MeleeHitSound = "arccw_go/knife/knife_hitwall1.wav"
SWEP.MeleeHitNPCSound = "physics/body/body_medium_break2.wav"

SWEP.MuzzleEffect = "muzzleflash_3"
SWEP.ShellModel = "models/shells/shell_762nato.mdl"
SWEP.ShellPitch = 100
SWEP.ShellScale = 2
SWEP.ShellRotateAngle = Angle(0, 180, 0)

SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.CaseEffectAttachment = 7 -- which attachment to put the case effect on

SWEP.SpeedMult = 0.88
SWEP.SightedSpeedMult = 0.5
SWEP.SightTime = 0.35

SWEP.IronSightStruct = {
    Pos = Vector(-2.6, -2, 1.679),
    Ang = Angle(0, 0, 0),
    Magnification = 1,
    SwitchToSound = "", -- sound that plays when switching to this sight
    CrosshairInSights = false
}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "shotgun"
SWEP.HoldtypeSights = "ar2"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG
SWEP.NoLastCycle = true
SWEP.ActivePos = Vector(0, 0, 2)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.CrouchPos = Vector(-4, 0, -1)
SWEP.CrouchAng = Angle(0, 0, -10)

SWEP.HolsterPos = Vector(1, 0, 2)
SWEP.HolsterAng = Angle(-5, 5, 0)

SWEP.BarrelOffsetSighted = Vector(0, 0, -1)
SWEP.BarrelOffsetHip = Vector(2, 0, -2)

SWEP.CustomizePos = Vector(6, -1, -1)
SWEP.CustomizeAng = Angle(10, 15, 15)

SWEP.BarrelLength = 24

SWEP.AttachmentElements = {}

SWEP.ExtraSightDist = 20

SWEP.WorldModelOffset = {
    pos = Vector(-5, 4, -6),
    ang = Angle(-5, 2, 180)
}

SWEP.ShellRotateAngle = Angle(5, 90, 0)

SWEP.MirrorVMWM = true



SWEP.Attachments = {}


SWEP.Animations = {
    ["draw"] = {
        Source = "base_draw",
		Time = 1
    },
	
    ["idle"] = {
        Source = "base_idle",
        LHIK = false,
		Time = 1
    },
	
    ["holster"] = {
        Source = "holster",
    },
    ["ready"] = {
        Source = "base_ready",
		SoundTable = {
			{s = "weapons/hunting/boltback.wav", t = 0.4},
			{s = "weapons/hunting/boltforward.wav", t = 0.6}
	},
		Time = 2
    },
	
    ["fire"] = {
        Source = "fire",
        MinProgress = 0.15,
    },
	
    ["fire_iron"] = {
        Source = "fire_scoped",
        MinProgress = 0.15,
    },
	
    ["cycle"] = {
        Source = "base_fire_end",
        ShellEjectAt = 0.35,
        MinProgress = 0.95,
		SoundTable = {
			{s = "weapons/hunting/boltback.wav", t = 0.2},
			{s = "weapons/hunting/boltforward.wav", t = 0.5}
	},
		Time = 1.2,
        TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN,
    },
	
    ["cycle_iron"] = {
        Source = "Iron_fire_end",
        ShellEjectAt = 0.35,
        MinProgress = 0.95,
		SoundTable = {
			{s = "weapons/hunting/boltback.wav", t = 0.2},
			{s = "weapons/hunting/boltforward.wav", t = 0.5}
	},
		Time = 1.2,
    },

    ["reload"] = {
        Source = "base_reload",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        LHIK = true,
		SoundTable = {
			{s = "weapons/semiauto/magout.wav", t = 0.6},
			{s = "weapons/assaultrifle/magout.wav", t = 0.7},
			{s = "weapons/semiauto/magin.wav", t = 2.1}
	},
		Time = 3,
    },
    ["reload_empty"] = {
        Source = "base_reloadempty",
		SoundTable = {
			{s = "weapons/semiauto/magout.wav", t = 0.5},
			{s = "weapons/assaultrifle/magout.wav", t = 0.6},
			{s = "weapons/semiauto/magin.wav", t = 1.8},
			{s = "weapons/hunting/boltback.wav", t = 2.6},
			{s = "weapons/hunting/boltforward.wav", t = 3}
	},
        Time = 3.9,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 1,
    },
	
    ["idle_sprint"] = {
        Source = "base_sprint",
		Time = 0.7,
    },
	
    ["exit_sprint"] = {
        Source = "base_idle",
		Time = 0.7,
    },
	
}