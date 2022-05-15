SWEP.Base = "arccw_base"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "CELLAR" -- edit this if you like
SWEP.AdminOnly = false

SWEP.PrintName = "Crossbow"
SWEP.Trivia_Class = "Crossbow"
SWEP.Trivia_Desc = "Compound crossbow used for specialist roles with special explosive tips."
SWEP.Trivia_Manufacturer = "Unknown"
SWEP.Trivia_Calibre = "HE Bolts"
SWEP.Trivia_Mechanism = "Crossbow"
SWEP.Trivia_Country = "USA"
SWEP.Trivia_Year = 1963

SWEP.Slot = 4

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/arccw/c_bo1_crossbow.mdl"
SWEP.MirrorVMWM = true
SWEP.WorldModelOffset = {
    pos        =    Vector(-3, 5, -7.5),
    ang        =    Angle(5, 7, 180),
    bone    =    "ValveBiped.Bip01_R_Hand",
    scale = 1.1,
}
SWEP.WorldModel = "models/weapons/arccw/c_bo1_crossbow.mdl"
SWEP.ViewModelFOV = 60

SWEP.DefaultBodygroups = "0100000000"

SWEP.Damage = 200
SWEP.DamageMin = 200
SWEP.BloodDamage = 500
SWEP.ShockDamage = 666
SWEP.BleedChance = 95
SWEP.AmmoItem = "bullets_bolts"

SWEP.BlastRadius = 200

SWEP.Penetration = 1
SWEP.DamageType = DMG_BUCKSHOT
SWEP.ShootEntity = "arccw_bo1_xbow_bolt_exp" -- entity to fire, if any
SWEP.MuzzleVelocity = 5000 -- projectile or phys bullet muzzle velocity
-- IN M/S

SWEP.TracerNum = 1 -- tracer every X
SWEP.TracerCol = Color(255, 25, 25)
SWEP.TracerWidth = 3

SWEP.ChamberSize = 0 -- how many rounds can be chambered.
SWEP.Primary.ClipSize = 1 -- DefaultClip is automatically set.

SWEP.CanFireUnderwater = true

SWEP.Recoil = 1
SWEP.RecoilSide = 0.5
SWEP.MaxRecoilBlowback = 2

SWEP.Delay = 60 / 300 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
    },
    {
        Mode = 0
    },
}

SWEP.NPCWeaponType = {"weapon_crossbow"}
SWEP.NPCWeight = 35

SWEP.AccuracyMOA = 5 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 500 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 100

SWEP.Primary.Ammo = "XBowBolt" -- what ammo type the gun uses

SWEP.ShootVol = 75 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound

SWEP.ShootSound = "ArcCW_BO1.Crossbow_Fire"
SWEP.ShootSoundSilenced = "ArcCW_BO1.M16_Sil"
SWEP.DistantShootSound = "ArcCW_BO1.Crossbow_Dist"

SWEP.MuzzleEffect = nil --"muzzleflash_shotgun"
SWEP.ShellModel = "models/shells/shell_12gauge.mdl"
SWEP.ShellPitch = 100
SWEP.ShellSounds = ArcCW.ShotgunShellSoundsTable
SWEP.ShellScale = 1.5

SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.CaseEffectAttachment = 2 -- which attachment to put the case effect on
SWEP.ProceduralViewBobAttachment = 1
SWEP.CamAttachment = 2

SWEP.SpeedMult = 0.95
SWEP.SightedSpeedMult = 0.75
SWEP.SightTime = 0.27

SWEP.BulletBones = { -- the bone that represents bullets in gun/mag
    -- [0] = "bulletchamber",
    -- [1] = "bullet1"
}

SWEP.CaseBones = {}

SWEP.IronSightStruct = {
    Pos = Vector(-2.2, 3, 0.5),
    Ang = Angle(0.3, 0, 0),
    Magnification = 1.1,
    CrosshairInSights = false,
    SwitchToSound = "", -- sound that plays when switching to this sight
}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "crossbow"
SWEP.HoldtypeSights = "crossbow"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN

SWEP.ActivePos = Vector(1, 3, 0.25)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.SprintPos = Vector(0, 3, 0)
SWEP.SprintAng = Angle(0, 0, 0)

SWEP.CustomizePos = Vector(19, 8, 2)
SWEP.CustomizeAng = Angle(15, 40, 30)

SWEP.HolsterPos = Vector(0.532, -6, 0)
SWEP.HolsterAng = Angle(-7.036, 30.016, 0)

SWEP.BarrelOffsetSighted = Vector(0, 0, -1)
SWEP.BarrelOffsetHip = Vector(2, 0, -2)

SWEP.AttachmentElements = {}

SWEP.ExtraSightDist = 5

SWEP.Attachments = {}

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1 / 35,
    },
    ["draw"] = {
        Source = "draw",
        Time = 25 / 35,
        LHIK = true,
        LHIKIn = 0.2,
        LHIKOut = 0.2,
    },
    ["holster"] = {
        Source = "holster",
        Time = 25 / 35,
        LHIK = true,
        LHIKIn = 0.2,
        LHIKOut = 0.2,
    },
    ["fire"] = {
        Source = {
            "fire_last",
        },
        Time = 0.2,
    },
    ["fire_iron"] = {
        Source = {
            "fire_last",
        },
        Time = 0.2,
    },
    ["reload"] = {
        Source = "reload",
        Time = 93 / 35,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_CROSSBOW,
        LHIK = true,
        LHIKIn = 0.2,
        LHIKOut = 0.2,
        SoundTable = {
            {s = "ArcCW_BO1.Crossbow_Draw", t = 5 / 35},
            {s = "ArcCW_BO1.Crossbow_Futz", t = 45 / 35},
            {s = "ArcCW_BO1.Crossbow_Latch", t = 50 / 35},
            {s = "ArcCW_BO1.Crossbow_Bolt", t = 60 / 35},
        },
    },
    ["enter_sprint"] = {
        Source = "sprint_in",
        Time = 10 / 30
    },
    ["idle_sprint"] = {
        Source = "sprint_loop",
        Time = 30 / 30
    },
    ["exit_sprint"] = {
        Source = "sprint_out",
        Time = 10 / 30
    },

    ["idle_empty"] = {
        Source = "idle_empty",
        Time = 1 / 35,
    },
    ["draw_empty"] = {
        Source = "draw_empty",
        Time = 25 / 35,
        LHIK = true,
        LHIKIn = 0.2,
        LHIKOut = 0.2,
    },
    ["holster_empty"] = {
        Source = "holster_empty",
        Time = 25 / 35,
        LHIK = true,
        LHIKIn = 0.2,
        LHIKOut = 0.2,
    },
    ["enter_sprint_empty"] = {
        Source = "sprint_in_empty",
        Time = 10 / 30
    },
    ["idle_sprint_empty"] = {
        Source = "sprint_loop_empty",
        Time = 30 / 30
    },
    ["exit_sprint_empty"] = {
        Source = "sprint_out_empty",
        Time = 10 / 30
    },
}