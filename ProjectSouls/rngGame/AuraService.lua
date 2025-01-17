local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Utility = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utility"))
local EffectService = require(script.Parent:WaitForChild("EffectService"))
local EffectServicev2 = require(script.Parent:WaitForChild("EffectServicev2"))
local RollConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("RollConfig"))
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))

local Replicate = script:WaitForChild("Replicate")
local RemoveAura = script:WaitForChild("RemoveAura")

local module = {
	List = {}
}

local Aura = {}

function module.CreateAura(Player, Packet)
	local self = Utility.Factory(Aura)
	
	local AuraConfig = RollConfig[Packet.Name]

	self.Name = Packet.Name
	self.Owner = Packet.Owner or Player
	self.UID = Packet.UID or Utility.GenerateUID()
	self.Effects = {}
	self.Effectsv2 = {}
	self.Connections = {}
	self.Config = AuraConfig
	module.List[self.UID] = self
	if RunService:IsServer() then
		if AuraConfig.Aura then
			for _, Aura in AuraConfig.Aura do
				table.insert(self.Effects, (EffectService.CreateEffect(Player, self:EffectPacket(Aura))))
			end
		end
		
		if AuraConfig.Aurav2 then
			table.insert(self.Effectsv2, (EffectServicev2.CreateEffect(Player, self:EffectPacketv2())))
		end
		
		Replicate:FireAllClients(Player, self:CreatePacket())
		table.insert(self.Connections, Players.PlayerAdded:Connect(function(NewPlayer)
			Replicate:FireClient(NewPlayer, Player, self:CreatePacket())
		end))
	else
		local HRP = self.Owner.Character:WaitForChild("HumanoidRootPart")
		self.Equipment = AuraConfig.Equipment and AuraConfig.Equipment[2]:Clone() or nil
		
		local CustomUse = AuraConfig.CustomUse and AuraConfig.CustomUse.SetUp(self) or nil
		self.Effects = EffectService.List[self.UID]
		self.Effectsv2 = EffectServicev2.List[self.UID]

		if self.Owner == Players.LocalPlayer then
			self:CreateConnections()
		end
		
		
		if AuraConfig.Aura then
			self.Display = AuraConfig.DisplayGui:Clone()
			if self.Display.Rarity.Text == "" then
				local Rarity = AuraConfig.Rarity or AuraConfig.Phrase
				self.Display.Rarity.Text = "1 in "..Rarity
			end
			
			for _, Desendant in self.Display:GetDescendants() do
				if Desendant:IsA("Script") then
					Desendant.Enabled = true
				end
			end
			
			self.Display.Parent = HRP
		end
		
		if self.Equipment then
			HRP:WaitForChild(AuraConfig.Equipment[1]).Part1 = self.Equipment.PrimaryPart
			self.Equipment.Parent = self.Owner.Character
		end
	end
	
	return self
end


function module.GetAura(UID)
	return module.List[UID]
end


function module.GetEffect(AuraUID, EffectUID)
	return EffectService.List[AuraUID][EffectUID]
end


function Aura:EffectPacket(Name)
	return {
		Owner = self.Owner,
		Name = self.Name,
		EffectName = Name,
	}
end

function Aura:EffectPacketv2()
	return {
		Owner = self.Owner,
		Name = self.Name,
	}

end

function Aura:CreatePacket()
	return {
		Owner = self.Owner,
		Name = self.Name,
		UID = self.UID,
	}
end

function Aura:CreateConnections()
	if self.Config.CustomUse then
		
		self.Owner.PlayerGui.HUD.Canvas.Ability.Visible = true
		
		table.insert(self.Connections, UserInputService.InputBegan:Connect(function(Input, GameService)
			if GameService then return end

			if Input.KeyCode == Enum.KeyCode.V then
				self.Config.CustomUse.Use(self)
			end
		end))
		table.insert(self.Connections, Players.LocalPlayer.PlayerGui.HUD.Canvas.Ability.Activated:Connect(function()
			task.wait(1) -- Yield cuz mobile users/to give a chance to aim
			self.Config.CustomUse.Use(self)
		end))
	end
end



function Aura:Destroy()
	module.List[self.UID] = nil
	
	for _, Connection in self.Connections do Connection:Disconnect() end
	
	if self.Owner == Players.LocalPlayer and self.Config.CustomUse then self.Owner.PlayerGui.HUD.Canvas.Ability.Visible = false end
	
	if RunService:IsServer() then
		for _, self in self.Effects do self:Destroy() end
		for _, self in self.Effectsv2 do self:Destroy() end
		RemoveAura:FireAllClients(self.UID)
	else
		if self.Display then self.Display:Destroy() end
		if self.Equipment then self.Equipment:Destroy() end
	end
end




if RunService:IsServer() then

else
	Replicate.OnClientEvent:Connect(module.CreateAura)
	
	script.RemoveAura.OnClientEvent:Connect(function(UID)
		local Aura = module.List[UID]
		local TotalTime = 0

		while Aura == nil do
			local DeltaTime = task.wait()
			TotalTime += DeltaTime

			Aura = module.List[UID]

			if TotalTime >= 10 then warn("UID not found") return end
		end
		
		Aura:Destroy()
	end)
end

return module
