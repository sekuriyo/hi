

--[[

	SigmaRager
	07/03/2022
	Player State Tracker to set or get the current state of a player.
	
	player_states = EnumList.new("PlayerStates", {"Apartment", "Delivering", "Upgrading"})

]]



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local EnumList = require(ReplicatedStorage.Packages.EnumList) 

local format = string.format

local PlayerStateManager = Knit.CreateService{
	Name = "PlayerStateManager",
	Players = {},
	Client = {}
}

--[[

Tracking state:

	Client:
		PlayerStateManager.Client:GetState(player : userdata) --Returns the state

	Server:
		PlayerStateManager:GetState(player : userdata)
		PlayerStateManager:SetState(player : userdata, new_state : string)
		
]]


function PlayerStateManager:KnitStart()
	
	
	local player_states = EnumList.new("PlayerStates", {"Apartment", "Delivering", "Upgrading"})
	
	local player_class = {}
	player_class.__index = player_class
	
	function player_class.new(player)
		local self = {}
		self.player = player
		self.state = player_states.Apartment
		return self
	end
	
	function player_class.deconstruct()
		self.player = nil
		self.state = nil
		self = nil
	end
	
	local function onPlayerAdded(player)
		local tracked_player = player_class.new(player)
		self.Players[player] = tracked_player
		warn(format("Player %s has been added to the table of tracked player states", tostring(player)))
	end
	
	local function onPlayerRemoving(player)
		if self.Players[player] then
			self.Players[player].deconstruct()
			self.Players[player] = nil
			warn(format("Player %s has been removed to the table of tracked player states", tostring(player)))
		end
		warn(format("Player %s left the game but is not in the table of tracked player states", tostring(player)))
	end
	
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end


function PlayerStateManager:GetState(player)
	return self.Players[player].state
end


function PlayerStateManager:SetState(player, state)
	assert(self.Players[player] ~= nil, format("%s doesn't have an active state tracker setup", tostring(player)))
	self.Players[player].state = state
end


function PlayerStateManager.Client:GetState()
	return PlayerStateManager:GetState()
end


return PlayerStateManager

