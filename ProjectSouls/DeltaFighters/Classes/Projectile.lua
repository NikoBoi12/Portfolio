local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(game.ReplicatedStorage.Modules.NikoModules.Utility)

local Projectile = {}

local Manager = {}

Projectile.New = function(Speed, MaxTime, MainPart, Params, Visual)
	local self = Utility.Factory(Projectile)
	
	self.Completed = Instance.new("BindableEvent")
	self.MainPart = MainPart
	self.Speed = Speed -- Studs per second
	self.TotalTime = 0
	self.MaxTime = MaxTime
	self.Params = RaycastParams.new()
	
	self.Params.FilterDescendantsInstances = Params
	self.Params.FilterType = Enum.RaycastFilterType.Exclude
	
	self:StartMovment()

	return self
end


Projectile.StartMovment = function(self)
	table.insert(Manager, self)
end


Projectile.Update = function(self, DeltaTime)
	self.TotalTime = math.clamp(self.TotalTime + DeltaTime,0,self.MaxTime)
	
	self:CastRay(DeltaTime)
	self:Movment(DeltaTime)
	
	if self.TotalTime == self.MaxTime then
		self:DespawnProjectile()
	end
end


Projectile.CastRay = function(self, DeltaTime)
	local RaycastResult = workspace:Raycast(self.MainPart.Position, self.MainPart.CFrame.LookVector * self.Speed * DeltaTime, self.Params)
	
	if RaycastResult then
		self:Result(RaycastResult)
	end
end


Projectile.Movment = function(self, DeltaTime)
	local CFrameCalculation = self.MainPart.CFrame + self.MainPart.CFrame.LookVector * self.Speed * DeltaTime
	
	self.MainPart.CFrame = CFrameCalculation
end


Projectile.Result = function(self, RaycastResult)
	local Find = table.find(Manager, self)
	table.remove(Manager, Find)
	self.Completed:Fire(RaycastResult)
end


Projectile.DespawnProjectile = function(self)
	local Find = table.find(Manager, self)
	table.remove(Manager, Find)
	if not self.MainPart.Parent:IsA("BasePart") and self.MainPart.Parent ~= workspace then
		self.MainPart.Parent:Destroy()
	else 
		self.MainPart:Destroy()
	end
	self.Completed:Destroy()
end


task.defer(function()
	while true do
		local DeltaTime = task.wait()
		for i, Projectile in Manager do
			Projectile:Update(DeltaTime)
		end
	end
end)


return Projectile
