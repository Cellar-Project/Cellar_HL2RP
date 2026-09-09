local PLAYER = FindMetaTable("Player")

function PLAYER:IsDispatch()
	return self:Team() == FACTION_DISPATCH
end

-- FACTION_ASS is defined by the zz_assassin plugin, which loads after this file,
-- so the global has to be read at call time rather than captured here.
function PLAYER:IsAssassin()
	return FACTION_ASS != nil and self:Team() == FACTION_ASS
end