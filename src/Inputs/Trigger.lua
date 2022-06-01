local Signal = require(script.Parent.Parent.Parent.Signal)
local t = require(script.Parent.Parent.Types).Trigger

local fixSuperclass = require(script.Parent.Parent.Util.fixSuperclass)

--[=[
    @class Trigger
    An analog button.
]=]
local Trigger = {}
local TRIGGER_METATABLE = {}
function TRIGGER_METATABLE:__index(i)
    if i == "RawPosition" then
        --[=[
            @within Trigger
            @readonly
            @prop RawPosition number
            The unprocessed position of the trigger. This means the position
            could be negative or greater than 1.
        ]=]
        return rawget(self, "_rawPosition")
    elseif i == "Position" then
        --[=[
            @within Trigger
            @readonly
            @prop Position number
            Position is garunteed to be 0 when at rest and at 1 when past the
            threshold.
        ]=]
        if self.IsFullyDown then
            return 1
        else
            return self.RawPosition
        end
    elseif i == "TriggerThreshold" then
        --[=[
            @within Trigger
            @readonly
            @prop TriggerThreshold number
            The threshold at which the trigger is considered to be fully down.
        ]=]
        return rawget(self, "_triggerThreshold")
    elseif i == "IsDown" then
        --[=[
            @within Trigger
            @readonly
            @prop IsDown boolean
            If the trigger is down at all.
        ]=]
        return rawget(self, "_isDown")
    elseif i == "IsFullyDown" then
        --[=[
            @within Trigger
            @readonly
            @prop IsFullyDown boolean
            If the trigger is fully down.
        ]=]
        return rawget(self, "_isFullyDown")
    elseif i == "Up" then
        --[=[
            @within Trigger
            @readonly
            @prop Up Signal<>
            Fires when the trigger is released from the fully down position.
        ]=]
        return rawget(self, "_up")
    elseif i == "Down" then
        --[=[
            @within Trigger
            @readonly
            @prop Down Signal<>
            Fires when the trigger is initially pressed.
        ]=]
        return rawget(self, "_down")
    elseif i == "FullyUp" then
        --[=[
            @within Trigger
            @readonly
            @prop FullyUp Signal<>
            Fires when the trigger is released fully.
        ]=]
        return rawget(self, "_fullyUp")
    elseif i == "FullyDown" then
        --[=[
            @within Trigger
            @readonly
            @prop FullyDown Signal<>
            Fires when the trigger is fully pressed.
        ]=]
        return rawget(self, "_fullyDown")
    elseif i == "Changed" then
        --[=[
            @within Trigger
            @readonly
            @prop Changed Signal<(pos: number, delta: number)>
            Fires when the trigger's position changes.
        ]=]
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

--[=[
    @within Trigger
    @param threshold number?
    @return Trigger
]=]
function Trigger.new(threshold)
    local self = setmetatable({}, TRIGGER_METATABLE)
    Trigger.constructor(self, threshold)

    return self
end

--[=[
    @within Trigger
    @param pos number
    Updates the position of the trigger by an absolute value.
]=]
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

--[=[
    @within Trigger
    @param delta number
    Updates the position of the trigger by a relative value.
]=]
function TRIGGER_METATABLE:UpdateTriggerDelta(delta)
    self:UpdateTriggerAbsolute(self.RawPosition + delta)
end

--[=[
    @within Trigger
    @param threshold number
    Sets the threshold at which the trigger is considered to be fully down.
]=]
function TRIGGER_METATABLE:SetTriggerThreshold(threshold)
    t.SetTriggerThreshold(threshold)
    rawset(self, "_triggerThreshold", threshold)
    self:UpdateTriggerAbsolute(self.Position)
end

-- roblox-ts compatability
Trigger.default = Trigger
return Trigger
