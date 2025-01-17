local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") 
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local TowerModule = ReplicatedStorage:WaitForChild("Services"):WaitForChild("TowerService")
local MobService = require(ReplicatedStorage.Services:WaitForChild("MobService"))

local Utility = require(ReplicatedStorage:WaitForChild("Utility"))
local GameUtility = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("GameUtility"))

--local worldVfxFolder = workspace:WaitForChild("VFX")

local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()
local IsStudio = RunService:IsStudio()

local Module = {}

function Module.new(Tower)
	local self = Utility.Factory(Module)

	self.Tower = Tower
	self.IsAttacking = Utility.NewEvent()
	self.LastAttack = tick()
	self.Connections = {}

	Tower.TowerData.TargetState = Tower.Config.BaseTargetState or "First"
	
	self:BindEvents()

	return self
end


function Module:WaitForTargetting()
	local TimeOut = 0
	while not self.Tower.Targetting do
		local DT = task.wait()
		if TimeOut >= 3 then
			return false
		end
		
		TimeOut += DT
	end
	
	return true
end


function Module:BindEvents()
	task.defer(function()
		local HasTargetComp = self:WaitForTargetting()
		if not HasTargetComp then warn("Missing Targetting Component this is required to use the attack component") return end
		
		self.Connections[#self.Connections+1] = RunService.Heartbeat:Connect((function(DT)
			if IsServer then
				self.Tower.Targetting:GetTarget(self.Tower)

				self:Attack(self.Target)
			end
		end))

		self.Connections[#self.Connections+1] = self.Tower.Targetting.TargetChanged:Connect(function(Target)
			self.Target = Target
		end)
	end)

end


function Module:Attack(Mob)
	local Tower = self.Tower

	if ((tick() - self.LastAttack) > Tower.TowerData.AttackSpeed) then
		self.LastAttack = tick()
		
		if self.Target then
			script.ClientVisuals:FireAllClients(Tower.UID, Mob.UID)
			Module[Tower.TowerData.AttackType](Mob, Tower)
		end
		
		--print(Tower.Targets)
		--[[
		checks attack type
		fires remote to client for vfx
		delay
		fires function of attack type dealing damage
		]]
	end
end


function Module.ClientAttack(TowerUID, MobUID)
	local Tower = require(TowerModule).List[TowerUID]
	local Mob = MobService.List[MobUID]
	
	if not (Mob and Tower) then return end
	
	local SFX = Tower.Model:FindFirstChild("SFX")

	local TowerPos = Tower.Location.Position
	local Noramlized = (Mob.Model:GetPivot().Position * Vector3.new(1, 0, 1)) + Vector3.new(0, TowerPos.Y, 0)

	Tower.Model:PivotTo(CFrame.lookAt(TowerPos, Noramlized))
	
	if SFX then
		if SFX:FindFirstChild("AttackSound") then SFX.AttackSound:Play() end
	end
end


function Module.Single(Mob, Tower)
	Mob.Health:Damage(Tower.TowerData.Damage, Mob.UID)
end


function Module.TowerAOE(Mob, Tower)
	local Pos, Range = Tower.Location.Position, Tower.TowerData.Range
	local Targets
	
	Targets = MobService.Grid:GetObjectsInRange("Mob", Pos, Range)	
	for _, Target in Targets do
		Target.Object.Health:Damage(Tower.TowerData.Damage, Target.Object.UID)
	end
end


function Module.VisualizeAOE(Position, Radius)
	local Sphere = script.AOEVisual:Clone()
	
	Sphere.Position = Position
	Sphere.Size = Vector3.new(Radius*2, Radius*2, Radius*2)
	Sphere.Parent = workspace
	
	Debris:AddItem(Sphere, 1)
end


function Module.ProjectileAOE(Mob, Tower)
	local Pos, Radius = Mob:GetPivot().Position, Tower.TowerData.Radius
	local Targets

	Targets = MobService.Grid:GetObjectsInRange("Mob", Pos, Radius)	
	
	Module.VisualizeAOE(Pos, Radius)
	
	for _, Target in Targets do
		Target.Object.Health:Damage(Tower.TowerData.Damage, Target.Object.UID)
	end
end


function Module:Remove()
	GameUtility.DisconnectConnections(self.Connections)
end



if RunService:IsServer() then
	
else
	script.ClientVisuals.OnClientEvent:Connect(Module.ClientAttack)
end


return Module
