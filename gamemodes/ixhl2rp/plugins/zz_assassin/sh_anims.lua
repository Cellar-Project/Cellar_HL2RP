local PLUGIN = PLUGIN

--[[
	The assassin rig ships as two models with different animation sources:

	  schwarzkruppzo/assassin.mdl         -> assassin_anims.mdl only: 50 bespoke sequences
	                                         (relaxed unarmed set, sniper aim, stances); no
	                                         stock player activities, so any weapon holdtype
	                                         without a table entry T-poses.
	  schwarzkruppzo/player/assassin.mdl  -> models/f_anm.mdl only: the full stock set, plus a
	                                         "proportions" delta (AUTOPLAY) that adapts stock
	                                         anims to this skeleton, whose legs/hands differ by
	                                         1-2 units from the standard female skeleton.

	tools/patch-assassin-model.cjs builds player/assassin_cellar.mdl, which includes both
	anim models with the proportions AUTOPLAY flag cleared. This file drives that model:
	lowered/unarmed states use the bespoke relaxed set, raised states use the stock
	per-weapon aim sets, prone is whatever f_anm provides on this server, and the
	proportions delta is re-applied as a gesture layer only while a stock sequence plays.
]]

PLUGIN.model = "models/schwarzkruppzo/player/assassin_cellar.mdl"
PLUGIN.legacyModel = "models/schwarzkruppzo/assassin.mdl"

-- Every sequence in assassin_anims.mdl. Anything the rig plays that is not in here comes
-- from f_anm.mdl and needs the proportion fix layered on.
PLUGIN.customSequences = {}

for _, name in ipairs({
	"reference", "body_rot_z", "spine_rot_z", "head_rot_z", "head_rot_y", "head_rot_x", "neck_trans_x",
	"valvebiped", "gmod_breath_layer", "gmod_breath_layer_lock_hands", "gmod_breath_layer_lock_right",
	"gmod_breath_layer_sitting", "jump_delta", "land", "glide_layer", "glide",
	"idle_ospr_angry", "walk_ospr_angry",
	"idle_relaxed", "LineIdle02", "walk_relaxed", "crouch_idle_relaxed", "crouch_walk_relaxed", "run_relaxed", "jump_relaxed",
	"prone_idle_relaxed", "prone_walk_relaxed", "aimlayer_prone_ospr", "prone_idle_ospr_relaxed", "prone_idle_ospr_angry",
	"stances_down01", "stances_down02", "stances_down03",
	"stances_sit01", "stances_sit02", "stances_sit03", "stances_sit04", "stances_sit05", "stances_sit06", "stances_sit07",
	"stances_sit08", "stances_sit09", "stances_sitwall", "stances_sitground", "stances_check",
	"stances_stand01", "stances_stand02", "stances_stand03", "stances_lean01", "stances_lean02"
}) do
	PLUGIN.customSequences[name] = true
end

-- Lowered = bespoke relaxed cycles, raised = the given stock activities.
local function WithRelaxedLowered(raised)
	return {
		[ACT_MP_STAND_IDLE] = {"idle_relaxed", raised.idle},
		[ACT_MP_CROUCH_IDLE] = {"crouch_idle_relaxed", raised.crouchIdle},
		[ACT_MP_WALK] = {"walk_relaxed", raised.walk},
		[ACT_MP_CROUCHWALK] = {"crouch_walk_relaxed", raised.crouchWalk},
		[ACT_MP_RUN] = {"run_relaxed", raised.run},
		glide = {"jump_relaxed", raised.jump},
		attack = raised.attack,
		reload = raised.reload,
		-- Same prone set every other female rig on the server uses.
		prone_walk = {"pwalk_all", "pwalk_all"},
		prone_idle = {"pidle_holding", raised.proneIdle}
	}
end

ix.anim.assassin = {
	normal = {
		[ACT_MP_STAND_IDLE] = {"idle_relaxed", ACT_HL2MP_IDLE_FIST},
		[ACT_MP_CROUCH_IDLE] = {"crouch_idle_relaxed", ACT_HL2MP_IDLE_CROUCH_FIST},
		[ACT_MP_WALK] = {"walk_relaxed", ACT_HL2MP_WALK_FIST},
		[ACT_MP_CROUCHWALK] = {"crouch_walk_relaxed", ACT_HL2MP_WALK_CROUCH_FIST},
		[ACT_MP_RUN] = {"run_relaxed", ACT_HL2MP_RUN_FIST},
		attack = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
		glide = {"jump_relaxed", ACT_HL2MP_JUMP_FIST},
		sit = ACT_BUSY_SIT_CHAIR,
		prone_walk = {"pwalk_all", "pwalk_all"},
		prone_idle = {"pidle_normal", "pidle_fists_aim"}
	},
	pistol = WithRelaxedLowered({
		idle = ACT_HL2MP_IDLE_PISTOL, crouchIdle = ACT_HL2MP_IDLE_CROUCH_PISTOL,
		walk = ACT_HL2MP_WALK_PISTOL, crouchWalk = ACT_HL2MP_WALK_CROUCH_PISTOL,
		run = ACT_HL2MP_RUN_PISTOL, jump = ACT_HL2MP_JUMP_PISTOL,
		attack = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL, reload = ACT_HL2MP_GESTURE_RELOAD_PISTOL,
		proneIdle = "pidle_pistol_aim"
	}),
	smg = WithRelaxedLowered({
		idle = ACT_HL2MP_IDLE_SMG1, crouchIdle = ACT_HL2MP_IDLE_CROUCH_SMG1,
		walk = ACT_HL2MP_WALK_SMG1, crouchWalk = ACT_HL2MP_WALK_CROUCH_SMG1,
		run = ACT_HL2MP_RUN_SMG1, jump = ACT_HL2MP_JUMP_SMG1,
		attack = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1, reload = ACT_HL2MP_GESTURE_RELOAD_SMG1,
		proneIdle = "pidle_smg1_aim"
	}),
	shotgun = WithRelaxedLowered({
		idle = ACT_HL2MP_IDLE_SHOTGUN, crouchIdle = ACT_HL2MP_IDLE_CROUCH_SHOTGUN,
		walk = ACT_HL2MP_WALK_SHOTGUN, crouchWalk = ACT_HL2MP_WALK_CROUCH_SHOTGUN,
		run = ACT_HL2MP_RUN_SHOTGUN, jump = ACT_HL2MP_JUMP_SHOTGUN,
		attack = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN, reload = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		proneIdle = "pidle_shotgun_aim"
	}),
	knife = WithRelaxedLowered({
		idle = ACT_HL2MP_IDLE_KNIFE, crouchIdle = ACT_HL2MP_IDLE_CROUCH_KNIFE,
		walk = ACT_HL2MP_WALK_KNIFE, crouchWalk = ACT_HL2MP_WALK_CROUCH_KNIFE,
		run = ACT_HL2MP_RUN_KNIFE, jump = ACT_HL2MP_JUMP_KNIFE,
		attack = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE,
		proneIdle = "pidle_knife_aim"
	}),
	melee = WithRelaxedLowered({
		idle = ACT_HL2MP_IDLE_MELEE, crouchIdle = ACT_HL2MP_IDLE_CROUCH_MELEE,
		walk = ACT_HL2MP_WALK_MELEE, crouchWalk = ACT_HL2MP_WALK_CROUCH_MELEE,
		run = ACT_HL2MP_RUN_MELEE, jump = ACT_HL2MP_JUMP_MELEE,
		attack = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
		proneIdle = "pidle_melee_aim"
	}),
	grenade = WithRelaxedLowered({
		idle = ACT_HL2MP_IDLE_GRENADE, crouchIdle = ACT_HL2MP_IDLE_CROUCH_GRENADE,
		walk = ACT_HL2MP_WALK_GRENADE, crouchWalk = ACT_HL2MP_WALK_CROUCH_GRENADE,
		run = ACT_HL2MP_RUN_GRENADE, jump = ACT_HL2MP_JUMP_GRENADE,
		attack = ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE,
		proneIdle = "pidle_melee_aim"
	}),
	-- The sniper rifle keeps its bespoke idle/walk aim cycles; the rig has no aiming run
	-- or crouch, so those fall back to the stock rifle set.
	arccw_ospr = WithRelaxedLowered({
		idle = "idle_ospr_angry", crouchIdle = ACT_HL2MP_IDLE_CROUCH_AR2,
		walk = "walk_ospr_angry", crouchWalk = ACT_HL2MP_WALK_CROUCH_AR2,
		run = ACT_HL2MP_RUN_AR2, jump = ACT_HL2MP_JUMP_AR2,
		attack = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2, reload = ACT_HL2MP_GESTURE_RELOAD_AR2,
		proneIdle = "pidle_ar2_aim"
	}),
	glide = ACT_GLIDE,
	vehicle = {
		["prop_vehicle_prisoner_pod"] = {"podpose", Vector(-3, 0, 0)},
		["prop_vehicle_jeep"] = {ACT_BUSY_SIT_CHAIR, Vector(14, 0, -14)},
		["prop_vehicle_airboat"] = {ACT_BUSY_SIT_CHAIR, Vector(8, 0, -20)},
		chair = {"stances_sit02", Vector(10, 0, -19)}
	}
}

ix.anim.SetModelClass(PLUGIN.model, "assassin")
ix.anim.SetModelClass(PLUGIN.legacyModel, "assassin")

--- If the mounted f_anm.mdl has no prone sequences (Prone Mod or Cellar content not
-- present), fall back to the rig's own prone cycles rather than standing up while
-- prone. Probed once per realm the first time an assassin model is seen.
function PLUGIN:ResolveProneSequences(client)
	if (self.proneResolved or client:LookupSequence("pidle_normal") >= 0) then
		self.proneResolved = true
		return
	end

	self.proneResolved = true

	for holdType, tree in pairs(ix.anim.assassin) do
		if (istable(tree) and tree.prone_idle) then
			tree.prone_walk = {"prone_walk_relaxed", "prone_walk_relaxed"}
			tree.prone_idle = holdType == "arccw_ospr"
				and {"prone_idle_ospr_relaxed", "prone_idle_ospr_angry"}
				or {"prone_idle_relaxed", "prone_idle_relaxed"}
		end
	end
end

function PLUGIN:PlayerModelChanged(client, model)
	if (string.lower(model or "") == self.model) then
		self:ResolveProneSequences(client)
	end
end

--[[
	Proportion fix. The "proportions" delta in the patched model no longer autoplays, so
	stock sequences would deform the legs and hands by 1-2 units. Layer it back in on
	a gesture slot whenever the main sequence is not one of the bespoke ones. Runs on
	both realms: the client for what is drawn, the server for hitboxes.
]]
function PLUGIN:UpdateAnimation(client, velocity, maxSeqGroundSpeed)
	if (client.ixAnimModelClass != "assassin") then
		if (client.ixAssassinProportions) then
			client:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
			client.ixAssassinProportions = nil
		end

		return
	end

	local sequenceName = client:GetSequenceName(client:GetSequence())
	local wanted = ix.config.Get("assassinProportionFix", true) and !self.customSequences[sequenceName]

	if (wanted == (client.ixAssassinProportions or false)) then
		return
	end

	if (wanted) then
		local sequence = client:LookupSequence("proportions")

		if (sequence < 0) then
			return
		end

		client:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, sequence, 0, false)
	else
		client:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
	end

	client.ixAssassinProportions = wanted
end
