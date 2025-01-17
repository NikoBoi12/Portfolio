local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(ReplicatedStorage.PlayerData)

local RNG = {}

local RandomObj = Random.new()

local function FindDuplicates(RarityTable)
	local DuplicateValues = {}

	for i, Config in RarityTable do
		if not DuplicateValues[Config.Rarity] then
			DuplicateValues[Config.Rarity] = {}
		end
		table.insert(DuplicateValues[Config.Rarity], {AuraName = Config.AuraName, Rarity = Config.Rarity, RarityConfig = Config})
	end
	
	for Rarity, Config in DuplicateValues do
		if #Config == 1 then
			DuplicateValues[Rarity] = nil
		else
			for Index, Value in Config do
				local FindValue = table.find(RarityTable, Value.RarityConfig)
				table.remove(RarityTable, FindValue)
			end

			table.sort(Config, function(A,B)
				return A.Rarity > B.Rarity
			end)
		end
	end

	for DuplicateRarity, Config in DuplicateValues do
		local Check = true
		while Check do
			for _, Value in Config do
				local RandomNum = RandomObj:NextInteger(1, 10)
				
				if RandomNum == 1 then
					table.insert(RarityTable, {AuraName = Value.AuraName, Rarity = DuplicateRarity})
					Check = false
					break
				end
			end
		end
	end
end

function RNG.CalculateRng(Player, WeightedTable, Fallback, LuckOverride, WeekendBoost)
	local Data
	local Luck = LuckOverride or 1
	
	if Player then
		Data = PlayerData.GetData(Player)
		if not Data then return end
		
		local PremiumLuck = 0
		
		if Player.MembershipType == Enum.MembershipType.Premium then
			PremiumLuck = .1
		end
		
		Luck = (Data.VIPPass and 1.5 or 1) * ((Data.PityLuck + (WeekendBoost or 0) + PremiumLuck) * (1 + (Data.GearLuck + Data.ObbyLuck + Data.PotionLuck + Data.SpecialLuck + Data.CircleLuck + (LuckOverride or 0))))
		if Luck <= 0 then Luck = .1 end
	end
	
	local HighestToLowest = {}
	
	local WeightTestTable = {}
	
	local Table = {}
	
	for Name, Config in WeightedTable do
		if Config.Rarity then
			local AdjustedRarity = Config.Rarity/Luck
			
			if AdjustedRarity < 2 then AdjustedRarity = 2 end
			
			WeightTestTable[Name] = Config.Rarity
			
			
			table.insert(HighestToLowest, {AuraName = Name, Rarity = AdjustedRarity})
		end
	end
	
	FindDuplicates(HighestToLowest)
	
	table.sort(HighestToLowest, function(A,B)
		return A.Rarity > B.Rarity
	end)
	
	for i, Config in HighestToLowest do
		local RandomNum = RandomObj:NextInteger(1, Config.Rarity)
		
		if RandomNum == 1 then
			if not Config.AuraName then
				warn("RNG ROLL HAS FAILED THIS IS A REPORT"..i.." "..Config)
			end
			return Config.AuraName or Fallback
		end
	end
	return Fallback
	
end


return RNG
