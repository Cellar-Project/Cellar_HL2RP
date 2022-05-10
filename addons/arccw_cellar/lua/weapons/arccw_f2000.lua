SWEP.Base = "arccw_base"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "CELLAR" 
SWEP.AdminOnly = false

SWEP.PrintName = "FN F2000"
SWEP.Trivia_Class = "Assault Rifle"
SWEP.Trivia_Desc = "A bulky belgian assault rifle firing the 5.56mm NATO round using a bullpup configuration to keep it a compact size."
SWEP.Trivia_Manufacturer = "GIAT Industries"
SWEP.Trivia_Calibre = "5.56x45mm NATO"
SWEP.Trivia_Mechanism = "Gas-Operated"
SWEP.Trivia_Country = "Belgium"
SWEP.Trivia_Year = 2000

SWEP.Slot = 2

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/arccw/c_mw2e_f2000.mdl"
SWEP.WorldModel = "models/weapons/arccw/w_mw2e_f2000.mdl"
SWEP.MirrorWorldModel = "models/weapons/arccw/w_mw2e_f2000.mdl"
SWEP.MirrorVMWM = true
SWEP.WorldModelOffset = {
    pos        =    Vector(-7.1, 3.5, -5.5),
    ang        =    Angle(-9, -1.5, 180),
    bone    =    "ValveBiped.Bip01_R_Hand",
    scale   =   1.2
}
SWEP.ViewModelFOV = 60

SWEP.Damage = 30
SWEP.DamageMin = 20
SWEP.BloodDamage = 290
SWEP.ShockDamage = 300
SWEP.BleedChance = 60
SWEP.AmmoItem = "bullets_556x45"

SWEP.Range = 120 -- in METRES
SWEP.Penetration = 9
SWEP.DamageType = DMG_BULLET
SWEP.ShootEntity = nil -- entity to fire, if any
SWEP.MuzzleVelocity = 950 -- projectile or phys bullet muzzle velocity
-- IN M/S
SWEP.ChamberSize = 0 -- how many rounds can be chambered.
SWEP.Primary.ClipSize = 30 -- DefaultClip is automatically set.

SWEP.Recoil = 0.3
SWEP.RecoilSide = 0.3
SWEP.RecoilRise = 0.4
SWEP.VisualRecoilMult = 0.2

SWEP.Delay = 60 / 900 -- 60 / RPM.
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

SWEP.NPCWeaponType = {
    "weapon_smg1",
    "weapon_ar2",
}
SWEP.NPCWeight = 100

SWEP.AccuracyMOA = 1.6 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 600 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 150

SWEP.Primary.Ammo = "smg1" -- what ammo type the gun uses
SWEP.MagID = "famas" -- the magazine pool this gun draws from

SWEP.ShootVol = 115 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound

SWEP.ShootSound = "ArcCW_MW2E.F2000_Fire"
SWEP.ShootSoundSilenced = "ArcCW_MW3E.M4M16_Sil"

SWEP.MeleeSwingSound = "arccw_go/m249/m249_draw.wav"
SWEP.MeleeMissSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.MeleeHitNPCSound = "physics/body/body_medium_break2.wav"

SWEP.MuzzleEffect = "muzzleflash_1"
SWEP.ShellModel = "models/shells/shell_762nato.mdl"
SWEP.ShellScale = 1.25
SWEP.ShellMaterial = "models/weapons/arcticcw/shell_556_steel"

SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.CaseEffectAttachment = 2 -- which attachment to put the case effect on
SWEP.ProceduralViewBobAttachment = 1
SWEP.CamAttachment = 4

SWEP.SpeedMult = 0.9
SWEP.SightedSpeedMult = 0.4
SWEP.SightTime = 0.4

SWEP.ProceduralRegularFire = false
SWEP.ProceduralIronFire = false

SWEP.IronSightStruct = {
    Pos = Vector(-3.29, 0, 1.2),
    Ang = Angle(-1.5, 0.02, 0),
    Magnification = 1.1,
    CrosshairInSights = false,
    SwitchToSound = "",
}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "ar2"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.ActivePos = Vector(0, 2, 1)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.SprintPos = Vector(0, 2, 1)
SWEP.SprintAng = Angle(0, 0, 0)

SWEP.CustomizePos = Vector(15, 3, 0)
SWEP.CustomizeAng = Angle(15, 40, 25)

SWEP.HolsterPos = Vector(3, 0, 0)
SWEP.HolsterAng = Angle(-7.036, 30.016, 0)

SWEP.BarrelOffsetSighted = Vector(0, 0, -1)
SWEP.BarrelOffsetHip = Vector(2, 0, -2)

SWEP.BarrelLength = 20

SWEP.ExtraSightDist = 5

SWEP.AttachmentsElements = {}
SWEP.Attachments = {}

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1 / 30,
    },
    ["draw"] = {
        Source = "draw",
        Time = 1,
        LHIK = true,
        LHIKIn = 0.2,
        LHIKOut = 0.25,
    },
    ["holster"] = {
        Source = "holster",
        Time = 0.75,
        LHIK = true,
        LHIKIn = 0.2,
        LHIKOut = 0.25,
    },
    ["ready"] = {
        Source = "first_draw",
        Time = 1.15,
        LHIK = true,
        LHIKIn = 0.2,
        LHIKOut = 0.25,
        SoundTable = {
            {s = "ArcCW_MW2E.F2000_FirstLift", t = 1 / 60},
            {s = "ArcCW_MW2E.F2000_FirstChamber", t = 7 / 30},
        },
    },
    ["fire"] = {
        Source = {"fire"},
        Time = 7 / 30,
        ShellEjectAt = 0,
        SoundTable = {
            {s = "ArcCW_MW3E.Mech_C", t = 1 / 60},
        },
    },
    ["fire_iron"] = {
        Source = {"fire_ads"},
        Time = 7 / 30,
        ShellEjectAt = 0,
        SoundTable = {
            {s = "ArcCW_MW3E.Mech_C", t = 1 / 60},
        },
    },
    ["reload"] = {
        Source = "reload",
        Time = 2.6,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SMG1,
        Framerate = 30,
        Checkpoints = {28, 38, 69},
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.24,
        SoundTable = {
            {s = "ArcCW_MW2E.F2000_MagOut", t = 18 / 35},
            {s = "ArcCW_MW2E.F2000_MagIn", t = 58 / 35},
        },
    },
    ["reload_empty"] = {
        Source = "reload_empty",
        Time = 3.2,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SMG1,
        Framerate = 30,
        Checkpoints = {28, 38, 69},
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.25,
        SoundTable = {
            {s = "ArcCW_MW2E.F2000_MagOut", t = 18 / 35},
            {s = "ArcCW_MW2E.F2000_MagIn", t = 58 / 35},
            {s = "ArcCW_MW2E.F2000_Chamber", t = 80 / 35},
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

-- UBGL IN ANIMS -----------------------------------------------------------------

    ["enter_ubgl"] = {
        Source = "idle_glsetup",
        Time = 0 / 30,
    },
    ["exit_ubgl"] = {
        Source = "idle_glsetup",
        Time = 0 / 30
    },
    ["idle_glsetup"] = {
        Source = "idle_glsetup",
        Time = 1 / 30,
    },
    ["in_glsetup"] = {
        Source = "glsetup_in",
        Time = 0.5,
    },
    ["out_glsetup"] = {
        Source = "glsetup_out",
        Time = 0.5,
    },
    ["fire_glsetup"] = {
        Source = "fire_glsetup",
        Time = 0.7,
        TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
        TPAnimStartTime = 0,
    },
    ["reload_glsetup"] = {
        Source = "reload_glsetup",
        Time = 3,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        TPAnimStartTime = 0.1,
        SoundTable = {
            {s = "ArcCW_COD4E.M203_Open", t = 0.125},
            {s = "ArcCW_COD4E.M203_Load", t = 1.5},
            {s = "ArcCW_COD4E.M203_Close", t = 2.25},
        }
    },
    ["reload_glsetup_soh"] = {
        Source = "reload_glsetup",
        Time = 3 / 2,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        TPAnimStartTime = 0.1,
        SoundTable = {
            {s = "ArcCW_COD4E.M203_Open", t = 0.125 / 2},
            {s = "ArcCW_COD4E.M203_Load", t = 1.5 / 2},
            {s = "ArcCW_COD4E.M203_Close", t = 2.25 / 2},
        }
    },
    ["enter_sprint_glsetup"] = {
        Source = "sprint_in_glsetup",
        Time = 10 / 30
    },
    ["idle_sprint_glsetup"] = {
        Source = "sprint_loop_glsetup",
        Time = 30 / 40
    },
    ["exit_sprint_glsetup"] = {
        Source = "sprint_out_glsetup",
        Time = 10 / 30
    },

    --- UMBK IN ANIMS ---
    ["idle_mksetup"] = {
        Source = "idle_mksetup",
        Time = 1 / 30,
    },
    ["in_mksetup"] = {
        Source = "mksetup_in",
        Time = 0.5,
    },
    ["out_mksetup"] = {
        Source = "mksetup_out",
        Time = 0.5,
    },
    ["fire_mksetup"] = {
        Source = "fire_mksetup",
        Time = 7 / 30,
        TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
        TPAnimStartTime = 0,
    },
    ["pump_mksetup"] = {
        Source = "pump_mksetup",
        Time = 0.75,
        TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
        TPAnimStartTime = 0,
        SoundTable = {
            {s = "ArcCW_MWC.MK_Back", t = 5 / 30 },
            {s = "ArcCW_MWC.MK_Fwd", t = 10 / 30 },
        }
    },
    ["reload_start_mksetup"] = {
        Source = "reload_in_mksetup",
        Time = 35 / 30,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        TPAnimStartTime = 0.1,
        SoundTable = {
            --{s = "ArcCW_COD4E.M203_Open", t = 0.125},
        }
    },
    ["reload_loop_mksetup"] = {
        Source = "reload_loop_mksetup",
        Time = 33 / 30,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        TPAnimStartTime = 0.1,
        SoundTable = {
            {s = "ArcCW_MWC.MK_Shell", t = 0 / 30},
        }
    },
    ["reload_finish_mksetup"] = {
        Source = "reload_out_mksetup",
        Time = 50 / 30,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        TPAnimStartTime = 0.1,
        SoundTable = {
            {s = "ArcCW_MWC.MK_Back", t = 20 / 30 },
            {s = "ArcCW_MWC.MK_Fwd", t = 25 / 30 },
        }
    },
    ["enter_sprint_mksetup"] = {
        Source = "sprint_in_mksetup",
        Time = 10 / 30
    },
    ["idle_sprint_mksetup"] = {
        Source = "sprint_loop_mksetup",
        Time = 30 / 40
    },
    ["exit_sprint_mksetup"] = {
        Source = "sprint_out_mksetup",
        Time = 10 / 30
    },
}