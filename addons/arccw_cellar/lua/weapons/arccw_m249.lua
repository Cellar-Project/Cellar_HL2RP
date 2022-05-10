SWEP.Base = "arccw_base"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "CELLAR" 
SWEP.AdminOnly = false

SWEP.PrintName = "M249 SAW"
SWEP.Trivia_Class = "Light Machine Gun"
SWEP.Trivia_Desc = "Belgian light machine gun. Standard squad automatic weapon for the United States armed forces."
SWEP.Trivia_Manufacturer = "FN Herstal"
SWEP.Trivia_Calibre = "5.56x45mm NATO"
SWEP.Trivia_Mechanism = "Short-stroke gas piston"
SWEP.Trivia_Country = "Belgium"
SWEP.Trivia_Year = 1984

SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/arccw/c_cod4_m249.mdl"
SWEP.WorldModel = "models/weapons/arccw/c_cod4_m249.mdl"
SWEP.MirrorVMWM = true
SWEP.ViewModelFOV = 60
SWEP.WorldModelOffset = {
    pos        =    Vector(-4.75, 4, -7.75),
    ang        =    Angle(-5, 0, 180),
    bone    =    "ValveBiped.Bip01_R_Hand",
    scale   =   1.25
}

SWEP.Damage = 30
SWEP.DamageMin = 20
SWEP.BloodDamage = 600
SWEP.ShockDamage = 600
SWEP.BleedChance = 70
SWEP.AmmoItem = "bullets_556x45"

SWEP.Range = 150 -- in METRES
SWEP.Penetration = 20
SWEP.DamageType = DMG_BULLET
SWEP.ShootEntity = nil -- entity to fire, if any
SWEP.MuzzleVelocity = 735 -- projectile or phys bullet muzzle velocity
-- IN M/S
SWEP.ChamberSize = 0 -- how many rounds can be chambered.
SWEP.Primary.ClipSize = 100 -- DefaultClip is automatically set.

SWEP.PhysBulletMuzzleVelocity = 900

SWEP.Recoil = 0.75
SWEP.RecoilSide = 0.6
SWEP.RecoilRise = 1
SWEP.VisualRecoilMult = 0.25

SWEP.Delay = 60 / 850 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 2,
    },
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.NPCWeaponType = "weapon_ar2"
SWEP.NPCWeight = 100

SWEP.AccuracyMOA = 3 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 700 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 250

SWEP.Primary.Ammo = "smg1" -- what ammo type the gun uses
SWEP.MagID = "m249" -- the magazine pool this gun draws from

SWEP.ShootVol = 115 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound

SWEP.ShootSound = "ArcCW_COD4E.M249_Fire"
SWEP.ShootSoundSilenced = "ArcCW_COD4E.M4M16_Sil"

SWEP.MeleeSwingSound = "arccw_go/m249/m249_draw.wav"
SWEP.MeleeMissSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.MeleeHitNPCSound = "physics/body/body_medium_break2.wav"

SWEP.MuzzleEffect = "muzzleflash_1"
SWEP.ShellModel = "models/shells/shell_762nato.mdl"
SWEP.ShellScale = 0.75
SWEP.ShellMaterial = "models/weapons/arcticcw/shell_556"

SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.CaseEffectAttachment = 2 -- which attachment to put the case effect on

SWEP.SpeedMult = 0.7
SWEP.SightedSpeedMult = 0.5
SWEP.SightTime = 0.5

SWEP.IronSightStruct = {
    Pos = Vector(-2.701, -2.5, 0.994),
    Ang = Angle(-0.787, 0, -3),
    Magnification = 1.1,
    SwitchToSound = "", -- sound that plays when switching to this sight
}

SWEP.BulletBones = { -- the bone that represents bullets in gun/mag
     [1] = "j_chain_bullets1",
     [2] = "j_chain_bullets2",
     [3] = "j_chain_bullets3",
     [4] = "j_chain_bullets4",
     [5] = "j_chain_bullets5",
     [6] = "j_chain_bullets6",
     [7] = "j_chain_bullets7",
     [8] = "j_chain_bullets8",
     [9] = "j_chain_bullets9",
     [10] = "j_chain_bullets10",
     [11] = "j_chain_bullets11",
     [12] = "j_chain_bullets12",
     [13] = "j_chain_bullets13",
     [14] = "j_chain_bullets14",
     [15] = "j_chain_bullets15",
}

SWEP.ProceduralRegularFire = false
SWEP.ProceduralIronFire = false

SWEP.CaseBones = {}

SWEP.IronSightStruct = {
    Pos = Vector(-3.16, 0, 2.15),
    Ang = Angle(0.75, 0.02, 0),
    Magnification = 1.1,
    CrosshairInSights = false,
    SwitchToSound = "", -- sound that plays when switching to this sight
}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "ar2"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.ActivePos = Vector(0, 3, 1)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.SprintPos = Vector(0, 3, 1)
SWEP.SprintAng = Angle(0, 0, 0)

SWEP.CustomizePos = Vector(15, 5, 0)
SWEP.CustomizeAng = Angle(15, 40, 30)

SWEP.HolsterPos = Vector(3, 0, 0)
SWEP.HolsterAng = Angle(-7.036, 30.016, 0)

SWEP.BarrelOffsetSighted = Vector(0, 0, -1)
SWEP.BarrelOffsetHip = Vector(2, 0, -2)

SWEP.BarrelLength = 30

SWEP.AttachmentElements = {}

SWEP.ExtraSightDist = 5

SWEP.Attachments = {}

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1 / 30,
    },
    ["draw"] = {
        Source = "draw",
        Time = 0.75,
    },
    ["holster"] = {
        Source = "holster",
        Time = 24 / 30,
        LHIK = true,
        LHIKIn = 0.2,
        LHIKOut = 0.2,
    },
    ["ready"] = {
        Source = "draw",
        Time = 1,
    },
    ["fire"] = {
        Source = {"fire"},
        Time = 7 / 30,
        ShellEjectAt = 0,
        SoundTable = {
            { s = "ArcCW_BO1.Mk48_Mech", t = 0 },
            { s = "ArcCW_BO1.Mk48_LFE", t = 0.1 },
        }
    },
    ["fire_iron"] = {
        Source = {"fire_ads"},
        Time = 7 / 30,
        ShellEjectAt = 0,
        SoundTable = {
            { s = "ArcCW_BO1.Mk48_Mech", t = 0 },
            { s = "ArcCW_BO1.Mk48_LFE", t = 0.1 },
        }
    },
    ["reload"] = {
        Source = "reload",
        Time = 5.16,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        LHIK = true,
        LHIKIn = nil,
        LHIKOut = 1,
        LastClip1OutTime = 2.5,
        SoundTable = {
            {s = "ArcCW_COD4E.M249_Chamber", t = 0.25},
            {s = "ArcCW_COD4E.M249_Open", t = 1},
            {s = "ArcCW_COD4E.M249_Out", t = 2},
            {s = "ArcCW_COD4E.M249_In", t = 3.25},
            {s = "ArcCW_COD4E.M249_Close", t = 4.25},
        },
    },
    ["reload_optic"] = {
        Source = "reload_optic",
        Time = 5.16,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        LHIK = true,
        LHIKIn = nil,
        LHIKOut = 1,
        LastClip1OutTime = 2.5,
        SoundTable = {
            {s = "ArcCW_COD4E.M249_Chamber", t = 0.25},
            {s = "ArcCW_COD4E.M249_Open", t = 1},
            {s = "ArcCW_COD4E.M249_Out", t = 2},
            {s = "ArcCW_COD4E.M249_In", t = 3.25},
            {s = "ArcCW_COD4E.M249_Close", t = 4.25},
        },
    },
    ["enter_sprint"] = {
        Source = "sprint_in",
        Time = 10 / 30
    },
    ["idle_sprint"] = {
        Source = "sprint_loop",
        Time = 30 / 40
    },
    ["exit_sprint"] = {
        Source = "sprint_out",
        Time = 10 / 30
    },
}