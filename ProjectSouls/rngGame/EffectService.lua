local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Utility = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utility"))
local AnimationUtility = require(ReplicatedStorage.Modules:WaitForChild("AnimationUtility"))
local RollConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("RollConfig"))
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local Blacklist = require(script:WaitForChild("Blacklist"))

local Replicate = script:WaitForChild("Replicate")

local module = {
	List = {}
}

local Effect = {}

function module.CreateEffect(Player, Packet)
	local self = Utility.Factory(Effect)
	self.Config = RollConfig[Packet.Name]
	
	self.Owner = Packet.Owner or Player
	self.UID = Packet.UID or Utility.GenerateUID()
	self.Name = Packet.Name
	self.Rig = self.Config.Aurav2
	self.RandomSeed = Packet.RandomSeed or math.random(99999)
	self.Connections = {}
	self.ActiveEffects = {}
	self.Player = Player
	
	module.List[self.UID] = self
	
	if RunService:IsServer() then
		Replicate:FireAllClients(Player, self:CreatePacket())
		table.insert(self.Connections, Players.PlayerAdded:Connect(function(NewPlayer)
			Replicate:FireClient(NewPlayer, Player, self:CreatePacket())
		end))

	else
		self:Start()
	end
	
	return self
end


function Effect:Start()
	local Character = self.Owner.Character
	
	local Rig = self.Rig:Clone()
	
	for _, Script in Rig:GetDescendants() do
		if Script:IsA("Script") then
			Script.Enabled = true
		end
	end
	
	for _, Part in Rig:GetChildren() do
		if table.find(Blacklist, Part.Name) then continue end
		
		local MotorSearch = Part:FindFirstChildWhichIsA("Motor6D") or Part:FindFirstChildWhichIsA("WeldConstraint")
		
		if MotorSearch then
			if Character:FindFirstChild(MotorSearch.Part0.Name) then
				MotorSearch.Part1.RootPriority = -1
				MotorSearch.Part0 = Character[MotorSearch.Part0.Name]
			end
		end
		
		table.insert(self.ActiveEffects, Part)
		
		Part.Parent = Character
	end
	
	for _, Part in Rig:GetChildren() do
		if Part.Name == "Humanoid" then continue end
		for _, ChildPart in Part:GetChildren() do
			if table.find(Blacklist, ChildPart.Name) then continue end
			
			if ChildPart:IsA("Motor6D") then
				ChildPart.Part0 = Character[ChildPart.Part0.Name]
			end
			
			if ChildPart:IsA("BillboardGui") then
				local Label = nil
				if ChildPart.Name == "Rarity" then
					Label = ChildPart:FindFirstChildWhichIsA("TextLabel")
				elseif ChildPart:FindFirstChild("Rarity") then
					Label = ChildPart:FindFirstChild("Rarity")
				end
				
				if Label then
					local Rarity = self.Config.Rarity and "1 in "..self.Config.Rarity or self.Config.Phrase or ""
					if Label.Text == "" then
						Label.Text = Rarity
					end
				end
			end
			
			ChildPart.Parent = Character[ChildPart.Parent.Name]
			
			table.insert(self.ActiveEffects, ChildPart)
		end
	end
	
	if not  self.Config.Rarity or self.Config.Rarity >= 10000 then
		self.PlayerAudio = self.Config.Theme:Clone()

		self.PlayerAudio.SoundGroup = ReplicatedStorage.Configs.SoundConfig.MuteOtherPlayersMusic
		self.PlayerAudio.Name = "AuraMusic"
		self.PlayerAudio.RollOffMaxDistance = 193.108
		self.PlayerAudio.RollOffMinDistance = 42.913
		self.PlayerAudio.RollOffMode = Enum.RollOffMode.InverseTapered

		self.PlayerAudio.Parent = Character.HumanoidRootPart
		self.PlayerAudio.Volume = 0
		
		self.PlayerAudio:Play()

		if self.Owner ~= self.Player then
			self.PlayerAudio.Volume = .3
		end
	end
	


	Rig:Destroy()
	
	if self.Rig:FindFirstChild("Animations") then
		for i, Animation in self.Rig.Animations:GetChildren() do
			AnimationUtility.Play(Character, Animation.Value)
		end
	end
end


function Effect:CreatePacket()
	return {
		Owner = self.Owner,
		Name = self.Name,
		UID = self.UID,
		RandomSeed = self.RandomSeed,
	}
end



function Effect:Destroy()
	module.List[self.UID] = nil
	
	for _, Connection in self.Connections do
		Connection:Disconnect()
	end
	
	if RunService:IsServer() then
		script.DestroyEffect:FireAllClients(self.UID)
	else
		local Character = self.Owner.Character
		if self.Rig:FindFirstChild("Animations") then
			for _, Animation in self.Rig.Animations:GetChildren() do
				AnimationUtility.Stop(Character, Animation.Value)
			end
		end

		for _, Effect in self.ActiveEffects do
			Effect:Destroy()
		end
	end
	
	self = nil
end


if RunService:IsServer() then

else
	script.DestroyEffect.OnClientEvent:Connect(function(UID)
		local Effect = module.List[UID]
		local TotalTime = 0
		
		while Effect == nil do
			local DeltaTime = task.wait()
			TotalTime += DeltaTime
			
			Effect = module.List[UID]
			
			if TotalTime >= 10 then warn("UID not found") return end
		end
		Effect:Destroy()
	end)
	Replicate.OnClientEvent:Connect(module.CreateEffect)
end

return module
