if SERVER then
	util.AddNetworkString("ixSquadAddMember")
	util.AddNetworkString("ixSquadKickMember")
	util.AddNetworkString("ixSquadLeader")
	util.AddNetworkString("ixSquadSync")
	util.AddNetworkString("ixSquadSyncFull")
	util.AddNetworkString("ixSquadDestroy")
end

ix.util.Include("sh_player.lua")

local SQUAD = ix.meta.squad or {}
	SQUAD.__index = SQUAD

	SQUAD.tag = 0
	SQUAD.leader = nil
	SQUAD.members = {}
	SQUAD.member_counter = 0 -- used for limit condition
	SQUAD.counter = 0 -- used for UNIT TAGS

	function SQUAD:GetTagName()
		return dispatch.available_tags[self.tag] or "ERROR"
	end

	function SQUAD:GetLimitCount()
		return self.member_counter
	end

	function SQUAD:HasMember(character)
		return self.members[character]
	end
	
	function SQUAD:HasPlayer(client)
		return self.members[client:GetCharacter()]
	end

	function SQUAD:IsLeader(character)
		return self.leader == character
	end

	function SQUAD:Setup(tag, character)
		self.tag = tag
		self.leader = character
		self.members = {}
		self.counter = 0  
		self.member_counter = 0

		self:AddMember(character, true)
	end

	function SQUAD:AddMember(character, noNetwork)
		if self:GetLimitCount() >= dispatch.GetMemberLimit() then
			return false, "its full lmao"
		end
		
		self.counter = self.counter + 1

		self.members[character] = self.counter
		self.member_counter = self.member_counter + 1 

		character:SetSquad(self)

		if SERVER and !noNetwork then
			net.Start("ixSquadAddMember")
				net.WriteUInt(self.tag, 4)
				net.WriteUInt(character:GetID(), 32)
			net.Send(dispatch.GetReceivers())
		end

		return true
	end

	function SQUAD:RemoveMember(character, noNetwork)
		if !character or !self:HasMember(character) then
			return false
		end 

		self.members[character] = nil
		self.member_counter = self.member_counter - 1 

		character:SetSquad()

		if SERVER then
			if self:GetLimitCount() <= 0 then
				self:Destroy(character)

				return true
			end

			if !noNetwork then
				net.Start("ixSquadKickMember")
					net.WriteUInt(self.tag, 4)
					net.WriteUInt(character:GetID(), 32)
				net.Send(dispatch.GetReceivers())
			end

			if self:IsLeader(character) then -- he was 
				self:SwitchLeader()
			end
		end

		return true
	end

	function SQUAD:SetLeader(character, noNetwork)
		if !self:HasMember(character) then
			return false
		end 

		self.leader = character

		if SERVER and !noNetwork then
			net.Start("ixSquadLeader")
				net.WriteUInt(self.tag, 4)
				net.WriteUInt(character:GetID(), 32)
			net.Send(dispatch.GetReceivers())
		end

		return true
	end

	function SQUAD:Destroy(lastCharacter)
		if SERVER then
			net.Start("ixSquadDestroy")
				net.WriteUInt(self.tag, 4)
			net.Send(dispatch.GetReceivers())

			ix.log.Add(lastCharacter, "squadDestroy", self:GetTagName())
		else
			for character, _ in pairs(self.members) do
				character:SetSquad()
			end
		end

		dispatch.squads[self.tag] = nil
	end
	
	if SERVER then
		function SQUAD:SwitchLeader()
			for character, _ in pairs(self.members) do
				self:SetLeader(character)
				break
			end
		end

		function SQUAD:Sync(full, receivers)
			receivers = receivers or dispatch.GetReceivers()

			local leaderID = self.leader:GetID()

			if !full then
				net.Start("ixSquadSync")
					net.WriteUInt(self.tag, 4)
					net.WriteUInt(leaderID, 32)
				net.Send(receivers)
			else
				net.Start("ixSquadSyncFull")
					net.WriteUInt(self.tag, 4)
					net.WriteUInt(leaderID, 32)
					net.WriteUInt(self.counter, 8)

					local members = {}

					for char, counter in pairs(self.members) do
						if char == self.leader then continue end
						
						members[char:GetID()] = counter
					end

					net.WriteTable(members)
				net.Send(receivers)
			end
		end
	end
ix.meta.squad = SQUAD

if CLIENT then
	net.Receive("ixSquadDestroy", function(len)
		local tagID = net.ReadUInt(4)
		local squad = dispatch.squads[tagID]

		if squad then
			squad:Destroy()
		end
	end)

	net.Receive("ixSquadSync", function(len)
		local tagID = net.ReadUInt(4)
		local leaderID = net.ReadUInt(32)
		local character = ix.char.loaded[leaderID]

		dispatch.CreateSquad(character, tagID)

		print("NET", "ixSquadSync", len)
	end)
	
	net.Receive("ixSquadSyncFull", function(len)
		local tagID = net.ReadUInt(4)
		local leaderID = net.ReadUInt(32)
		local counter = net.ReadUInt(8)
		local members = net.ReadTable()

		local leader = ix.char.loaded[leaderID]

		local SQUAD = dispatch.CreateSquad(leader, tagID)
		SQUAD.counter = counter

		for charID, id in pairs(members) do
			local character = ix.char.loaded[charID]

			SQUAD.members[character] = id
		end

		print("NET", "ixSquadSyncFull", len)
	end)

	net.Receive("ixSquadAddMember", function(len)
		local tagID = net.ReadUInt(4)
		local charID = net.ReadUInt(32)
		local squad = dispatch.squads[tagID]

		if squad then
			local character = ix.char.loaded[leaderID]

			squad:AddMember(character)
		end

		print("NET", "ixSquadAddMember", len)
	end)

	net.Receive("ixSquadKickMember", function(len)
		local tagID = net.ReadUInt(4)
		local charID = net.ReadUInt(32)
		local squad = dispatch.squads[tagID]

		if squad then
			local character = ix.char.loaded[leaderID]
			
			squad:RemoveMember(character)
		end

		print("NET", "ixSquadKickMember", len)
	end)

	net.Receive("ixSquadLeader", function(len)
		local tagID = net.ReadUInt(4)
		local charID = net.ReadUInt(32)
		local squad = dispatch.squads[tagID]

		if squad then
			local character = ix.char.loaded[leaderID]
			
			squad:SetLeader(character)
		end

		print("NET", "ixSquadLeader", len)
	end)
end
