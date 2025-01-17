local Utility = require(game.ReplicatedStorage.Modules.Utility)

local Timer = {}

local ActiveTimers = {}

Timer.new = function(Duration, Start, Name)
	local self = Utility.Factory(Timer)
	self.Name = Name
	self.Completed = Utility.NewEvent()
	self.Updated = Utility.NewEvent()
	self.Current = 0
	self.Duration = Duration
	self.IsRunning = false

	if Start then
		self:Start()
	end

	return self
end

function Timer:Update(DeltaTime)
	self.Current += DeltaTime
	self.Updated:Fire(DeltaTime)
	if self.Current >= self.Duration then
		self:Pause()
	end
end

function Timer:Start()
	if self.IsRunning == true then
		return
	end

	self.IsRunning = true
	table.insert(ActiveTimers, self)
end


function Timer:Pause()
	self.IsRunning = false
	local CurrentTimer = ActiveTimers and self and table.find(ActiveTimers, self) or nil
	if CurrentTimer then
		if self.Completed then
			self.Completed:Fire()
			if self.Completed.Parent ~= nil then
				self.Completed:Destroy()
			end
		end

		table.remove(ActiveTimers, CurrentTimer)
	else
		warn("Could not find timer?", self)
	end
end


function Timer:Restart()
	self.Current = 0
end


task.defer(function()
	while true do
		local DeltaTime = task.wait()
		for i, Timer in ActiveTimers do
			Timer:Update(DeltaTime)
		end
	end
end)


return Timer
