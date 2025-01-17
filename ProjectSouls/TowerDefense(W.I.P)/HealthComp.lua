local Module = { -- ?
	Health = 100,
	MaxHealth = 100,
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") 

local Utility = require(ReplicatedStorage:WaitForChild("Utilities").ReverbUtils)
local MobService = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("MobService"))

local UpdateHealthUI = ReplicatedStorage.Remotes.UpdateMobHealth

local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

Module.new = function(Health, MaxHealth)
	local self = Utility.Factory(Module)
	self.Health = Health or 100
	self.MaxHealth = MaxHealth or 100
	self.Died = Utility.NewEvent()
	self.Changed = Utility.NewEvent()
	self.IsDead = false
	self.Connections = {}
	
	return self
end

Module.onDied = function(self)
	self.IsDead = true
	self.Died:Fire()
end

Module.onChanged = function(self, UID, PreviousHealth)
	self.Changed:Fire(self.Health, PreviousHealth) -- remove that when base health fixed
	if self.Health <= 0 and not self.IsDead then
		self:onDied()
	else
		UpdateHealthUI:FireAllClients(self.Health, UID)
	end
end

Module.Die = function(self)
	if not self.IsDead then
		self.Health = 0
		self:onDied()
	end
end

Module.Damage = function(self, Damage, UID) -- if died den tower shouldnt focus on attack
	local PrevHealth = self.Health
	self.Health = math.clamp(self.Health - Damage, 0, math.huge)
	self:onChanged(UID, PrevHealth)
	
	if self.Health > 0 then
		return Damage
	else
		return PrevHealth
	end
	
end


Module.UpdateHealth = function(Health, UID)
	local self = MobService.List[UID]

	if (self == nil) or (self.Model == nil) then return end
	
	self.Health.Health = Health
	if self.Model:FindFirstChild("Health") then
		self.Model.Health.Frame.TextLabel.Text = Health.."/"..self.Model.Health:GetAttribute("MaxHealth")
		self.Model.Health.Frame.Damage.Size = UDim2.fromScale(1 - self.Health.Health/self.Health.MaxHealth, 1)
	end
end

function Module:Destroy()
	self:Die()
end

if IsClient then
	UpdateHealthUI.OnClientEvent:Connect(Module.UpdateHealth)
end

return Module
