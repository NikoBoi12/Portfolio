local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))
local NetSync = require(ReplicatedStorage:WaitForChild("NetSync"))
local CurrencyManager = require(ReplicatedStorage:WaitForChild("DataManagers"):WaitForChild("CurrencyManager"))

local Client = RunService:IsClient()
local Server = RunService:IsServer()

local SkillManager = {}


function SkillManager.HasSkill(Player, Skill)
	if not Skill then warn("Skill is invalid or nil") return end
	local Data = PlayerData.GetData(Player)
	
	return NetSync.table.find(Data.SoulSkill.Skills, Skill)
end

function SkillManager.AddBuffs(Player, SelectedSkill)
	local Data = PlayerData.GetData(Player)
	
	local Config = require(ReplicatedStorage.Configs.SoulSkills[Data.SoulSkill.Soul])[SelectedSkill]

	for Buff, Value in Config.Buffs or {} do
		if not Data.SoulSkill.Buffs[Buff] then Data.SoulSkill.Buffs[Buff] = Value return end
		if typeof(Value) ~= "number" then warn("Value is not a number: "..Value) return end
		Data.SoulSkill.Buffs[Buff] += Value
	end
end


function SkillManager.UnlockSkill(Player, SelectedSkill)
	if not Player or not Player.Parent then warn((Player and Player.Name or "Unknown").." Seems to have left the game") return end
	local Data = PlayerData.GetData(Player)
	local Config = require(ReplicatedStorage.Configs.SoulSkills[Data.SoulSkill.Soul])[SelectedSkill]

	if not Config then warn("Invalid Config For "..SelectedSkill) return end
	if SkillManager.HasSkill(Player, SelectedSkill) then warn("Already have this skill") return end
	if not CurrencyManager.CanRemoveSkillPoints(Player, Config.Cost) then warn("Not enough skill points for "..SelectedSkill) return end
	
	if Client then
		script.UnlockSkill:FireServer(SelectedSkill)
	else
		SkillManager.AddBuffs(Player, SelectedSkill)
	end
	
	Data.SoulSkill.Skills[#Data.SoulSkill.Skills + 1] = SelectedSkill
	CurrencyManager.RemoveSkillPoint(Player, Config.Cost)
	
	return true
end


if Server then
	script.UnlockSkill.OnServerEvent:Connect(SkillManager.UnlockSkill)
end


return SkillManager
