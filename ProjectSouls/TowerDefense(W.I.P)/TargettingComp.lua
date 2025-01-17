local Module = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(ReplicatedStorage:WaitForChild("Utility"))
local GameUtility = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("GameUtility"))

local MobService = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("MobService"))
local GridService = require(ReplicatedStorage.Utilities:WaitForChild("Grid"))
local TargetModes = require(script.TargetModes)

local arcs = require(script:WaitForChild("Arcs"))
local triangles = require(script:WaitForChild("Triangle"))

local MobsFolder = workspace:WaitForChild("Mobs")
local TowersFolder = workspace:WaitForChild("Towers")

local Paths = workspace:WaitForChild("Paths")
local SpawnPart = Paths:WaitForChild("Spawn")
local BasePart = Paths:WaitForChild("Base")

Module.new = function(Tower)
	local self = Utility.Factory(Module)
	self.TargetChanged = Utility.NewEvent()
	self.PointCache = {}

	return self
end

Module.GetArcs = function(self, Tower, pos)
	local origin = pos and pos or Tower.Location
	local arcs = arcs.GetValidArcs(origin.p, Tower.Range)
	
	local pointCache = self.PointCache

	local a = origin.p -- origin
	for i = 1, #arcs do
		local currentResult = arcs[i]
		local nextResult = i == #arcs and arcs[1] or arcs[i+1]

		local b = currentResult.ray and currentResult.ray or (a + currentResult.direction)
		local c = nextResult.ray and nextResult.ray or (a + nextResult.direction)

		-- print(newTrigangle)
		local difference = math.abs(#pointCache - #arcs)
		if #pointCache > #arcs then
			-- delete parts
			--print("Delete")
			for i = #pointCache, #arcs + difference, -1 do
				pointCache[i]:Destroy()
				table.remove(pointCache, i)
			end
		elseif #pointCache < #arcs then
			-- add parts
			--print("Add")
			for i = #pointCache + 1, #arcs do
				local w1, w2 = triangles.Draw(a, b, c, nil) -- vecA, vecB, vecC, parent
				table.insert(pointCache, {w1, w2})
			end
		end

		if pointCache[i] then
			triangles.Draw(a, b, c, nil, pointCache[i][1], pointCache[i][2])
		end
	end
	
	self.Arcs = arcs

	return arcs, pointCache
end

Module.FilterBlindspots = function(self, Tower, Targets)
	-- Targets = { {Object=Model,Distance=number,Direction=number}, ... }
	
	local validTargets = {}
	local arcs = self.Arcs or self:GetArcs(Tower)

	local TowerPosition = Tower.Location.Position
	for _, TargetData in Targets do
		local mob = TargetData.Object
		local mobDistance = TargetData.Distance
		local mobDirection = TargetData.Direction
		local mobPosition = mob:GetPivot().Position

		-- compare and find closest arc
		local closestArc = nil
		local maxDot = -1

		for _, arcResult in arcs do
			local dot = arcResult.direction:Dot(mobDirection)
			if dot > maxDot then
				maxDot = dot
				closestArc = arcResult
			end
		end

		-- confirm mob is within threshold
		local bound = closestArc.ray or (TowerPosition + closestArc.direction)
		local threshold = (TowerPosition - bound).Magnitude
		if mobDistance < threshold then
			table.insert(validTargets, mob)
		end
	end

	return validTargets
end

Module.SwitchState = function(self, StateName, Tower)
	Tower.TowerData.State = StateName
	self:GetTarget(Tower)
end

Module.UpdateTarget = function(self, Target)
	self.TargetChanged:Fire(Target)
end

local MobsGrid = GridService.GetGrid("MobsGrid")
Module.GetTarget = function(self, Tower, UIDs) 
	--local ValidTargets = GameUtility.GetModelsInRange(Tower, MobsFolder:GetChildren())
	local ValidTargets = MobsGrid:GetObjectsInRange("Mob", Tower.Location.Position, Tower.TowerData.Range)
	
	--ValidTargets = self:FilterBlindspots(Tower, ValidTargets)
	
	local State = Tower.TowerData.TargetState

	local Target
	if (#ValidTargets ~= 0) and (TargetModes[State]) then
		Target = TargetModes[State](Tower, ValidTargets) --ValidTargets[1].Object
	end

	if Target ~= Tower.Target then
		self.TargetChanged:Fire(Target)
	end
end


function Module:Destroy()
	for i, Point in self.PointCache do
		for _, Wedge in Point do
			Wedge:Destroy()
		end
		self.PointCache[i] = nil
	end
end

return Module
