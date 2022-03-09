dispatch.mpf_ranks = {
	[1] = {
		name = "Regular",
		class = function() 
			return CLASS_MPF 
		end
	},
	[2] = {
		name = "Rank Leader",
		class = function() 
			return CLASS_RL 
		end
	},
}

function dispatch.Rank(id)
	return dispatch.mpf_ranks[id] or dispatch.mpf_ranks[1]
end

function dispatch.GetRank(character)
	return ix.class.list[character:GetClass()].rank or 0
end