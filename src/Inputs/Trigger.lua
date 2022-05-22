local Signal = require(script.Parent.Parent.Parent.Signal)
local t = require(script.Parent.Parent.Types).Trigger

local fixSuperclass = require(script.Parent.Parent.Util.fixSuperclass)

local Trigger = {}
local TRIGGER_METATABLE = {}
function TRIGGER_METATABLE:__index(i)
    if i == "RawPosition" then
        return rawget(self, "_rawPosition")
    elseif i == "Position" then
        if self.IsFullyDown then
            return 1
        else
            return self.RawPosition
        end
    elseif i == "TriggerThreshold" then
        return rawget(self, "_triggerThreshold")
    elseif i == "IsDown" then
        return rawget(self, "_isDown")
    elseif i == "IsFullyDown" then
        return rawget(self, "_isFullyDown")
    elseif i == "Up" then
        return rawget(self, "_up")
    elseif i == "Down" then
        return rawget(self, "_down")
    elseif i == "FullyUp" then
        return rawget(self, "_fullyUp")
    elseif i == "FullyDown" then
        return rawget(self, "_fullyDown")
    elseif i == "Changed" then
        return rawget(self, "_changed")
    else
        return TRIGGER_METATABLE[i] or error(i.. " is not a valid member of Trigger", 2)
    end
end
function TRIGGER_METATABLE:__newindex(i)
    error(i.. " is not a valid member of Trigger or is unassignable", 2)
end

function Trigger:constructor(threshold)
    t.new(threshold)

    -- roblox-ts compatibility
    fixSuperclass(self, Trigger, TRIGGER_METATABLE)

    rawset(self, "_rawPosition", 0)
    rawset(self, "_triggerThreshold", threshold or 0.95)
    rawset(self, "_isDown", false)
    rawset(self, "_isFullyDown", false)
    rawset(self, "_up", Signal.new())
    rawset(self, "_down", Signal.new())
    rawset(self, "_fullyUp", Signal.new())
    rawset(self, "_fullyDown", Signal.new())
    rawset(self, "_changed", Signal.new())
end

function Trigger.new(threshold)
    local self = setmetatable({}, TRIGGER_METATABLE)
    Trigger.constructor(self, threshold)

    return self
end

function TRIGGER_METATABLE:UpdateTriggerAbsolute(pos)
    t.UpdateTriggerAbsolute(pos)
    local rawPos = self.RawPosition
    local delta = pos - rawPos

    rawset(self, "_rawPosition", pos)
    if pos > self.TriggerThreshold then
        if not self.IsFullyDown then
            rawset(self, "_isFullyDown", true)
            self.FullyDown:Fire()
        end
    elseif self.IsFullyDown then
        rawset(self, "_isFullyDown", false)
        self.Up:Fire()
    end

    if delta ~= 0 then
        self.Changed:Fire(pos, delta)

        if pos == 0 then
            rawset(self, "_isDown", false)
            self.FullyUp:Fire()
        elseif rawPos == 0 then
            rawset(self, "_isDown", true)
            self.Down:Fire()
        end
    end
end

function TRIGGER_METATABLE:UpdateTriggerDelta(delta)
    self:UpdateTriggerAbsolute(self.RawPosition + delta)
end

function TRIGGER_METATABLE:SetTriggerThreshold(threshold)
    t.SetTriggerThreshold(threshold)
    rawset(self, "_triggerThreshold", threshold)
    self:UpdateTriggerAbsolute(self.Position)
end

-- roblox-ts compatability
Trigger.default = Trigger
return Trigger
