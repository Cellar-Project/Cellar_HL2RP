local SQUAD = ix.meta.squad or {}
	SQUAD.__index = SQUAD

	SQUAD.tag = "NOTAG"
	SQUAD.leader = nil
	SQUAD.members = {}
	SQUAD.isOverwatch = false
	SQUAD.counter = 0

	function SQUAD:Setup(tag, leader, isOverwatch)
		self.tag = tag
		self.leader = leader
		self.members = {}
		self.isOverwatch = isOverwatch
		self.counter = 0
	end

	function SQUAD:AddMember(client)
		self.counter = self.counter + 1 
		self.members[client] = self.counter

		-- todo: network
	end

	function SQUAD:RemoveMember(client)
		if !IsValid(client) then
			return
		end
		
		self.members[client] = nil

		-- todo: network
	end

	function SQUAD:SetLeader(client)
		self.leader = client

		-- todo: network
	end
	
ix.meta.squad = SQUAD